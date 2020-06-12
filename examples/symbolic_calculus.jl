using JuliaWeBWorK
using SymPy

## --------------------------------------------------

meta=(Project="Some sample calculus questions",
     Question="3"
      )

intro = raw"""

[Details for students](https://webwork.maa.org/wiki/Student_Information)

----

# Sample test

Justify answers and show all work for full credit. No graphing calculators. No internet.

(Wait, that is **joke**).

"""

## --------------------------------------------------

q1_question = raw"""
# Problem 1
Let \[
 f(x) = \frac{4}{5} x^5 + 2x^4 - 20x^3 +  9
\]

(a) Find the critical points of  \(f(x)\)
"""

function q1_answer()
    @vars x
    ex = 4//5 * x^5 + 2x^4  -  20x^3 + 9
    cps = solve(diff(ex,x))
    List(cps) 
end

q1 = numericq(q1_question, q1_answer, ())


## --------------------------------------------------

q2_question = raw"""
(b) Specify all intervals where \(f(x)\) is *increasing*.
"""
function q2_answer()
    @vars x
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
end

q2 = numericq(q2_question, q2_answer,  ())

## --------------------------------------------------

q3_question = "(c) For which critical points does the first derivative change sign from positive to negative?"

function q3_answer()
    @vars x
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
end

q3 =  numericq(q3_question,   q3_answer, ())

## --------------------------------------------------

q4a_question  = raw"""
# Problem 2
Let \[
f(x) = x^4 -  12x^2  + {{:a1}}
\]

(a) Find the critical points  of.
"""

function q4_helper(a)
    @vars x
    ex = x^4 - 12x^2 + a
    dp = diff(ex,x)
    dpp = diff(ex,(x,2))
    cps =  (sort∘solve)(dp)
    ips =  (sort∘solve)(dpp)
    (ex, cps, ips)
end
       
function q4a_answer(a)
    ex,cps,ips = q4_helper(a)
    List(cps)
end

## --------------------------------------------------

q4b_question  = raw"""
(b) Find  the inflection points of  \(f(x)\).
"""

function q4b_answer(a)
    ex,cps,ips = q4_helper(a)
    List(ips)
end

## --------------------------------------------------

q4c_question =  raw"""
(c) Find the intervals where  \( f(x) \)   is concave  down
"""

function q4c_answer(a)
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
end

## --------------------------------------------------

q4d_question = raw"""
(d) Which critical points have a negative second derivative?
"""

function  q4d_answer(a)
    ex,cps,ips = q4_helper(a)
    x = free_symbols(ex)[1]
    xs =  []
    for c  in  cps
        diff(ex,(x,2))(c) < 0 && push!(xs,  c)
    end
    List(xs)
end


q4 =  multinumericq((q4a_question,  q4b_question, q4c_question, q4d_question),
                           (q4a_answer,  q4b_answer, q4c_answer, q4d_answer),
                           (8:15,))
                           
                           
##
## --------------------------------------------------
##
p  =  Page(intro, (q1,q2, q3, q4); context="Interval", meta...)  #  Interval here  is needed
                

