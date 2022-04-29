# JuliaWeBWorK.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://mth229.github.io/JuliaWeBWorK.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://mth229.github.io/JuliaWeBWorK.jl/dev)
[![Build Status](https://github.com/mth229/JuliaWeBWorK.jl/workflows/CI/badge.svg)](https://github.com/mth229/JuliaWeBWorK.jl/actions)



Author WeBWorK `pg` files using `Julia` scripts.


## Example

A `pg` page consists of an intro, one or more questions, and some meta data. This example shows a `pg` page with three questions.

```
using JuliaWeBWorK

# meta data
meta = (
KEYWORDS  = "Julia, WeBWorK",
DBChapter = "Sample questions",
DBSection = "section 1",
Section = "1",
Problem = "1"
)

qs = JuliaWeBWorK.QUESTIONS()     # convenient container for questions
letters = JuliaWeBWorK.LETTERS()  # convenience for incrementing questions

# jmt string macro allows string interpolation, Mustache interpolation
# we author in Markdown with latex for equations
# Latex uses ``inline`` or
# ```math
# displaymath
# ```

intro = jmt"""

# Some sample questions

"""

## ----

numericq(jmt"""

# Addition

$(letters()) What is ``{{:a1}} + {{:a2}}``?

""",
         (a1,a2) -> a1 + a2,     # compute answer
         (2:5, 3:6)              # a1 is chosen from 2:5, a2 chosen from 3:6
         ) |> qs                 # add to questions

## -----

radioq(jmt"""
----

# Order


$(letters()) Select the biggest value.

""",
       ["1", ["2", "3", "4", "5"]],   # nested containers are shuffled
       5                              # index within flattened list of values
       ) |> qs

## ----

multiplechoiceq(jmt"""

----
# Tangent lines

![some image](https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/Tangent_to_a_curve.svg/200px-Tangent_to_a_curve.svg.png)

$(letters()) What is true *in general* about tangent lines?

""",
               ["They intersect the graph at just one point",
                "They intersect the ``x`` axis at ``0`` or ``1`` point",
                "They intersect the ``y`` axis at ``0`` or ``1`` point"],
               [2]
               ) |> qs

p =  Page(intro, qs;  meta...)  # show(p) creates the pg contents

## Can copy to the clipboard (mac command below) and paste into
## https://demo.webwork.rochester.edu/webwork2/wikiExamples/MathObjectsLabs2/2/
## to check
open(pipeline(`pbcopy`, stderr=stderr), "w") do io
   show(io, p)
end

## Or just call show

p
```


Questions can be numeric (`numericq`), choice (`radioq`), multiple choice (`multiplechoiceq`), string answer (`stringq`), or an open-ended text box (`essayq`). As well, there is a means to display randomized plots (`plotq`), labels (`label`), or hint popups (`hint`).

Questions are authored in Markdown with LaTeX equations possible. It is suggested to use the markdown syntax of ``...`` for inline math and ```math ... ``` for display equations. The questions may be parameterized by random values through the `{{:a1}}`, `{{:a2}}`, ... Mustache placeholders. The "addition" example illustrates. This randomization may be shared across problem using `randomizer`.
