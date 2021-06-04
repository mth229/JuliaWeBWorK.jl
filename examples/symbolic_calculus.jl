using JuliaWeBWorK
using SymPy

qs = JuliaWeBWorK.QUESTIONS()

## --------------------------------------------------

meta=(Project="Some sample calculus questions",
     Question="3"
      )

intro = jmt"""

[Details for students](https://webwork.maa.org/wiki/Student_Information)

----

# Sample test

Justify answers and show all work for full credit. No graphing calculators. No internet.

(Wait, that is **joke**).

"""

## --------------------------------------------------

numericq(jmt"""
# Problem 1
Let

```math
f(x) = \frac{4}{5} x^5 + 2x^4 - 20x^3 +  9
```

(a) Find the critical points of  ``f(x)``
""",
         () -> begin
         @syms x
         ex = 4//5 * x^5 + 2x^4  -  20x^3 + 9
         cps = solve(diff(ex,x))
         List(cps) 
         end,
         ()) |> qs


## --------------------------------------------------

numericq(jmt"""
(b) Specify all intervals where \(f(x)\) is *increasing*.
""",
         () -> begin
         @syms x
         ex = 4//5 * x^5 + 2x^4  -  20x^3 + 9
         dex = diff(ex,x)
         cps = sort(solve(dex))
         delta = minimum(diff(cps))/2
         l = -Inf
         Ints = []
         for  r in cps
         if dex(r-delta) > 0
         push!(Ints, Interval(l,r))
         end
         l = r
         end
         if dex(l+delta) > 0
         push!(Ints, Interval(l, Inf))
         end
         List(Ints)
         end,
         ()) |> qs


## --------------------------------------------------

numericq(jmt"""

(c) For which critical points does the first derivative change sign from positive to negative?"

""",
         () -> begin
         @syms x
         ex = 4//5 * x^5 + 2x^4  -  20x^3 + 9
         dex = diff(ex,x)
         cps = sort(solve(dex))
         delta = minimum(diff(cps))/2
         xs =  []
         for r in cps
         if (dex(r-delta) > 0) && (dex(r+delta) < 0)
         push!(xs, r)
         end
         end
         List(xs)
         end,
         ()) |> qs

## --------------------------------------------------

r  = randomizer(8:15) |> qs
function q4_helper(a)
    @vars x
    ex = x^4 - 12x^2 + a
    dp = diff(ex,x)
    dpp = diff(ex,(x,2))
    cps =  (sort∘solve)(dp)
    ips =  (sort∘solve)(dpp)
    (ex, cps, ips)
end

numericq(jmt"""

# Problem 2
Let 

```math
f(x) = x^4 -  12x^2  + {{:a1}}
```

(a) Find the critical points  of ``f(x)``.
""",
         (a) -> begin
         ex,cps,ips = q4_helper(a)
         List(cps)
         end,
         r) |> qs

numericq(jmt"""

(b) Find  the inflection points of  ``f(x)``.

""",
         (a) -> begin
         ex,cps,ips = q4_helper(a)
         List(ips)
         end,
         r) |> qs
         
numericq(jmt"""

(c) Find the intervals where  ``f(x)``  is concave  down.

""",
         (a) -> begin
         ex,cps,ips = q4_helper(a)
         x = free_symbols(ex)[1]
         dex = diff(ex,x)
         ddex = diff(ex,x,x)
         
         δ = minimum(diff(ips))/2
         Ints =  []
         l =  -Inf
         for r in ips
         if  ddex(r-δ) <  0
         push!(Ints, Interval(l,r))
         end
         l = r
         end
         if ddex(l + δ) < 0
         push!(Ints,  Interval(l,Inf))
         end
         List(Ints)
         end,
         r) |> qs

numericq(jmt"""

(d) Which critical points have a negative second derivative?

""",
         (a)  -> begin
         ex,cps,ips = q4_helper(a)
         x = free_symbols(ex)[1]
         xs =  []
         for c  in  cps
         diff(ex,(x,2))(c) < 0 && push!(xs,  c)
         end
         List(xs)
         end,
         r) |> qs

                           
                           
##
## --------------------------------------------------
##
p  =  Page(intro, qs; context="Interval", meta...)  #  Interval here  is needed
                

