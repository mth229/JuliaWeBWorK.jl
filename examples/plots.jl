using JuliaWeBWorK
using Plots

## --------------------------------------------------

meta=(Project="Plotting  questions",
     Question="3"
      )

intro = raw"""

[Details for students](https://webwork.maa.org/wiki/Student_Information)

----

# This shows  how  fixed and randomized plots can be included; it also shows how to use [JSXGraph](https://jsxgraph.uni-bayreuth.de/) to create dynamic graphics (using JavaScript commands).

For randomized plots, as each  *possible*  plot is precomputed and serialized,  
this should not be  used  over large event spaces.

"""

## --------------------------------------------------

## fixed plot, using string interpolation (direct, but would require escaping some markup)
p = plot(sinpi, -1/2,  5/2)
plot!(p, zero, -1/2, 5/2)
q1 = """

![Figure]($(Plot(p)))

(1) In the figure above, what are the zeros of the function?
"""

numericq(q1, () -> List((0,1,2)), ())

## fixed plot with a template
q1a = mt"""
![Figure]({{{:plot}}})
"""
numericq(q1a(plot=Plot(p)), () -> 1, ())

## fixed plot for a filename using File
pngfile = tempname() * ".png"
savefig(p, pngfile)
q1b = mt"""
![Figure]({{{:plot}}})
"""
numericq(q1b(plot=File(pngfile)), ()->2, ())

## Randomized plot for students using the `plot` "question" type (in quotes
## as `plotq` only prings a randomized plot, the question comes after, hence
## the use of a `randomizer` to share the randomization.
r = randomizer(2:3)
q2 = plotq("Plot of periodic function", (a) -> Plot(plot(sin, 0,2a*pi)), r)
q3 = numericq("(2) How many periods of the periodic function are shown in the above figure?", (a)  -> a, r)
q4 = stringq("(3) Is this a `sine` or `cosine` function? (spell it out)",(a)->"sine", r)


## This show uses of the `MT"""` string macro and the  <<>> tag to insert plot
## Different tags are needed for the subsitution of the plot, and the next pass
## substitutes any variables `{{:a1}}`, `{{:a2}}`, ...
p = plot(sin, 0, 2pi)
q5q = MT"""
The plot of \( \sin(x) \) over \( [0, 2\pi] \) is produced by

```
plot(sin, 0, 2pi)
```

resulting in

![](<<{:plot}>>)

What is the value  of the function at \(x = \pi \)?
"""
q5 = numericq(q5q(plot=Plot(p)), ()->0, ())

## As an alternative to MT, the `jmt` string macro of `Mustache` first
## performs Julia's string interpolation before parsing into Mustache
## tokens:
q5q_alternative = jmt"""
The plot of \( \sin(x) \) over \( [0, 2\pi] \) is produced by

```
plot(sin, 0, 2pi)
```

resulting in

![]($(Plot(p)))

What is the value  of the function at \(x = {{:a1}} \)?
"""
q5a = numericq(q5q_alternative, (a)->sin(a), ((1,2,3),); tolerance=1e-1)

## This shows use of [jsxgraph](https://jsxgraph.uni-bayreuth.de/) graphics for
## interactive graphics. This is not as integrated into WeBWorK as GeoGebra, but
## are easy enough to author and quite illustrative.
q6 = jsxgraph("""
var brd = JXG.JSXGraph.initBoard('jxgbox', {boundingbox: [-10, 10, 10, -10]});
var a = brd.create('point', [-2, 1]);
var b = brd.create('point', [-4, -5]);
var c = brd.create('point', [3, -6]);
var d = brd.create('point', [2, 3]);
var p = brd.create('polygon', [a, b, c, d], {hasInnerPoints: true});
"""; domid="jxgbox")


p = Page(intro, (q1, r, q2, q3, q4, q5, q6); meta...)
