using JuliaWeBWorK

using SymPy # useful for formula
using Plots # for plotq

meta=(AuthorText="JuliaWeBWorK",
      Keywords="Kitchen sink, everything but",
      Question="1"
      )


qs = JuliaWeBWorK.QUESTIONS()

# text formatting example
intro = raw"""

[WeBWorK](https://webwork.maa.org/)


----


A *silly* example of the different questions that can readily be asked.

"""


# Randomized questions

## numeric

###  No randomization
numericq("Enter 1", ()->1, ()) |> qs
numericq("Enter 1, 2", () -> List((1,2)), ()) |> qs
numericq(raw"Enter \([\sin(x)]'\)", () ->  (@vars  x; Formula(diff(sin(x),x))), ()) |> qs
numericq(raw"Enter the interval \(  (1,2) \)", () -> Interval(1,2),  ()) |> qs
numericq(raw"Enter the intervals \(  (1,2) \) and  \( (3,4)  \)", () -> List(Interval(1,2), Interval(3,4)),  ()) |> qs

p = plot(x->x^5 -x -1, -1, 1.5, legend=false)
plot!(p, zero)
numericq("How many  zeros in the plot: ![plot]($(Plot(p)))", () -> 1,()) |> qs

## randomization per problem
numericq("Enter `2*{{:a1}}`", (a) -> 2a, (1:3, )) |> qs
numericq("Enter  `{{:a1}}`, `{{:a2}}`", (a,b) ->  List(a,b),  (1:3, 1:3)) |> qs
numericq(raw"Enter \([\sin({{:a1}}x)]'\)", (a) ->  (@vars  x; Formula(diff(sin(a*x),x))), (2:3,)) |> qs
numericq(raw"Enter  the interval \( ({{:a1}}, {{:a2}}) \)", (a,b) ->  Interval(a,b),  (1:3, 4:6)) |> qs
numericq(raw"Enter  the intervals \( ({{:a1}}, {{:a2}}) \) and \( ({{:a3}}, {{:a4}}) \)",
               (a,b,c,d) ->  List(Interval(a,b),  Interval(c,d)),  (1:3, 4:6, 1:2, 3:4)) |> qs
stringq("Spell out {{:a1}}", (a) -> ("one", "two", "three")[a], (1:3, )) |> qs


## Shared randomization
r = randomizer(2:3)
numericq("Enter `2*{{:a1}}`", (a) -> 2a,r) |> qs
numericq(raw"Enter \([\sin({{:a1}}x)]'\)", (a) ->  (@vars  x; Formula(diff(sin(a*x),x))), r) |> qs
function n36_fn(a)
    p = plot(x->x^5 - x - (1+1/a), -1, 1.5)
    plot!(p,zero)
    Plot(p)
end
plotq(raw"Plot of \(f \)", n36_fn, r) |> qs
numericq(raw"How many zeros does the graph ofa \( f\) show?", (a) -> 1, r) |> qs
stringq("Spell out {{:a1}}", (a) -> ("one", "two", "three")[a], r) |> qs

# choice questions
radioq("Select 1", (("one",  jmt"two", "three"), "not available"), 1) |> qs
multiplechoiceq("Select all  bigger than 2", ((1,2,5,6),(7,8, jmt"0")), (3,4,5,6)) |> qs

# output only
stringq("Who is your father?", (a) -> "Darth Vader", (1:1,)) |> qs  # string q needs some randomization
hint("Use  the force  Luke") |> qs

essay = essayq("""
How  was this exercise?
""") |> qs

# create  Page object
page = Page(intro, qs; meta...)

# create pg file
# open("filename",  "w")  do  io
#     print(io, page)
# end
