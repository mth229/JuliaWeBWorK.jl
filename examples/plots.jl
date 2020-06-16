using JuliaWeBWorK
using Plots

## --------------------------------------------------

meta=(Project="Plotting  questions",
     Question="3"
      )

intro = raw"""

[Details for students](https://webwork.maa.org/wiki/Student_Information)

----

# This shows  how  fixed and randomized plots can be included.

As each  *possible*  plot is precomputed and serialized,  this should not be  used  over large event spaces.

"""

## --------------------------------------------------

## fixed plot
p = plot(sinpi, -1/2,  5/2)
plot!(p, zero)
q1 = numericq("""

![Figure]($(Plot(p)))

(1) In the figure above, what are the zeros of the function?
""", () -> List((0,1,2)), ())

## Randomized plot for students
r = randomizer(2:3)
q2 = plotq("Plot of periodic function", (a) -> Plot(plot(sin, 0,2a*pi)), r)
q3 = numericq("(2) How many periods of the periodic function are shown in the above figure?", (a)  -> a, r)
q4 = stringq("(3) Is this a ``sine`` or ``cosine`` function? (spell it out)",(a)->"sine", r)

Page(intro, (q1, r, q2, q3, q4); meta...)


                

