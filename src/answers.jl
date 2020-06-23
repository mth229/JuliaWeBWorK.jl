## Various question/answer  types
"""
   AbstractQ

A  question has atleast two part: a question (marked up in modified markdown) and an answer, which is typically randomized. In  WeBWorK, there are  tpyically 3 places in  the file where a question needs defintions:  in the preamble  the values are defined (written by `create_answer`);  between `BEGIN_TEXT` and `END_TEXT` the question is asked (written by `show_answer`); and the grading  area  (written by `show_answer).  Not implemented (yet?) are the solutions.  Hints can be added through `hint`.

"""
abstract type AbstractQ end

"""
    AbstractRandomizedQ

A question where randomization is done  by creating an array of *all* possible values  for the sample space in `Julia` and having WeBWorK  select  one of the values. The [`randomizer`](ref) function can  be   used to share this random selection amongst questions.
"""
abstract type  AbstractRandomizedQ <: AbstractQ end

"""
    AbstractOutputQ

Type for output only things (Plots, hint, label ...)
"""
abstract type AbstractOutputQ <: AbstractQ end

"""
     AbstractChoiceQ

The  choices questions don't  readily lend themselves to fit  with  the `AbstractRandomizedQ` setup,  so the choice questions push
randomization on  to WeBWorK.
"""
abstract type AbstractChoiceQ <: AbstractQ end


# create_answer_tpl:  called by create_answer
# question_tpl: called by  show_question
# answer_tpl: called by  show_answer



create_answer(r::AbstractQ) = throw(ArgumentError("no default method"))

function show_question(r::AbstractQ)
    question = escape_string(r.question, r.id)
    answer = "\\\$answer$(r.id)"
    Mustache.render(question_tpl(r), (id=r.id,
                                      question=question,question_partial=question_partial(r),
                                      answer=answer))

end


#  default 
question_tpl(r::AbstractQ) =  """
{{{:question}}}
\$PAR
{{>:question_partial}}
"""
question_partial(r::AbstractQ) =  ""


function show_answer(r::AbstractQ)
    answer = "\$answer$(r.id)"
    Mustache.render(answer_tpl(r),  (id=r.id, answer=answer, answer_partial=answer_partial(r)))
end

function answer_tpl(r::AbstractQ)
"ANS( {{{:answer}}}->cmp( {{>:answer_partial}} ));"
end
    
answer_partial(r::AbstractQ) = ""

show_solution(r::AbstractQ) = ""



##
## --------------------------------------------------
##
## AbstractRandomizedQ
           
#  util

# get  quotes when needed
_show(x) = sprint(io->show(io, x))
const parser = CommonMark.Parser()

## L"", q"" macros to  wrap string  in latex (\(,\))  or quote(``).
lstring(s)   =  (occursin("\\(", s) || occursin("\\[",s)) ? String(s) :  string(raw"\(", s, raw"\)")
macro L_str(s, flags...)  lstring(s) end
macro L_mstr(s, flags...) lstring(s) end
macro q_str(x)  "`$x`" end







raw"""
    escape_string(str, id, n=16)

Escape string does two things:
* replace parameters specified through `{{:a1}}`, `{{:a2}}`, ..., `{{:an}}` with  the randomized value. 
* takes the markdown formatting in `str` and converts into "`text/pg`" format

The `id` is generated by the question.

Example
```
julia> str = "*x* = ``{{:a1}}``";

julia> escape_str(str, "ID")
"\$PAR\n\$BITALIC x \$EITALIC = \\(\\verb~\$a1aaID~\\)"
```
"""
function escape_string(str, id="XXXX",  n=16)
    params  =  Dict()
    for i in 1:n
        k = Symbol("a"*string(i))
        v = "\\\$a"*string(i)*"aa"*id*" "
        params[k] = v
    end
    
    str = Mustache.render(str, params)
    str = replace(str, raw"\(" => "\\\\(")
    str = replace(str, raw"\)" => "\\\\)")
    str = replace(str, raw"\[" => "\\\\[")
    str = replace(str, raw"\]" => "\\\\]")
    str = replace(str, "\\\$a" => raw"$a")
    sprint(io->show(io, "text/pg", parser(str)))
    
end

# function  escape_string(str, id="XXXXXXXXXXXXXXXXXX", n=16)
#     params  =  Dict()
#     for i in 1:n
#         k = Symbol("a"*string(i))
#         v = "\\\$a"*string(i)*"aa"*id*" "
#         params[k] = v
#     end

#     str = replace(str, "\\" => "\\\\")
#     str = Mustache.render(str, params)
#     sprint(io->show(io, "text/pg", Markdown.parse(str)))
    
# end


##
## --------------------------------------------------
##





## --------------------------------------------------
struct Randomizer
    id
    vars
    N
end

#  length  is number of iterators; use length(r.vars)  for  length  of  iterables  (M)
Base.length(r::Randomizer) = r.N

"""
    randomizer(vars...)

A  means to share the randomization across questions.

Example

```
r = randomizer(1:3)
q1 =  numericq("What is  ``2-{{:a1}}?``", (a) -> 2-a,  r)
q2 =  numericq("What is  ``3-{{:a1}}?``", (a) -> 3-a,  r)
Page("test", (r, q1, q2))
```
"""
function randomizer(args...; id=nothing)
    _id = id == nothing ? string(hash(args)) : id
    N = length(args)

    Randomizer(_id, args, N)
end

randomizer(r::Randomizer) = r

function create_answer(r::Randomizer)
    id, M = r.id, length(r.vars)
    """
\$randomizer$(id) = random(0,$M-1, 1);
"""
end
show_question(r::Randomizer) =  ""
show_answer(r::Randomizer) =  ""

Base.iterate(r::Randomizer) = Base.iterate(Base.Iterators.product(r.vars...))
Base.iterate(r::Randomizer, s) = Base.iterate(Base.Iterators.product(r.vars...),s)


##
## --------------------------------------------------
##

## Some output style mark up


raw"""
   Formula(ex)

For formula  answer, as in 
Example
```
using SymPy
question  = raw"What is  \( ( {{:a1}} x^2 )' \)"
function answer(a)  
  @vars x
  ex = a*x^2
  out = diff(ex,x)
  Formula(out)
end
randomizer = (1:5,)
numericq(question,  answer, randomizer)
```

!!! note 
    This likely has cases not handled well through just call `string(ex)`. If so, the output of the answer should be
    `"Fomula(\\"desired_expression\\")"`, as a string
 
"""
struct Formula
    ex
end
Base.show(io::IO, F::Formula) = print(io, "Formula(\""  * _show(F.ex) * "\")")

#Formula(ex) = "Formula(\"$(string(ex))\")"


raw"""
   List(tuple)

For List comparison, the function  should return answers  wrapped in  `List`; e.g. (`List(1,2,3)`).

Example
```
using SymPy
question = raw"What are the elements of  \( {1,2, {{:a1}}  } \)"
function  answer(a)
   List(1,2,a)
end
randomizer = (3:5,)
numericq(question,  answer, randomizer)
```
"""
struct List
    x
    List(ex::Tuple) = new(ex)
    List(v::Vector) = new(tuple(v...))
    List(args...) = new(args)
end
Base.show(io::IO, l::List) = print(io, "List("  * join(_show.(l.x),  ", ") *  ")")


raw"""
    Interval(a,b)

Intervals have a < b, and are graded regardless of open or closed

Example
```
question = raw"On what  intervals is \( f(x)=(x+1) ⋅ x ⋅ (x-1) \) positive?"
answer() =  List([Interval(-1, 0), Interval(1,Inf)])
numericq(question, answer, ())
```
"""
struct Interval
    a
    b
    Interval(a,b) = a < b ? new(a,b) : new(b,a)
end
Base.show(io::IO, I::Interval) = print(io, "Interval($(I.a), $(I.b))")

    



"""
    Plot(p)

Convert plot  to `png`  object; run `Base64.base64encode`; wrap  for inclusion into `img` tag.

Works for `Plots`, and would work for other graphing problems with a   `show(io, MIME("text/png"), p)` method.
"""
function Plot(p)
    io  = IOBuffer()
    show(io, MIME("image/png"), p)
    data = Base64.base64encode(take!(io))
    close(io)

    io = IOBuffer()
    print(io,"data:image/gif;base64,")
    print(io,data)
    String(take!(io))
end


##
## --------------------------------------------------
##

## AbstractRandomizeQ setup


"""
    MathObject(r)

What type of [MathObject](https://webwork.maa.org/wiki/Introduction_to_MathObjects) to create?  Defaults to "List", but "" (`PlotQ`) or "String"  (`StringQ`)  are useful.
"""
MathObject(r::AbstractRandomizedQ) = "List"


"""
    create_answer_partial

Ability to modify just  part of the `create_answer_tpl` for "AbstractRandomizedQ" for a  given type. (e.g., `StringQ`)
"""
create_answer_partial(r::AbstractRandomizedQ) = ""


create_answer_tpl(r::AbstractRandomizedQ) = """
@list{{:id}} = (
{{{:answers}}}
);

{{>:create_answer_partial}}

{{{:randomizer}}}
{{#:inds}}
\$a{{.}}aa{{:id}} = \$list{{:id}}[\$randomizer{{:id}}][{{.}}-1];
{{/:inds}}
\$answer{{:id}}= {{:MathObject}}(\$list{{:id}}[\$randomizer{{:id}}][{{:N}}]);

"""


## The key to using Julia with randomized questions is to *precompute* the
## answers for all the possible values. If the sample space is modest, this is not
## an onerous task. Here, we return a vector of arrays, with  strings escaped.
# map iterables,f into a "list" for precomputed  randomized answers
function make_values(vals, f; escape=false)
    buf = IOBuffer()
    M = 0
    first = true
    _vals =  isa(vals, Randomizer) ? vals : Base.Iterators.product(vals...)
    for xs  in _vals #
        if first
            first=false
        else
            println(buf, ",")
        end
        print(buf, "[" *  join(_show.(xs),", "))
        print(buf,  ", ")
        val = Base.invokelatest(f,xs...)

        if isa(val, String)
            val = "\"" * val *  "\""
        end
        print(buf, val)
        print(buf,  "]")
        M += 1
    end
    String(take!(buf)), M
end


function create_answer(r::AbstractRandomizedQ)
    N = length(r.vars)
    all_answers, M = make_values( r.vars, r.fn)

    # which randomizer do we use, a new one or recycled one?
    if (r.vars isa Randomizer)
        randomizer= "\$randomizer$(r.id) = \$randomizer$(r.id);"
    else
        randomizer =  "\$randomizer$(r.id) = random(0,$M-1, 1);"
    end

    
    Mustache.render(create_answer_tpl(r), (id=r.id, answers=all_answers, randomizer=randomizer,
                                           MathObject=MathObject(r), create_answer_partial=create_answer_partial(r),
                                           inds=1:N, ainds=1:1, N=N, M=M))
end


question_partial(r::AbstractRandomizedQ) =  """
\\{ ans_rule(60) \\}
"""



# question_tpl(r::AbstractRandomizedQ) =  """

# {{{:question}}}
# \$PAR
# \\{ ans_rule(60) \\}

# """

# function answer_tpl(r::AbstractRandomizedQ)
#     """
# ANS( {{{:answer}}}->cmp( {{{:cmp_partial}}} ));
# """
# end


##
## --------------------------------------------------
##


struct NumericQ <: AbstractRandomizedQ
    id
    vars
    fn
    question
    solution
    tolerance
    ordered
end



## numericq((a1=1:5,a2=[1,2,3]),     # a  tuple of n iterables
##          (a1) -> sin(a1),         # an n-ary function giving answer for a combination of values
##          "What  is sin({{:a1}})?",# a string. Use {{:ai}}  to  reference random parameters
##          "It is `sin({{:a1}})`.") # a string.

"""
    numericq(question, ans_fn, [random];  solution,  tolerance=1e-4,  ordered=false)

* question is a string processed through `Markdown` and may include LaTex where `\\( \\)`  and  `\\[  \\]` are
used for  inline math and display math. The `raw` string macro is useful to avoid  escaping  back slashes. In Markdown, inline  literals need *two* backtics, not *one*, as is standard.

References to randomized variables is  through  `{{:a1}}`, `{{:a2}}`, `{{:a3}}`,….

* The answer function is  an n-ary function of the  randomized parameters

* the  random parameters are specified  by  0,1,2,or 3  iterable objects (e.g. `1:5` or `[1,2,3,5]`) combined in a tuple (grouped
with parentheses; use  `(itr,)` if only 1 randomized parameter. Alternatiively, a  `ranodmizer` object may be passed allowing  shared randomization amongst questions.

* tolerance is  an *absolute* tolerance.

* `ordered` is only for the case where the output is a list and you want an exact order

Examples

```
using SymPy, SpecialFunctions
numericq("What is the value  of  `airy(pi)`?", () -> airyai(pi), ())
numericq("What is ``{{:a1}} + {{:a2}}``?",  (a,b) -> a+b, (1:5, 1:5))
numericq("What is ``{{:a1}}*{{:a2}}*{{:a3}}``?",  (a,b) -> a+b, (1:5, 1:5,1:5))  ## parses fine, as `` in Markdown is LaTeX
numericq("What is \\({{:a1}}⋅{{:a2}}⋅{{:a3}}\\)?",  (a,b) -> a+b, (1:5, 1:5,1:5)) ## note \\cdot, not *, unfortunate parsing o/w
numericq("Estimate from your graph the \\(x\\)-intercept.", ()-> 2.3, ();  tolerance=0.5)
numericq("What is \\( \\infty  \\)?",  () ->  Inf, ())
numericq("What is \\( {1,2,{{:a1}} } \\)?",  (a) -> List(1,2,a), (3:6), ordered=true)
numericq("What is the derivative of  \\( \\sin(x) \\)?", () -> (@vars x;  Formula(diff(sin(x),x))),  ())
```

Plots may be randomized too.  See  [`Plot`](@ref), though they will not show in  a hard copy.

```
using Plots
p = plot(sin, 0, 2pi);
plot!(zero);
q = numericq("![A Plot](\$(Plot(p))) This is a plot  of ``sin`` over what interval?", ()->Interval(0, 2pi),())
```

Or if `r` is a `randomizer`, 

```
numericq("A plot caption", (a) ->  Plot(plot(sin, 0,  a*2pi)), r)
```



!! note "TODO"
   Should consolidate arguments  to  `cmp` (`tolerance`,   `ordered`)
   For `Interval` types,  may  need  to  set the context.

"""
function numericq(
    question,
    fn,
    vars=(); # tuple ##  Randomizer
    solution="",
    tolerance=1e-4,
    ordered=false # for the List type
)
    length(vars) == 0 && return fixed_numericq(fn, question, solution, tolerance, ordered)
    id = string(hash((vars, fn, question, solution)))
    NumericQ(id, vars, fn, question, solution, tolerance,ordered)
end

struct FixedNumericQ  <: AbstractRandomizedQ
    id 
    question
    solution
    answer
    tolerance
    ordered
end

function  fixed_numericq(fn, question,  solution="",tolerance=(1e-4), ordered=false)
    
    id = string(hash((question, solution)))
    FixedNumericQ(id, question, solution, fn(),  tolerance,ordered)
end



create_answer(r::FixedNumericQ) = """
\$answer$(r.id) =  List($(r.answer));
"""

function  answer_partial(r::Union{NumericQ, FixedNumericQ})
    strict = r.ordered ? ", ordered=>'strict'" :  ""
""" tolerance=>$(r.tolerance), tolType=>"absolute"$strict"""
end

#function answer_tpl(r::Union{NumericQ, FixedNumericQ})
#    strict = r.ordered ? ", ordered=>'strict'" :  ""
#    """
#ANS( {{{:answer}}}->cmp(tolerance=>$(r.tolerance), tolType=>"absolute"  $strict ));
#"""
#end


##
## --------------------------------------------------
##

struct StringQ <: AbstractRandomizedQ
    id
    vars
    fn
    question
    solution
end
MathObject(r::StringQ) = "String"

"""
    stringq(question, answer, values)

Answer among limited set of strings. The strings available are all the possible outputs of `answer` (a function) over all possible values  in the sample space.

Examples:

```
q1 = stringq(raw"Is \\({{:a1}} > 0\\)? (yes/no)", (a) -> ("no","yes")[(a>0) + 1], (-3:3,))
q2 = stringq("Spell  out {{:a1}}", (a) -> ("one","two","three")[a], (1:3,))    
```
"""
function stringq(question, fn, vars, solution="")
    length(vars) == 0 && throw(ArgumentError("why?"))
    id = string(hash((vars, fn, question, solution)))
    StringQ(id, vars, fn, question, solution)
end

## Partial for create_answer_tpl
## add strings to context
create_answer_partial(r::StringQ) = """
\$N{{:id}} =  scalar @list{{:id}};
foreach (0 .. (\$N{{:id}}-1)) {
  \$value = \$list{{:id}}[\$_][{{:N}}];
  if (! \$seen{\$value}++ ) { 
    Context()->strings->add(qq(\$value)=>{});
  };
};
"""
    

##
##--------------------------------------------------
##

struct PlotQ <: AbstractRandomizedQ
    id
    vars
    fn
    question
end
MathObject(r::PlotQ) = ""

##  randomized plot
## fn should return Plot() call
function plotq(caption, fn, vars)
    length(vars) == 0 && throw(ArgumentError("Use ![]() syntax"))
    id = string(hash((caption,   fn, vars)))
    PlotQ(id, vars, fn, caption)
end


function show_question(r::PlotQ)
    caption  = escape_string(r.question, r.id)
    """
END_TEXT
\$image$(r.id) = MODES(
HTML=>qq(<figure><img src=\${answer$(r.id)}><figcaption>$(caption)</figcaption></figure>),
TeX=>qq([$(r.question)](image))
);
BEGIN_TEXT
\$image$(r.id)
"""
end

show_answer(r::PlotQ) = ""


##
## ------ Choice questions ---------------------
##

struct RadioQ <: AbstractChoiceQ
    id
    question
    answer
    choices
    fixed
    solution

end

"""
    radioq(question, choices,  answer, [solution])

* choices. Pass as a single iterable for  all randomized choices (e.g., `("one","two","three")`); or as a tuple with a lead iterable,  in which case the second element(s) will appear at the end of the list (e.g., `(("one","two","three"),"four")` or
   `(("one","two","three"),("four","five"))`
* answer. The index, within  the flattened choices, of  the answer  (1-based)

Examples

```
radioq("Pick \"three\"", ("one", "two","three"), 3)               # all randomize
radioq("Pick third", (("one", "two"),"three"),  3)            # "three" at end 
radioq("Pick third", (("one","two"),  ("three",  "four")), 3)  # "three", "four" at end
```

To specify that all are  ordered specify an iterable of length 1 containing an iterable:

```
choices  =  ("one", "two","three")
radioq("Pick \"three\"", [choices], 3)
```


!!! note
    Do to a quirk of parsing, the  answer as a value (not an index) should *not* be a number.
"""
function radioq(question,
                choices,
                answer::Int,
                solution=""
                )
    id = string(hash((question,  choices, answer, solution)))

    # check if all fixed ((values...))
    if _isiterable(choices[1])  && length(choices) ==  1
        choices =  [choices[1][1:1],  choices[1][2:end]]
    end
    
    
    if  _isiterable(choices[1]) # check for first element being iterable
        if _isiterable(choices[2])
            full = vcat(choices[1]...,  choices[2]...)
            fixed = choices[2]
        else
            full = vcat(choices[1]...,  choices[2])
            fixed = (choices[2],)
        end
        n = length(choices[1])
    else
        full = choices
        fixed = ()
        n = length(choices)
    end

    ans = full[answer]
    
    

    RadioQ(id, question, ans, full, fixed, solution)
end

function create_answer(r::RadioQ)
    buf = IOBuffer()
    id = "\$answer$(r.id)"
    
#    fmt  =  s-> escape_string(s)[6:end]
    fmt =  x -> """ "$(escape_string(string(x))[1:end-6])" """
    
    println(buf, "$id = RadioButtons(")
    println(buf, "[")
    #qs = [""" "$(escape_string(q)[6:end])" """ for q in r.choices]
    #qs = _show.(fmt.(r.choices))
    qs = fmt.(r.choices)
    println(buf, join(qs, ", " ))
    println(buf,"],")
    
    answer = fmt(r.answer) #""" "$(escape_string(r.answer)[6:end])" """
    println(buf, answer)
    println(buf,  ",")

    if !isempty(r.fixed)
        println(buf, "last => [")
        #qs = [""" "$(escape_string(q)[6:end])" """ for q in r.fixed]
        #qs = _show.(fmt.(r.fixed))
        qs = fmt.(r.fixed)        
        println(buf, join(qs, ", " ))
        println(buf,"],")
    end
    println(buf,");")

    String(take!(buf))
end

# create_answer_tpl(r::RadioQ) = """
# \$answer{{:id}} = RadioButtons(
# {{{:answers}}}, {{{:answer}}}); 
# """


question_partial(r::RadioQ) = """
\\{ \$answer{{:id}}->buttons() \\}
"""

# question_tpl(r::RadioQ,i=1) = """
# {{{:question}}}
# \$PAR
# \\{ \$radiobutton{{:id}}->buttons() \\}
# """

answer_partial(r::RadioQ) =  ""
#answer_tpl(r::RadioQ) = """
#ANS( \$radiobutton$(r.id)->cmp() );
#"""

# function create_answer(r::RadioQ)
#     isempty(r.random) && is.empty(r.fixed)  && throw(ArgumentError("need some choice"))

#     rands =  join(["\"" *  replace.(string(x), "\"" => "“") *  "\""  for x  in  r.random], ", ")
#     if r.randomize
#         rands  =   "[" *  rands *  "]"
#     end
        
#     fixs = "\"" *  replace(string(r.fixed), "\"" => "“")  * "\""
    

#     if  isempty(rands)
#         answers  = fixs
#     elseif isempty(r.fixed)
#         answers  =  rands
#     else
#         answers  =  "[" *  rands * ", " * fixs *  "]"
#     end

#     answer = r.ans -  1 # 0-based

#     Mustache.render(create_answer_tpl(r), (id=r.id, answers=answers, answer=answer))
# end



##
##  --------------------------------------------------
##

struct MultiChoiceQ <: AbstractQ
    id
    question
    correct
    extra
    fixed
    instruction
end

##  Choices is  ((random1,random2,  ...),  fixed) or just (random,random, ...random)
##  answer is a tuple  or  vector of indices
"""
     multiplechoiceq(question, choices, answer; [instruction])

* `choices` can have all randomized  choices (e.g. `("one","two","three")`); a single fixed non-randomized  choice (e.g., (`("one","two","three"), "four")`), or a list of non-randomized choices: (`("one","two","three"), ("four","five"))`). Tuples, vectors, or other iterables  can be used. For  a  fixed  order use a  single  iterable of choices: `[["one","two","three"]]`.

* `answer`: a tuple or vector  of indices of the  correct answers. The  indices refer  to the components stacked in random then fixed order.

Example:
```
multiplechoiceq("Select all three", (raw"\\(1\\)", "**two**", "3"), (1,2,3))
multiplechoiceq("Some question", (("one","two","three"),"four"), 4)
multiplechoiceq("Some question", (("one","two","three"),("four","five")), (4,5))
```
"""
function multiplechoiceq(question, choices, answer; instruction="Select one or more answers:")

    id  =  string(hash((question, choices,  answer)))

    # check if all fixed ((values...))
    if _isiterable(choices[1])  && length(choices) ==  1
        choices =  [choices[1][1:1],  choices[1][2:end]]
    end
    
    if  _isiterable(choices[1]) # check for first element being iterable
        if _isiterable(choices[2])
            full = vcat(choices[1]...,  choices[2]...)
            fixed = choices[2]
        else
            full = vcat(choices[1]...,  choices[2])
            fixed = (choices[2],)
        end
        n = length(choices[1])
    else
        full = choices
        fixed = ()
        n = length(choices)
    end
    correct  = full[[answer...]]
    extra = setdiff(full[1:n], correct)

    MultiChoiceQ(id, question, correct,  extra, fixed, instruction)
end
# helper to identify setup
_eltype(x) = eltype(x)
_eltype(x::P)  where  {P <: AbstractString} =  P
_isiterable(i) = _eltype(i) != typeof(i)

function create_answer(r::MultiChoiceQ)
    buf = IOBuffer()
    id = "\$answer$(r.id)"

    fmt =  x -> """ "$(escape_string(string(x))[1:end-6])" """
    
    println(buf, "$id = new_checkbox_multiple_choice();")


    println(buf, """$id -> qa("$(r.instruction)", """)
    println(buf, join(fmt.(r.correct),  ", "))
    println(buf,");")

    if !isempty(r.extra)
        println(buf, """
    $id -> extra(
    """)
        println(buf, join(fmt.(r.extra),  ", "))
        println(buf,");")
    end

    if  !isempty(r.fixed)
        println(buf, """
    $id -> makeLast(
    """)
        println(buf, join(fmt.(r.fixed),  ", "))
        println(buf,");")
    end

    String(take!(buf))
end

    
        


    
    
#     $mc = 
# $mc -> qa (
# "Select all expressions that are equivalent to  
# \( e^{x^2 + 1/x} \).  There may be more than
# one correct answer.", 
# "\( e^{x^2} e^{1/x} \)$BR",
# "\( e^{x^2} e^{x^{-1}} \)$BR",                
# "\( e^{ (x^3+1) / x } \)$BR",
# );
# $mc -> extra(
# "\( \displaystyle \frac{ e^{x^2} }{ e^x } \)$BR",
# "\( e^{x^2} + e^{1/x} \)$BR",
# );
# $mc -> makeLast("None of the above");


question_partial(r::MultiChoiceQ) = """
\\{ \$answer$(r.id) -> print_q() \\}
\$BR
\\{ \$answer$(r.id) -> print_a() \\}
"""


show_answer(r::MultiChoiceQ) =  """    
 ANS( checkbox_cmp( \$answer$(r.id)->correct_ans() ) );
"""



##
##  --------------------------------------------------
##

##
## ------------- Output only widgets ------------------------------
##


show_answer(r::AbstractOutputQ) = ""



##
##  --------------------------------------------------
##

struct EssayQ <: AbstractOutputQ
    id
    question
    width
    height
end

"""
    essayq(question; width=60, height=6)

WeBWorK allows for **one** essay question per page. These will be graded by the instructor.
"""
function essayq(question; width=60, height=6)
    EssayQ("1", question, width, height)
end

create_answer(r::EssayQ) = ""
question_partial(r::EssayQ) = """
\\{ essay_box($(r.height),$(r.width)) \\}
"""

# question_tpl(r::EssayQ)  = """
# \$PAR
# {{{:question}}}
# \$PAR
# \\{ essay_box($(r.height),$(r.width)) \\}
# """
show_answer(r::EssayQ) = """
ANS( essay_cmp() );
"""

## Output  widget


## --------------------------------------------------

struct TextQ  <: AbstractOutputQ
    id
    question
end

"""
    label(text)

Add text area to a  set or questions

Example
```
Click  [here](www.google.com)
```
"""
function label(label)
    id = string(hash(label))
    TextQ(id, label)
end

create_answer(r::TextQ) = ""

# show_question_tpl(r::TextQ, args...) = """
# {{{:question}}}
# """
#show_answer(r::TextQ) = ""
    

struct IFrameQ <: AbstractOutputQ
    id
    url
    width
    height
    alt
end

"""
    iframe(url, [alt]; [width], [height])

Embed the web page specified in `url` in the page.

Example (from https://webwork.maa.org/wiki/IframeEmbedding1)

```
r = iframe("https://docs.google.com/presentation/d/1pk0FxsamBuZsVh1WGGmHGEb5AlfC68KUlz7zRRIYAUg/embed#slide=id.i0";
    width=555, height=451)
```
"""
function iframe(url, alt="An embedded web page"; width=600, height=400)
    id = hash((url, alt, width,height))
    IFrameQ(id, url, width, height, alt)
end

create_answer_tpl(r::IFrameQ) = """
\$iframe{{:id}} = MODES(
HTML=> 
"<iframe src='$(r.url)'
frameborder='0' width='{{:width}}' height='{{:height}}'></iframe>", 
TeX =>
"{{:alt}}"
);
"""

function create_answer(r::IFrameQ)
    Mustache.render(create_answer_tpl(r), (id=r.id, width=r.width, height=r.height, alt=r.alt))
end

function show_question(r::IFrameQ, args...)
   """
\${BCENTER}
\$iframe$(r.id)
\${ECENTER}
"""
end

#show_answer(r::IFrameQ) = ""


##
## --------------------------------------------------
##


struct KnowlLink <: AbstractOutputQ
    txt
    alt
end

"""
    hint(text, tag="hint...")

Little inline popup.
[docs](https://webwork.maa.org/wiki/Knowls)
"""
hint(text, tag="hint...")  =  KnowlLink(text, tag)

create_answer(r::KnowlLink) = ""

function show_question(r::KnowlLink, args...)
    txt = replace(r.txt, "\\"=>"\\\\")
    txt = sprint(io -> show(io, "text/pg",  parser(txt))) #Markdown.parse(txt)))
    txt = replace(txt, "\\"=>"\\\\")
    """
\\{
knowlLink("$(r.alt)",
value=>escapeSolutionHTML(EV3P("$(txt)")), base64=>1);
\\}
"""
end
                 

##
## --------------------------------------------------
##



