
## Page("SOme blurb",  (q1,q2,q3, ...);
#DBSubject="Calculus",
#KEYWORDS="limits",
#AuthorText="John  Verzani"
#AuthorText2="Joseph Maher"
#)
raw"""
    Page(intro::AbstractString, questions; context="",  meta...)


Create a page  which prints as a `pg`  file.

* `intro` may be marked  up with  in modified markdown 
* `questions` is a tuple of questions
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


Example:

```
using JuliaWeBWorK
meta=(AuthorText="Julia", Institution="JuliaAcademy", Question="1")
intro  = raw"# Problem 1"
q1 = numericq(raw"What is  \({{:a1}} + {{:a2}}\)?",  (x,y)->x+y,  (1:5, 1:5))
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


function Base.show(io::IO, p::Page)

    for (k,v) in p.meta_information
        println(io, "## $k('$v')")
    end
        
    
    println(io, raw"""
DOCUMENT();

loadMacros("PG.pl","PGbasicmacros.pl","PGanswermacros.pl");
loadMacros("PGstandard.pl");
loadMacros("MathObjects.pl");
loadMacros("Parser.pl");
loadMacros("AnswerFormatHelp.pl");
loadMacros("parserRadioButtons.pl");
loadMacros("PGchoicemacros.pl");
loadMacros("PGessaymacros.pl");
##loadMacros("PGML.pl");
##loadMacros("PGcourse.pl");

Context()->{format}{number} = "%.16g";
Context()->variables->add(y=>'Real', z=>'Real', t=>'Real', u=>'Real', m=>'Real', n=>'Real');
Context()->flags->set(ignoreEndpointTypes=> 1);

my %seen;  # hat tip to https://perlmaven.com/unique-values-in-an-array-in-perl;  filter Context->strings->add
$seen{"yes"} = 1; $seen{"no"}=1;$seen{"true"} = 1; $seen{"false"}=1;
Context()->strings->add(qq(yes)=>{},qq(no)=>{},qq(true)=>{},qq(false)=>{});
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
EOF
""")
    ## add in somee missing styles
    println(io,"""
\$BBLOCKQUOTE =  MODES(
HTML=>"<BlockQuote>",
TeX =>""
);

\$EBLOCKQUOTE  = MODES(
HTML=>"</BlockQuote>",
TeX=>""
);
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
    
    println(io, "BEGIN_TEXT\n")

    println(io, get(ENV, "BRANDING",  ""))
    
    intro = replace(p.intro, "\\" => "\\\\")
    print(io, escape_string(intro))
    ## show(io, "text/pg", Markdown.parse(intro))

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

   # println(io, "#***************************************** Solution: ")
   # println(io, "Context()->texStrings;")
   # println(io, "BEGIN_SOLUTION")

   #  println(io, "hi")
   # for q in  p.questions
   #     print(io,  show_solution(q))
   # end

   # println(io, "END_SOLUTION")

   println(io, "ENDDOCUMENT();")

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
export numbers_only
