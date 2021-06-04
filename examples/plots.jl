using JuliaWeBWorK
using Plots

## --------------------------------------------------

meta=(Project="Plotting  questions",
     Question="3"
      )

qs = JuliaWeBWorK.QUESTIONS()

intro = jmt"""

[Details for students](https://webwork.maa.org/wiki/Student_Information)

----

# Including plots

This shows  how  fixed and randomized plots can be included; it also shows how to use [JSXGraph](https://jsxgraph.uni-bayreuth.de/) to create dynamic graphics (using JavaScript commands).

For randomized plots, as each  *possible*  plot is precomputed and serialized,  
this should not be  used  over large event spaces.

"""

## --------------------------------------------------

## fixed plot, using string interpolation
## This is the simplest and suggested way to include a plot
p = plot(sinpi, -1/2,  5/2)
plot!(p, zero, -1/2, 5/2)
numericq(jmt"""

# Include using `(Plot(p))`

![Figure]($(Plot(p)))

(1) In the figure above, what are the zeros of the function?
""",
         () -> List((0,1,2)),
         ()
         ) |> qs


## reading a plt in from a file, `pngfile`
## here we create `pngfile` and fill it with an image; this isn't generally needed
pngfile = tempname() * ".png" 
savefig(p, pngfile)

numericq(jmt"""

----
# Include file through `(File(pngfile))`

![Figure]($(File(pngfile)))

""",()->1,()) |> qs

## Reading a plot from a url
label(jmt"""

----
# Using Markdown to include from a url

![some image](https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/Tangent_to_a_curve.svg/200px-Tangent_to_a_curve.svg.png)
""") |> qs



## Randomized plot for students using the `plot` "question" type (in quotes
## as `plotq` only prings a randomized plot, the question comes after, hence
## the use of a `randomizer` to share the randomization.

r = randomizer(2:3) |> qs

label(jmt"""
----
# Randomized plots

Plot of a periodic function
""") |> qs

plotq("", (a) -> Plot(plot(sin, 0,2a*pi)), r) |> qs

numericq("(2) How many periods of the periodic function are shown in the above figure?", (a)  -> a, r) |> qs


## This shows use of [jsxgraph](https://jsxgraph.uni-bayreuth.de/) graphics for
## interactive graphics. This is not as integrated into WeBWorK as GeoGebra, but
## are easy enough to author and quite illustrative.
## To load from a file, the `JuliaWeBWorK.INCLUDE` is available to manage relative directories

label(jmt"""
----
# Using jsxgraph for interactive plots
""") |> qs

jsxgraph("""
var brd = JXG.JSXGraph.initBoard('jxgbox', {boundingbox: [-10, 10, 10, -10]});
var a = brd.create('point', [-2, 1]);
var b = brd.create('point', [-4, -5]);
var c = brd.create('point', [3, -6]);
var d = brd.create('point', [2, 3]);
var p = brd.create('polygon', [a, b, c, d], {hasInnerPoints: true});
"""; domid="jxgbox") |> qs




p = Page(intro, qs; meta...)
