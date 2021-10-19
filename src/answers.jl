## Various question/answer  types
"""
   AbstractQ

A  question has atleast two part: a question (marked up in julia-flavored markdown) and an answer, which is typically randomized. In  WeBWorK, there are  tpyically 3 places in  the file where a question needs defintions:  in the preamble  the values are defined (written by `create_answer`);  between `BEGIN_TEXT` and `END_TEXT` the question is asked (written by `show_answer`); and the grading  area  (written by `show_answer).  Hints can be added through `hint`.

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

# add javascript code to header by type of question
# default is none
javascript_headers(::T) where {T} = ""

create_answer(r::Any) = ""#throw(ArgumentError("no default method"))

show_question(r::Any) = ""
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

show_answer(r::Any) = ""
function show_answer(r::AbstractQ)
    answer = "\$answer$(r.id)"
    Mustache.render(answer_tpl(r),  (id=r.id, answer=answer, answer_partial=answer_partial(r)))
end

function answer_tpl(r::AbstractQ)
"ANS( {{{:answer}}}->cmp( {{>:answer_partial}} ));"
end

answer_partial(r::AbstractQ) = ""

show_solution(r::Any) = ""



##
## --------------------------------------------------
##
## AbstractRandomizedQ

#  util

# get  quotes when needed
_show(x) = sprint(io->show(io, useinfinity(x)))
const parser = CommonMark.Parser()
enable!(parser, MathRule())
enable!(parser, AdmonitionRule())
#enable!(parser, TableRule())  # to0 hard to get going without just copying
#enable!(parser, DollarMathRule()) use \(\) and \[ \] not $$ and $$...$$


## XXX These should be deprecates XXX
## String macros for marking up question blocks or strings
## typically `raw`, `mt`, or `jmt` would be used
## but
## `L` will wrap results in display math if not already done. (Taken from LaTeXStrings package)
## `q` will wrap results in code backticks
## `MT` will parse a Mustache template using `<<`, `>>`
lstring(s)   =  (occursin("\\(", s) || occursin("\\[",s)) ? String(s) :  string(raw"\(", s, raw"\)")
macro L_str(s, flags...)  lstring(s) end
macro L_mstr(s, flags...) lstring(s) end
macro q_str(x)  "`$x`" end
"""
    MT

Use `<<...>>` or `<<{...}>>` for substitution before randomimization substitution. Useful for plots
"""
macro MT_str(s)
    Mustache.parse(s, ("<<", ">>"))
end




## --------------------------------------------------
function  useinfinity(a::T) where {T<:Number}
    if isinf(a)
        a = (a==Inf)  ?  "infinity" : "-infinity"
    end
    a
end
useinfinity(a) = a



raw"""
    escape_string(str, id, n=16)

Escape string does two things:

* replace parameters specified through `{{:a1}}`, `{{:a2}}`, ...,
  `{{:an}}` with the randomized value. When authoring be aware that if
  the next character after the closing braces can not be part of
  a *valid* variable name.

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
        v = "\\\$a"*string(i)*"aa"*id * "" #" " ## to space or not to space...
        params[k] = v
    end

    str = Mustache.render(str, params)
    str = replace(str, raw"\(" => "\\\\(")
    str = replace(str, raw"\)" => "\\\\)")
    str = replace(str, raw"\[" => "\\\\[")
    str = replace(str, raw"\]" => "\\\\]")
    str = replace(str, "\\\$a" => raw"$a")
    str = sprint(io->show(io, "text/pg", parser(str)))
    str
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
qs = JuliaWeBWorK.QUESTIONS()
r = randomizer(1:3) |> qs
q1 =  randomq("What is  ``2-{{:a1}}?``", (a) -> 2-a,  r) |> qs
q2 =  randomq("What is  ``3-{{:a1}}?``", (a) -> 3-a,  r) |> qs
Page("test", qs)
```
"""
function randomizer(args...; id=nothing)
    _id = id == nothing ? string(hash(args)) : id
    N = length(args)

    Randomizer(_id, args, N)
end

randomizer(r::Randomizer) = r

function create_answer(r::Randomizer)
    id, M = r.id, prod(length.(r.vars))
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
randomvals = (1:5,)
randomq(question,  answer, randomvals)
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
   List(...)

For List comparison, the function  should return answers  wrapped in  `List`; e.g. (`List(1,2,3)`).

Example
```
using SymPy
question = raw"What are the elements of  \( {1,2, {{:a1}}  } \)"
function  answer(a)
   List(1,2,a)
end
randomvals = (3:5,)
randomq(question,  answer, randomvals)
```
"""
struct List
    x
    List(v::Vector) = new(tuple(v...))
    List(args...) = List(args)
    List(ex::Tuple) = new(useinfinity.(ex))
end
Base.show(io::IO, l::List) = print(io, "List("  * join(_show.(l.x),  ", ") *  ")")


raw"""
    Interval(a,b)

Intervals have a < b, and are graded regardless of open or closed

Example
```
question = raw"On what  intervals is ``f(x)=(x+1) \cdot x \cdot (x-1)`` positive?"
answer() =  List([Interval(-1, 0), Interval(1,Inf)])
randomq(question, answer, ())
```
"""
struct Interval
    a
    b
    function  Interval(a,b)
        a, b = a < b ? (a,b) :  (b,a)
        a, b = useinfinity.((a,b))
        new(a,b)
    end
end
Base.show(io::IO, I::Interval) = print(io, "Interval($(I.a), $(I.b))")


## ----

"""
    Plot(p)

Convert plot  to `png`  object; run `Base64.base64encode`; wrap  for inclusion into `img` tag.

Works for `Plots`, and would work for other graphing backends with a
`show(io, MIME("text/png"), p)` method.
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

"""
    File(p)

 run `Base64.base64encode`; wrap  for inclusion into `img` tag.
"""
function File(nm)

    io = IOBuffer()
    for r ∈ read(nm)
        write(io, r)
    end
    data =  Base64.base64encode(take!(io))

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
        val = useinfinity(val)

        if isa(val, String)
            val = sprint(io->show(io, "text/plain",  val))
        end

        print(buf, val)
        print(buf, "]")
        M += 1
    end
    String(take!(buf)), M
end


function create_answer(r::AbstractRandomizedQ)
    N = length(r.vars)
    all_answers, M = make_values( r.vars, r.fn)

    # which randomizer do we use, a new one or recycled one?
    if (r.vars isa Randomizer)
        randomizer= "\$randomizer$(r.id) = \$randomizer$(r.vars.id);"
    else
        randomizer =  "\$randomizer$(r.id) = random(0,$M-1, 1);"
    end


    Mustache.render(create_answer_tpl(r), (id=r.id, answers=all_answers, randomizer=randomizer,
                                           MathObject=MathObject(r),
                                           create_answer_partial=create_answer_partial(r),
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


struct RandomQ <: AbstractRandomizedQ
    id
    vars
    fn
    question
    solution
    tolerance
    ordered
end



## randomq((a1=1:5,a2=[1,2,3]),     # a  tuple of n iterables
##          (a1) -> sin(a1),         # an n-ary function giving answer for a combination of values
##          "What  is sin({{:a1}})?",# a string. Use {{:ai}}  to  reference random parameters
##          "It is `sin({{:a1}})`.") # a string.

"""
    randomq(question, ans_fn, random;  solution,  tolerance=1e-4,  ordered=false)


Means to ask questions which are randomized within `Julia`. The basic
usage expects one or more numeric values as the answer. The answers
may be randomized by specifying random parameter values and an answer
function which returns the answer for the range of values specified by
the randomized parameters. Besides numeric values, the `Formula` type
can be used to specify an expresion for the answer; the `Interval`
type can be used to specify one or more intervals for an answer (all
intervals are assumed open).

The function `numericq` is an alias.

Arguments:

* `question` is a string processed through julia-flavored `Markdown`
   - LaTeX can be included: Use `\\(, \\)` for inline math and `\\[,\\]`
     for display math. Alternatively, enclosing values in double back
     ticks indicates inline LaTeX markup, and the math literal block syntax
     ("```math ... ```") can be used for display math.
   - use regular markdown for other markup. Eg, code, bold, italics, sectioning,
     lists.
   - The `jmt` string macro is helful to avoid escaping backslashes. It allows for string
     interpolation. Use `raw` if dollar signs have no meaning.
   - References to randomized variables are  through Mustache variables numbered
     sequentially  `{{:a1}}`, `{{:a2}}`, `{{:a3}}`, ... up to 16 (by default).

* `ans_fn`: the answer function is  an n-ary function of the  randomized parameters

* `random`: the random parameters are specified by 0,1,2,or more (up
to 16) iterable objects (e.g., `1:5` or `[1,2,3,5]`) combined in a
tuple (grouped with parentheses; use `(itr,)` if only 1 randomized
parameter). Alternatively, a [`randomizer`](@ref) object may be passed
allowing shared randomization amongst questions.

The collection of all possible outputs for the given random parameterizations are generated and `WeBWorK` selects an index from among them.

* tolerance is  an *absolute* tolerance, when the output is numeric.

* `ordered` is only for the case where the output is a list and you want an exact order

Examples

```
using SymPy, SpecialFunctions
# markdown
randomq("What is the *value*  of  `airy(pi)`?", () -> airyai(pi), ())
# latex via back ticks
randomq("What is ``{{:a1}} + {{:a2}}``?",  (a,b) -> a+b, (1:5, 1:5))
randomq("What is ``{{:a1}}*{{:a2}}+{{:a3}}``?",  (a,b,c) -> a*b+c, (1:5, 1:5,1:5))
# latex via \\(, \\)
randomq(raw"What is \\({{:a1}}\\cdot{{:a2}} + {{:a3}}\\)?",  (a,b,c) -> a*b+c, (1:5, 1:5,1:5))
randomq("Estimate from your graph the \\(x\\)-intercept.", ()-> 2.3, ();  tolerance=0.5)
## Dispaly math
randomq("What is \\[ \\infty  \\]?",  () ->  Inf, ())
randomq("What is \\( {1,2,{{:a1}} } \\)?",  (a) -> List(1,2,a), (3:6), ordered=true)
randomq("What is the derivative of  \\( \\sin(x) \\)?", () -> (@syms x;  Formula(diff(sin(x),x))),  ())
```

Plots may be included in different manners (see the example), but typically
include via the `Plot` function as follows:

```
using Plots
p = plot(sin, 0, 2pi);
plot!(zero);
q = randomq("![A Plot](\$(Plot(p))) This is a plot  of ``sin`` over what interval?", ()->Interval(0, 2pi),())
```

Plots may be randomized too.  See  [`Plot`](@ref), though they will not show in  a hard copy.


!! note "TODO"
   Should consolidate arguments  to  `cmp` (`tolerance`,   `ordered`)
   For `Interval` types,  may  need  to  set the context.

"""
function randomq(
    question,
    fn,
    vars=(); # tuple ##  Randomizer
    solution="",
    tolerance=1e-4,
    ordered=false # for the List type
)
    length(vars) == 0 && return fixed_randomq(fn, question, solution, tolerance, ordered)
    id = string(hash((vars, fn, question, solution)))
    RandomQ(id, vars, fn, question, solution, tolerance,ordered)
end

"""
    numericq

Alias for [`randomq`](@ref).
"""
const numericq=randomq


struct FixedRandomQ  <: AbstractRandomizedQ
    id
    question
    solution
    answer
    tolerance
    ordered
end

function  fixed_randomq(fn, question,  solution="",tolerance=(1e-4), ordered=false)

    id = string(hash((question, solution)))
    FixedRandomQ(id, question, solution, fn(),  tolerance,ordered)
end



function create_answer(r::FixedRandomQ)
    answer = useinfinity(r.answer)
    """
\$answer$(r.id) =  List($(answer));
"""
end

function  answer_partial(r::Union{RandomQ, FixedRandomQ})
    strict = r.ordered ? ", ordered=>'strict'" :  ""
""" tolerance=>$(r.tolerance), tolType=>"absolute"$strict"""
end

#function answer_tpl(r::Union{RandomQ, FixedRandomQ})
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

!!! Note:
    Using `yes/no` or `true/false` is common, so for these cases all 4 names are available, even if some do not appear in the collection of all possible outputs.

!!! Note:
    If the answers don't include all likely choices, then the student will not have the option
of choosing the distractors.... This is not so great.
"""
function stringq(question, fn, vars, solution="")
    #  no randomization and we  introduce a **fake one**
    if  length(vars) ==  0
        fn1 = (a)  ->  fn()
        vars = (1:1,)
    else
        fn1  = fn
    end

    id = string(hash((vars, fn1, question, solution)))
    StringQ(id, vars, fn1, question, solution)
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

"""
    yesnoq(question, yes::Bool, r=(), solution="")

A question with non-computed answer "yes" (yes=true) or "no" (yes=false)
"""
function yesnoq(qustion, yes::Bool, r=(), solution="")
    strinq(question, ()->"yes", r, solution)
end


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

# helpers with randomization
_eltype(x) = eltype(x)
_eltype(x::P)  where  {P <: AbstractString} =  P
_isiterable(::Mustache.MustacheTokens) = false
_isiterable(i) = _eltype(i) != typeof(i)
_flatten(xs) = reduce((a,b) -> vcat(a,_isiterable(b) ? collect(b) : b), xs, init=Any[])

# randomize choices, change inds to string answer
# choices is a collection. Each element which _isiterable  will be shuffled
function randomize(choices, inds)
    answers = Mustache.render.(_flatten(choices))[_isiterable(inds) ? collect(inds) : inds]
    out = String[]
    for choice ∈ choices
        if _isiterable(choice)
            σ = randperm(length(choice)) # shuffle
            append!(out, Mustache.render.(choice[σ]))
        else
            push!(out, Mustache.render(choice))
        end
    end
    out, answers
end



struct RadioQ <: AbstractChoiceQ
    id
    question
    answer
    choices
    solution

end

"""
    radioq(question, choices,  answer, [solution])

* choices. A collection of possible answers. These may be nested collections, in which case the second level is randomized
* answer. The index, within  the flattened choices, of  the answer  (1-based)

Examples

```
radioq("Pick \"three\"", ("one", "two","three"), 3)           # none randomized
radioq("Pick \"three\"", (("one", "two","three"),), 3)        # all randomized
radioq("Pick third", (("one", "two"),"three"),  3)            # "three" at end
radioq("Pick third", (("one","two"),  ("three",  "four")), 3) # randomized each pair
```


```
choices  =  ("one", "two","three")
radioq("Pick \"three\"", [choices], 3)
```

"""
function radioq(question,
                choices,
                answer::Int,
                solution=""
                )


    choices, answer = randomize(choices, answer)
    id = string(hash((question, choices, answer, solution)))


    RadioQ(id, question, answer, choices, solution)
end

function create_answer(r::RadioQ)
    buf = IOBuffer()
    id = "\$answer$(r.id)"

    fmt =  x -> """ "$(escape_string(string(x))[1:end-5])" """

    choices, answer = r.choices, r.answer


    println(buf, "$id = RadioButtons(")
    println(buf, "[")
    a,st = iterate(choices)
    print(buf, fmt(a))
    for a ∈ Iterators.rest(choices, st)
        print(buf, ",", fmt(a))
    end
    println(buf, "],")

    answer = fmt(answer)
    println(buf, answer)
    println(buf, ", noindex=>1")
    println(buf,");")

    String(take!(buf))
end


question_partial(r::RadioQ) = """
\\{ \$answer{{:id}}->buttons() \\}
"""

answer_partial(r::RadioQ) =  ""

##
##  --------------------------------------------------
##

struct MultiChoiceQ <: AbstractQ
    id
    question
    answer
    choices
    instruction
end

##  Choices is  ((random1,random2,  ...),  fixed) or just (random,random, ...random)
##  answer is a tuple  or  vector of indices
"""
     multiplechoiceq(question, choices, answer; [instruction])

* `choices` A collection of answers. An answer may be a collection, in which case it will be shuffled.

* `answer`: a tuple or vector  of indices of the  correct answers. The  indices refer  to the components stacked in random then fixed order.

Example:
```
multiplechoiceq("Select all three", (raw"\\(1\\)", "**two**", "3"), (1,2,3)) # not randomised
multiplechoiceq("Some question", (("one","two","three"),"four"), 4) # first three randomized
multiplechoiceq("Some question", (("one","two","three"),("four","five")), (4,5)) # randomized first three, last two
```
"""
function multiplechoiceq(question, choices, answer; instruction="Select one or more answers:")

    choices, correct = randomize(choices, answer)
    solution = ""
    id = string(hash((question, choices, answer, solution)))

    MultiChoiceQ(id, question, correct,  choices, instruction)
end

function create_answer(r::MultiChoiceQ)
    buf = IOBuffer()
    id = "\$answer$(r.id)"

    choices, answer = r.choices, r.answer

    fmt =  x -> """ "$(escape_string(string(x))[1:end-5])" """

    println(buf, "$id = new_checkbox_multiple_choice();")

    println(buf, """$id -> qa("$(r.instruction)", """)
    if _isiterable(answer)
        println(buf, join(fmt.(answer), ", "))
    else
        println(buf, fmt(answer))
    end
    println(buf,");")

    println(buf, """
$id -> makeLast(
""")
    println(buf, join(fmt.(choices),  ", "))
    println(buf,");")

    String(take!(buf))
end


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
hint(text, tag="hint...")  =  KnowlLink(Mustache.render(text), tag)

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

## ----

struct JSXGraph <: AbstractOutputQ
    id
    domid
    width
    height
    commands
end

javascript_headers(::Type{JSXGraph}) = """
<script src='//jsxgraph.org/distrib/jsxgraphcore.js' type='text/javascript'>
</script>
<script src='//jsxgraph.org/distrib/geonext.min.js' type='text/javascript'>
</script>
"""


"""
    jsxgraph(commands; domid="jxgbox", width=600, height=400)

Insert a graphic built using the [jsxgraph](https://jsxgraph.uni-bayreuth.de/wp/index.html) javascript library.

The javascript commands below have a DOM id passed to `initBoard` which is specified to `domid`,
with default of `jxgbox`. This would need adjusting were two or more graphs in the same page desired.

Example (https://jsxgraph.uni-bayreuth.de/wiki/index.php/Drag_Polygons):

```
q = jsxgraph(\"\"\"
var brd = JXG.JSXGraph.initBoard('jxgbox', {boundingbox: [-10, 10, 10, -10]});
var a = brd.create('point', [-2, 1]);
var b = brd.create('point', [-4, -5]);
var c = brd.create('point', [3, -6]);
var d = brd.create('point', [2, 3]);
var p = brd.create('polygon', [a, b, c, d], {hasInnerPoints: true});
\"\"\"; domid="jxgbox")

p = Page("Dragging polygons", (q,))
```

Most of the examples in the [jsxgraph wiki](https://jsxgraph.uni-bayreuth.de/wiki/index.php/Category:Examples) work
simply by copying the commands into a multi-line string, as in the example.

The site [jsfiddle.net](jsfiddle.net) allows for easy testing of js code.
"""
function jsxgraph(commands; domid="jxgbox", width=600, height=400)
    JSXGraph("jsxgraph_"*string(hash(label)), domid, width, height, commands)
end
export jsxgraph

# template for wrapping jsxgraph commands
const jsxgraph_tpl = mt"""
${{id}}_commands = <<"END_HTML";
{{{commands}}}
END_HTML

${{id}} = MODES(HTML=>"
<div id='{{domid}}' class='jxgbox' style='width:{{width}}px; height:{{height}}px'></div>
<script type='text/javascript'>
${{id}}_commands
</script>
",
TeX=> '[ You need to log into WeBWorK to see the graph for this problem ]',
);
"""

create_answer(jsxg::JSXGraph) = Mustache.render(jsxgraph_tpl, jsxg)

const jsxgraph_q_tpl = mt"""
$BR
${{id}}
$BR
"""
show_question(jsxf::JSXGraph, args...) = Mustache.render(jsxgraph_q_tpl, jsxf)


##
## --------------------------------------------------
##

"""
    INCLUDE(DIR)

Returns a function that will includes the *text* of a file found
relative to the specified directory (which would usually be
`@__DIR__`). Intended for use with `jsxgraph` to keeps JavaScript
files separate from `.jl` files.

```
INCLUDE = JuliaWeBWorK.INCLUDE(@__DIR__)
INCLUDE("fname.js")
```
"""
function INCLUDE(DIR)
    nm -> begin
        io = IOBuffer()
        fname = joinpath(DIR, nm)
        for l in readlines(fname)
            println(io, l)
        end
        String(take!(io))
    end
end

# add this so that we can render input
Mustache.render(x::Number) = string(x)
