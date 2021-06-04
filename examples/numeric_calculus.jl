using JuliaWeBWorK
using  Roots

## --------------------------------------------------

meta=(AuthorText="JuliaWeBWorK",
      Keywords="numeric derivatives",
      Question="1"
      )

qs = JuliaWeBWorK.QUESTIONS()
letters = JuliaWeBWorK.letters()

intro = raw"""

**Derivatives**



"""

## --------------------------------------------------

numericq(jmt"""

### Problem $(letters())

Calculate the slope of the secant line of \( f(x)= {{:a1}} x^2 + {{:a2}} \) 
between \( ({{:a3}},f({{:a3}})) \) and \( ({{:a4}},f({{:a4}})) \).
""",
         (a₂,a₀,a,b) -> begin
         fn = x  ->  a₂*x^2 + a₀
         m  = (fn(a)-fn(b))/(a-b)
         m
         end,
         (2:4, 6:8, 2:4, 5:9)
         ) |> qs

## ----

numericq(raw"""

###  Problem $(letters())

For the function \( f(x)= {{:a1}} x^2 + {{:a2}} \) between 
\( ({{:a3}},f({{:a3}})) \) and \( ({{:a4}},f({{:a4}})) \),
plot the function and the secant line. 

Estimate from the graph the largest distance between the two
functions between {{:a3}} and {{:a4}}.
""",
         (a₂,a₀,a,b) -> 
         fn =  x  ->  a₂*x^2 + a₀
         ## could work harde rhere
         m  = (fn(a)-fn(b))/(a-b)
         M = maximum(abs, [fn(x) - (a +  m*(x-a)) for  x ∈ range(min(a,b),  max(a,b), length=100)])
         M
         end,
         (2:4, 6:8, 2:4, 5:9),
         tolerance=5.0
         ) |> qs

## --------------------------------------------------


p  =  Page(intro, qs; meta...)
                

