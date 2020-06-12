using  Roots

## --------------------------------------------------

meta=(AuthorText="JuliaWeBWorK",
      Keywords="numeric derivatives",
      Question="1"
      )


intro = raw"""

**Derivatives**



"""

## --------------------------------------------------

q1_question  =  raw"""

### Problem 1

Calculate the slope of the secant line of \( f(x)= {{:a1}} x^2 + {{:a2}} \) 
between \( ({{:a3}},f({{:a3}})) \) and \( ({{:a4}},f({{:a4}})) \).
"""

function  q1_answer(a₂,a₀,a,b)
    fn = x  ->  a₂*x^2 + a₀
    m  = (fn(a)-fn(b))/(a-b)
    m
end

q1 = numericq(q1_question,  q1_answer, (2:4, 6:8, 2:4, 5:9))



q2_question = raw"""

###  Problem 2

For the function \( f(x)= {{:a1}} x^2 + {{:a2}} \) between 
\( ({{:a3}},f({{:a3}})) \) and \( ({{:a4}},f({{:a4}})) \),
plot the function and the secant line. 

Estimate from the graph the largest distance between the two
functions between {{:a3}} and {{:a4}}.
"""

function  q2_answer(a₂,a₀,a,b)
    fn =  x  ->  a₂*x^2 + a₀
    ## could work harde rhere
    m  = (fn(a)-fn(b))/(a-b)
    M = maximum(abs, [fn(x) - (a +  m*(x-a)) for  x ∈ range(min(a,b),  max(a,b), length=100)])
    M
end

q2 = numericq(q2_question,  q2_answer, (2:4, 6:8, 2:4, 5:9), tolerance=5.0)

q3 = numericq("(1,2,3)", () -> List((1,2,3)), ())
q4 = numericq("2", () -> 2, ())
q5 = numericq(raw"\(\pi\)", () -> float(pi), ())

##
## --------------------------------------------------
##

p  =  Page(intro, (q3,q4, q5); meta...)
                

