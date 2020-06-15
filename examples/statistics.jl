using JuliaWeBWorK

## --------------------------------------------------

meta=(Project="Some sample statistics questions",
     Question="3"
      )

intro = raw"""

Here are two sample   statistics questions.

"""

## --------------------------------------------------

q1_question = raw"""

### Problem 1

From the  following ``R``  output, what is a  95% confidence interval?


```
t.test(Data$Steps, conf.level=0.95)


One Sample t-test

95 percent confidence interval:
 7171.667 8212.949

mean of x
 7692.308
```
"""


q1_answer = () -> List([Interval(7171.667, 8212.949)])

q1 = numericq(q1_question, q1_answer, ())

## --------------------------------------------------

q2r = randomizer(20:25)

q2a_question = raw"""

### Problem 2

Output from an  ``R`` command is

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
"""

q2a_answer =  (μ) -> -9.0783

q2b_question  = raw"""

(b) What was the sample  size?
"""

q2b_answer = (μ) -> 9 + 1

q2c_question = raw"""

(c)  Using  the fact that
\[
t = \frac{\bar{x} - \mu}{SE},
\]

Find \( SE \).
"""

function q2c_answer(μ)
    t, x̄ = -9.0783, 19.25
    (x̄ -μ)/t
end


q2a =  numericq(q2a_question, q2a_answer, q2r)
q2b =  numericq(q2b_question, q2b_answer, q2r)
q2c =  numericq(q2c_question, q2c_answer, q2r)
q2 =   (r, q2a, q2b, q2c)

## --------------------------------------------------
p  =  Page(intro, (q1,q2...); context="Interval",  meta...)
                

