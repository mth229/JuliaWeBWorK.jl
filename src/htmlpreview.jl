# How to make a hard copy of a page

using quarto_jll: quarto
import Markdown

_to_md(m::Char, args...; kwargs...) = (@show m; m)
_to_md(m, args...; kwargs...) = Markdown.parse(m)
_to_md(m::Number, args...; kwargs...) = m
function _to_md(m::Union{String, Mustache.MustacheTokens}, args...; kwargs...)
    Mustache.render(m, args...; kwargs...) |> markdown_latex |> Markdown.parse
end
function _to_md(m::Tuple, args...; kwargs...)
    as = [Mustache.render.(mi, args...; kwargs...) for mi ∈ m]
    join(as, " ") |> markdown_latex |> Markdown.parse
end

_to_md(m::List, args...; kwargs...) =
    _to_md(join(string.(m.x), ", "), args...; kwargs...)
function _to_md(m::Interval, args...; kwargs...)
    str = "[$(m.a), $(m.b)]"
    _to_md(str, args...; kwargs...)
end
function _to_md(m::Formula, args...; kwargs...)
    str = repr(m)
    _to_md(str, args...; kwargs...)
end

function markdown_latex(r)
    replace(r,
            raw"$ATSYMS" => "@syms",
            raw"\[" => raw"```math",
            raw"\]" => raw"```",
            raw"\(" => raw"``",
            raw"\)" => raw"``")
end



sample(r) = r[rand(eachindex(r))]
Sample(r) = sample.(r)
function Sample(r::Randomizer)
    seed = r.id
    rng = Random.MersenneTwister(seed)
    [v[rand(rng, eachindex(v))] for v in r.vars]
end
# need show methods for each of the question types
export question_html


function question_html(r::AbstractQ)
    q = _to_md(r.question) # question
    a = _to_md(r.answer)   # answer
    o = nothing            # where to put answer

    (; q, a, o)
end

function question_html(r::RadioQ)
    q = _to_md(r.question)
    a = _to_md(r.answer)
    o = _to_md.(r.choices)

    (; q,o,a)
end

function question_html(r::MultiChoiceQ)
    q = _to_md(r.question)
    a = _to_md.(join(string.(r.answer), ", "))
    o = _to_md.(r.choices)

    (; q,o,a)
end

_blank_ = "____"
function question_html(r::FixedRandomQ)
    q = _to_md(r.question)
    a = _to_md(r.answer)
    o =  _blank_

    (; q, a, o)
end

function question_html(r::Union{RandomQ, StringQ})
    d = Dict()
    vars = Sample(r.vars)
    for (i,v) ∈ enumerate(vars)
        d[Symbol("a$i")] = v
    end
    q = _to_md(r.question, d)
    a = _to_md(r.fn(vars...))
    o = _blank_

    (; q, a, o)
end

function question_html(r::Union{TextQ,EssayQ})
    q = _to_md(r.question)
    a = nothing
    o = nothing

    (; q,o,a)
end


function question_html(r::KnowlLink)
    q =  _to_md((r.alt,r.txt)) # XXX incorporate alt
    a = o = nothing
    (;q,a,o)
end

function question_html(r::JSXGraph)
    domid = randstring(10)
    q = Markdown.parse("~~jsxgraph goes here~~")
    a = o = nothing
    (;q,a,o)
end

function question_html(r::Randomizer)
    q = a = o = nothing
    (;q,a,o)
end

# cf. https://www.oxygenxml.com/doc/versions/27.1/ug-editor/topics/dg-target-counter-function.html
# for bodymatter (which isn't working!)
quarto_header = raw"""
```{=html}
<style>
  .blurred-text {
  filter: blur(5px); /* Adjust blur amount as needed */
  transition: filter 0.3s ease; /* Smooth transition */
}

.blurred-text.unblurred {
  filter: none;
}
.bodymatter a::after { content: leader('.') target-counter(attr(href), page, decimal) }
</style>

      <script id="MathJax-script" async
          src="https://cdn.jsdelivr.net/npm/mathjax@3.0.1/es5/tex-mml-chtml.js">
      </script>
      <script>
	MathJax = {
         loader: {load: ['[tex]/ams']},
        tex: {
          packages: {'[+]': ['ams']}
          inlineMath: [ ['$','$'], ['\\(','\\)'] ],
          displayMath: [ ['$$','$$'], ['\\\[','\\\]'] ]
        }}
      </script>
```
"""

"""
    htmlpreview(fname::String; blur::Bool=true)
    htmlpreview(fs; blur::Bool=true)

Preview the script in HTML.

* `fname`: name of script to generate `pg` files. Assumes the resulting `Page` object is named `p`.
* `fs`: create html file over all filenames created by iterating over `fs`
* `blur`: blur the answers until clicked on

This is useful to identfy errors, though the resulting `pg` files must also be checked for rendering issues.

The trip to HTML is a bit hacky; any oddities should be reported as bugs.
"""
function htmlpreview(fname::String; blur::Bool=false)
    cur_anon = Module()
    Base.include(cur_anon, fname)
    isa(cur_anon.p, Page) || throw(ArgumentError("use `p` for a Page object"))
    f = tempname()
    qmd = f * ".qmd"
    html = f * ".html"
    open(qmd, "w") do io
        Base.invokelatest(_preview_page,
                          io, cur_anon.p;
                          title = basename(fname),
                          header=true,
                          blur=blur)
    end
    quarto() do bin
        run(`$bin render $qmd`)
        run(`open $html`)
    end
    1
end

function print_toc(io::IO, fs)
    ## toc
    println(io, """
<nav>
  <ol>
""")
        for f ∈ fs
            f′ = basename(f)
            f′′ = normalize(f′)
            cur_anon = Module()
            Base.include(cur_anon, f)
            isa(cur_anon.p, Page) || continue
            # get header from intro
            u = Markdown.parse(Mustache.render(cur_anon.p.intro))
            hs = filter(x -> isa(x, Markdown.Header), u.content)
            h = first(hs)
            header = Markdown.plain(h)[3:end]


            println(io,  """
<li class="bodymatter"><a href="#$(f′′)">$(f′): $header</a></li>
""")
        end
        println(io, """
  </ol>
</nav>\n
""")
end
normalize(f) = f[4:end]
function insert_pagebreak(io)
            println(io, """
```{=html}
<p style="page-break-after: always;">&nbsp;</p>
```
""")
end


function htmlpreview(fs; blur::Bool=false, toc=true)
    qmd, html = tempname() .* (".qmd", ".html")

    open(qmd, "w") do io
        println(io, quarto_header)
        if toc
            print_toc(io, fs)
            insert_pagebreak(io)
        end


        for f ∈ fs
            cur_anon = Module()
            Base.include(cur_anon, f)
            isa(cur_anon.p, Page) || continue
            Base.invokelatest(_preview_page,
                              io, cur_anon.p;
                              title = basename(f),
                              header=false,
                              blur=blur)
            insert_pagebreak(io)
        end
    end

    quarto() do bin
        run(`$bin render $qmd`)
        run(`open $html`)
    end
    1
end



# write page to io using html
# pass header and title
function _preview_page(io::IO, p::Page;
                       title::String="",
                       header::Bool=true,
                       blur::Bool=false)
    intro = Mustache.render(p.intro)
    intro = replace(intro,
                    raw"$ATSYMS" => "@syms",
                    raw"\[" => raw"```math",
                    raw"\]" => raw"```",
                    raw"\(" => raw"``",
                    raw"\)" => raw"``")
    intro = Markdown.parse(intro)

    header && println(io, quarto_header)
    !isempty(title) && println(io, "# ", title, "\n")

    println(io, """::: {.callout-note appearance="minimal"}\n""")
    println(io, intro, "\n")
    println(io, """:::\n""")

    for r ∈ p.questions.qs
        o = question_html(r)

        !isnothing(o.q) && println(io, o.q, "\n")
        if !isnothing(o.o)
            if o.o == _blank_
                println(io, """[---------------------]{width="2cm"}""", "\n")
            else
                for u in o.o
                    print(io, "□ ")
                    println(io, u, "\n")
                end
            end
        end
        if !isnothing(o.a)
            println(io, "Answer:")
            if blur
                println(io, "[",o.a,"""]{class='blurred-text' onclick="(function(el){el.classList.add('unblurred')})(this)"}""", "\n")
            else
                println(io, o.a, "\n")
            end
        end
    end
end
