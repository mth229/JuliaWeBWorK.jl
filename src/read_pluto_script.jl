## Author in Pluto
## First cell should look like this:
#=

begin
	import Pkg
	Pkg.add(url = "https://github.com/mth229/JuliaWeBWorK.jl.git")
	using JuliaWeBWorK
	function Base.show(io::IO, obj::JuliaWeBWorK.AbstractQ)
		o = JuliaWeBWorK.question_html(obj)
		show(io, MIME("text/html"), HTML(first(o)))
		println(io, "")
		if !isnothing(o.o)
            if o.o == JuliaWeBWorK._blank_
				show(io, "____answer = $(o.a)____")
			else
				for u in o.o
					box = o.a == u ? "✓ " : "□ "
                    show(io, box)
                    show(io, u)
                end
			end
		end
	end
end
=#

# Second cell defines `intro` as last entry, e.g.:
#=
begin
	answer_context = ""
	meta = (href="abc", url="abc")

	using MTH229
	using Plots
	gr()
	letters = JuliaWeBWorK.LETTERS() # here not in 1st cell

	f(x) = sin(x^2) + x
	p1 =  plot(f, -2,  2);


intro = md"""
...
"""
=#
# Then the rest can be parsed by this script

using JuliaWeBWorK
using Markdown
import Mustache
Mustache.render(o::Markdown.MD) = Markdown.plain(o)
# read a script
f = "pluto-script.jl"
line_delimiter_lambda = startswith("# ╔═╡ ")


function make_module(nm=randstring())
    nm = "Z"*uppercase(nm)
    eval(Meta.parse("module " * nm * " end"))
    eval(Meta.parse(nm))
end


safeeval(m, ex::Nothing) = nothing
function safeeval(m, ex::Union{Number,Symbol, Expr})
    try
        res = Core.eval(m, ex)


    catch e
        printstyled("Error with evaluating $ex: $(string(e))\n", color=:red)
        @show (string(e))
    end
end

function process_block(m, txt)
    result = ""
    cmd = "begin\n" * join(txt, "\n") * "end"
    result = safeeval(m, Meta.parse(cmd))
end


function read_script(f; line_delimiter_lambda=startswith("# ╔═╡ "), offset::Int=1)
    m = Module()
    process_block(m, split("""
using Markdown
using JuliaWeBWorK
letters = JuliaWeBWorK.LETTERS()
""", "\n"))

    qs = JuliaWeBWorK.QUESTIONS()
    ls = readlines(f)
    inds = findall(line_delimiter_lambda, ls)

    intro_lines = ls[inds[1+offset]+1 : inds[2+offset]-1]
    # intro lines define meta, answer_context
    intro = process_block(m, intro_lines)
    meta = isdefined(m, :meta) ? m.meta : ()
    answer_context = isdefined(m, :answer_context) ? m.answer_context : Dict{Symbol, String}()

    for i in (3+offset):length(inds)
        lines = ls[inds[i-1]+1:inds[i]-1]
        o = process_block(m, lines)
        isa(o, JuliaWeBWorK.AbstractQ) &&  push!(qs, o)
    end

    Page(intro, qs; meta, answer_context)
end
