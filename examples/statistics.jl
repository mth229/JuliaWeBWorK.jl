using JuliaWeBWorK

qs = JuliaWeBWorK.QUESTIONS()
## --------------------------------------------------

meta=(Project="Some sample statistics questions",
     Question="3"
      )

intro = jmt"""

Here are two sample   statistics questions.

"""

## --------------------------------------------------

# need raw, dollar sign
numericq(raw"""

### Problem 1

From the  following `R`  output, what is a  95% confidence interval?


```
t.test(Data$Steps, conf.level=0.95)


One Sample t-test

95 percent confidence interval:
 7171.667 8212.949

mean of x
 7692.308
```
""",
         () -> begin
         List([Interval(7171.667, 8212.949)])
         end,
         ()
         ) |> qs

## --------------------------------------------------

r = randomizer(20:25) |> qs

numericq(raw"""

### Problem 2

Output from an  `R` command is

```
    One Sample t-test
data:  my_data$weight
t = -9.0783, df = 9, p-value = 7.953e-06
alternative hypothesis: true mean is not equal to {{:a1}}
95 percent confidence interval:
 17.8172 20.6828
sample estimates:
mean of x 
    19.25 
```

(a) What is the observed value of the statistic?
""",
         (μ) ->  -9.0783,
         r) |> qs

numericq(jmt"""

(b) What was the sample  size?
""",
         (μ) -> 9 + 1,
         r) |> qs

numericq(jmt"""

(c)  Using  the fact that

```math
t = \frac{\bar{x} - \mu}{SE},
```

Find \( SE \).
""",
         (μ) -> begin
         t, x̄ = -9.0783, 19.25
         (x̄ -μ)/t
         end,
         r) |> qs

## --------------------------------------------------
p  =  Page(intro, qs; context="Interval",  meta...)
                

