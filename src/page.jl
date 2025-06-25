
## Page("SOme blurb",  (q1,q2,q3, ...);
#DBSubject="Calculus",
#KEYWORDS="limits",
#AuthorText="John  Verzani"
#AuthorText2="Joseph Maher"
#)
raw"""
    Page(intro, questions; context="",  meta...)


Create a page  which prints as a `pg`  file.

* `intro` may be marked  up using modified markdown
* `questions` is a tuple of questions or `QUESTIONS` object
* `context` optional value to create page context. Typical  usage: `context="Interval"`
* `answer_context`: Dictionary of context for all answers on the page, e.g
```
answer_context=Dict(:operators=>Dict(:undefine=>"'+','-','*','/','^'"),
                    :functions=>Dict(:disable=>"'All'"),
                    :constants=>Dict(:remove=>"\"e\"")
                   )
```
The context dictionary above, is aliased as `numbers_only`.

* `meta` for page meta data.

If `ENV["BRANDING"]` is set, it will be printed on each page generated.

Example:

```
using JuliaWeBWorK
meta=(AuthorText="Julia", Institution="JuliaAcademy", Question="1")
intro  = raw"# Problem 1"
q1 = numericq("What is  ``{{:a1}} + {{:a2}}``?",  (x,y)->x+y,  (1:5, 1:5))
p =  Page(intro, (q1,); meta...)
# open("mynew.pg","w") do io
#    print(io, p)
# end
```
"""
struct Page
    intro
    questions
    meta_information
    context
    answer_context
    function Page(intro, questions; context="",answer_context="", kwargs...)
        new(intro,  questions, Dict(kwargs...), context, answer_context)
    end
end

# utility function
function kv(io::IO, v,d, ops=[])
    if isa(d, Dict)
        if(v != nothing)
            push!(ops, v)
            for (vv, dd) in d
                kv(io, vv, dd, ops)
            end
        else
            for (kk,vv) in d
                kv(io, kk, vv)
            end
        end
    else
        println(io, """Context()->$(join(string.(ops), "->"))->$(v)($(d));\n""")
    end
end


"""
    numbers_only

Dictionary to pass to `answer_context` to turn off WeBWorK's simplification pass.
There is no means to turn this off per problem, only per page.
"""
numbers_only = Dict(:operators=>Dict(:undefine=>"'+','-','*','/','^'"),
                           :functions=>Dict(:disable=>"'All'"),
                           :constants=>Dict(:remove=>"\"e\"")
                           )

function Base.show(io::IO, p::Page)

    for (k,v) in p.meta_information
        println(io, "## $k('$v')")
    end


    println(io, raw"""
DOCUMENT();

loadMacros("PG.pl","PGbasicmacros.pl","PGanswermacros.pl");
loadMacros("PGstandard.pl");
loadMacros("PGcourse.pl");
loadMacros("MathObjects.pl");
loadMacros("Parser.pl");
loadMacros("AnswerFormatHelp.pl");
loadMacros("parserRadioButtons.pl");
loadMacros("PGchoicemacros.pl");
loadMacros("PGessaymacros.pl");
loadMacros("draggableSubsets.pl");
loadMacros("niceTables.pl");
##loadMacros("PGML.pl");
##loadMacros("PGcourse.pl");

Context()->{format}{number} = "%.16g";
Context()->variables->add(y=>'Real', z=>'Real', t=>'Real', u=>'Real', m=>'Real', n=>'Real');
Context()->flags->set(ignoreEndpointTypes=> 1);

my %seen;  # hat tip to https://perlmaven.com/unique-values-in-an-array-in-perl;  filter Context->strings->add
$seen{"yes"} = 1; $seen{"no"}=1;$seen{"true"} = 1; $seen{"false"}=1;
Context()->strings->add(qq(yes)=>{},qq(no)=>{},qq(true)=>{},qq(false)=>{});
$ATSYMS  = qw"@syms";

""")

    println(io, "TEXT(beginproblem());")

    ## add in space  for popup  (called  by imagelink)
    println(io, raw"""
HEADER_TEXT(<<EOF);
  <script type="text/javascript" language="javascript">
  <!-- //
  function windowpopup(url) {
     var opt = "height=625,width=600,location=no,menubar=no," +
              "status=no,resizable=yes,scrollbars=yes," +
              "toolbar=no,";

    window.open(url,'newwindow',opt).focus();
  }
  // -->
  </script>
""")

    ## print javascript headers, as needed
    for T in unique(typeof.(p.questions))
        print(io, javascript_headers(T))
    end

    println(io, raw"""
EOF
""")
    ## add in somee missing formatting styles
    println(io,"""
\$BBLOCKQUOTE =  MODES(
HTML=>"<BlockQuote>",
TeX =>""
);

\$EBLOCKQUOTE  = MODES(
HTML=>"</BlockQuote>",
TeX=>""
);

\$ADMONITION = MODES(
HTML=>"&#9734;&nbsp;",
TeX=>"\\(\\bigwhitestar)");
""")


    if length(p.context) > 0
        println(io,  "Context(\"$(p.context)\");")
    end

    println(io, "\n## ---------- create answer values ----------\n")
    for q  in p.questions
        print(io, create_answer(q))
        println(io, "")
    end

    println(io, "\n## ---------- show  questions  ----------\n")


    println(io, raw"""$branding_ = <<"END_BRANDING";""")
    println(io, get(ENV, "BRANDING",  ""))
    println(io, """END_BRANDING""")
    println(io, raw"""$branding = MODES(HTML=>$branding_, TeX=>"[nothing to see]");""")

    println(io, "BEGIN_TEXT\n")
    println(io, raw"""$branding""")

    #intro = replace(p.intro, "\\" => "\\\\") # had this, replaced with
    intro = Mustache.render(p.intro)
    print(io, escape_string(intro))

    println(io, "\n\n\$HR\$PAR\n")

    for q in  p.questions
        print(io,  show_question(q))
        println(io,"\$PAR\n")
    end

    println(io,  "END_TEXT")

    println(io, "\n## ---------- show  answers  ----------\n")

    ops = []
    if length(p.answer_context) > 0
        kv(io, nothing, p.answer_context)
    end

    for q in p.questions
        println(io, show_answer(q))
        println(io,"")
    end

    ## Solutions go at end (when added)
    soln_io = IOBuffer()
    for q in  p.questions
         print(soln_io,  show_solution(q))
    end
    solns = String(take!(soln_io))

    if length(solns) > 0

        println(io, "#***************************************** Solution: ")
        println(io, """
Context()->texStrings;
SOLUTION(EV3(<<"END_SOLUTION"));
""")
        println(io, escape_string(solns))

        println(io, """
END_SOLUTION
Context()->normalStrings;
""")
    end


   println(io, "ENDDOCUMENT();")

end

"""
    PAGE(SCRIPTNAME)

Write a page to a file name based on the value of `SCRIPTNAME`. Returns an anonymous function
which can be called repeatedly to write a page with a filename based on `SCRIPTNAME`.

This is designed to be used as `PAGE = JuliaWeBWorK.PAGE(@__FILE__)`. Then from one script file
several related `pg` files can be generated. This might be useful for authoring exams
where it is a good practice to have many separate problems and not one big one with many
parts.

```
using JuliaWeBWorK
PAGE = write_page(@__FILE__)

q = numericq(raw"What is \\({{:a1}} + {{:a2}}\\)?", (a,b) -> a+b, (1:4, 2:5))
PAGE("Addition", (q,))  # writes to SCRIPT_BASE_NAME-1.pg

q = numericq(raw"What is \\({{:a1}} - {{:a2}}\\)?", (a,b) -> a-b, (1:4, 2:5))
PAGE("subtraction", (q,))  # writes to SCRIPT_BASE_NAME-2.pg

q = numericq(raw"What is \\({{:a1}} * {{:a2}}\\)?", (a,b) -> a*b, (1:4, 2:5))
PAGE("multiplication", (q,))  # writes to SCRIPT_BASE_NAME-3.pg
```


"""
function PAGE(SCRIPTNAME)
    base_nm = replace(SCRIPTNAME, r".jl$" => "")
    ctr = Ref(1)
    # return an anonymous function for printing a page
    # to the numbered .pg file.
    (args...;kwargs...) -> begin
        fname = base_nm * "-$(ctr[]).pg"
        ctr[] += 1
        open(fname, "w") do io
            show(io, Page(args..., kwargs...))
        end
    end
end


### ------ CONVENIENCES ------------


# simple struct to hold questions
# * can be passed to `page`
# * the call method calls `push!(q, x)` so that questions can be piped into t
#   these objects, as in `numericq(...) |> qs`
struct Questions
    qs
end
QUESTIONS() = Questions(Any[])
Base.iterate(q::Questions) = iterate(q.qs)
Base.iterate(q::Questions, st) = iterate(q.qs, st)
Base.length(q::Questions) = length(q.qs)
Base.push!(q::Questions, x) = push!(q.qs, x)
## returning `x` allows use like `u = randomizer(...) |> qs`
(q::Questions)(x) = (push!(q, x); x)


## ----
"return iterator over the letters `(a)`, `(b)`, ... Calling function increments letters"
function LETTERS()
    letters = ["(a)", "(b)", "(c)", "(d)", "(e)", "(f)", "(g)", "(h)", "(i)", "(j)", "(k)", "(l)", "(m)", "(n)", "(o)", "(p)", "(q)", "(r)", "(s)", "(t)", "(u)", "(v)", "(w)", "(x)", "(y)", "(z)"]
    idx = Base.Ref(1)
    () -> begin
        idx[] = idx[] + 1
        letters[idx[]-1]
    end
end

### ------ HACKS ------------

## A total hack to print `@syms` in a block
## First \{\} are expanded, then $... and @... are substituted
## so we can't generalize through the \{...\} phase
ATSYMS = "\$ATSYMS"; export ATSYMS

# https://github.com/JuliaLang/julia/blob/master/stdlib/InteractiveUtils/src/clipboard.jl
function mac_clipboard(p)
    open(pipeline(`pbcopy`, stderr=stderr), "w") do io
        show(io, p)
    end
end
export mac_clipboard
