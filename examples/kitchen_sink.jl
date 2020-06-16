using JuliaWeBWorK

using SymPy # useful for formula
using Plots # for plotq

meta=(AuthorText="JuliaWeBWorK",
      Keywords="Kitchen sink, everything but",
      Question="1"
      )


# text formatting example
intro = raw"""

[WeBWorK](https://webwork.maa.org/)


----


A *silly* example of the different questions that can readily be asked.

"""


# Randomized questions

## numeric

###  No randomization
n11 = numericq("Enter 1", ()->1, ())
n12 = numericq("Enter 1, 2", () -> List((1,2)), ())
n13 = numericq(raw"Enter \([\sin(x)]'\)", () ->  (@vars  x; Formula(diff(sin(x),x))), ())
n14 = numericq(raw"Enter the interval \(  (1,2) \)", () -> Interval(1,2),  ())
n15 = numericq(raw"Enter the intervals \(  (1,2) \) and  \( (3,4)  \)", () -> List(Interval(1,2), Interval(3,4)),  ())

p = plot(x->x^5 -x -1, -1, 1.5, legend=false)
plot!(p, zero)
n16 =  numericq("How many  zeros in the plot: ![plot]($(Plot(p)))", () -> 1,());

n1s  = (n11, n12, n13,  n14, n15, n16)

## randomization per problem
n21 = numericq("Enter ``2*{{:a1}}``", (a) -> 2a, (1:3, ))
n22 = numericq("Enter  ``{{:a1}}``, ``{{:a2}}``", (a,b) ->  List(a,b),  (1:3, 1:3))
n23 = numericq(raw"Enter \([\sin({{:a1}}x)]'\)", (a) ->  (@vars  x; Formula(diff(sin(a*x),x))), (2:3,))
n24 = numericq(raw"Enter  the interval \( ({{:a1}}, {{:a2}}) \)", (a,b) ->  Interval(a,b),  (1:3, 4:6))
n25 = numericq(raw"Enter  the intervals \( ({{:a1}}, {{:a2}}) \) and \( ({{:a3}}, {{:a4}}) \)",
               (a,b,c,d) ->  List(Interval(a,b),  Interval(c,d)),  (1:3, 4:6, 1:2, 3:4))
n27 = stringq("Spell out {{:a1}}", (a) -> ("one", "two", "three")[a], (1:3, ))

n2s = (n21, n22, n23, n24, n25, n27)

## Shared randomization
r = randomizer(2:3)
n31 = numericq("Enter ``2*{{:a1}}``", (a) -> 2a,r)
n33 = numericq(raw"Enter \([\sin({{:a1}}x)]'\)", (a) ->  (@vars  x; Formula(diff(sin(a*x),x))), r)
function n36_fn(a)
    p = plot(x->x^5 - x - (1+1/a), -1, 1.5)
    plot!(p,zero)
    Plot(p)
end
n36p = plotq(raw"Plot of \(f\)", n36_fn, r)
n36 = numericq(raw"How many zeros does the graph \( f\) show?", (a) -> 1, r)
n37 = stringq("Spell out {{:a1}}", (a) -> ("one", "two", "three")[a], r)

n3s = (r,  n31, n33, n36p, n36,  n37)

# choice questions
c1 = radioq("Select 1", (("one",  "two", "three"), "not available"), 1)
c2 = multiplechoiceq("Select all  bigger than 2", ((1,2,5,6),(7,8)), (3,4,5,6))

cs = (c1, c2)

# output only
o1 = stringq("Who is your father?", (a) -> "Darth Vader", (1:1,))  # string q needs some randomization
o1h = hint("Use  the force  Luke")

os = (o1, o1h)

essay = essayq("""
How  was this exercise?
""")

# create  Page object
page = Page(intro, (n1s...,  n2s..., n3s..., cs..., os..., essay); meta...)

# create pg file
# open("filename",  "w")  do  io
#     print(io, page)
# end
