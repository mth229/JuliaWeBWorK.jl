## Example of markup which uses Markdown for text formatting and LaTeX for math formatting

using JuliaWeBWorK

## raw is used so there is no need to escape backslashes
q = raw"""

# LaTeX markup can be done two ways (Julian or using LaTeX's \(,\) and \[,\])

Inline: ``\LaTeX`` or \(\LaTeX\)

Display math can be done in two ways 

```math
\sin(x)^2 = \frac{1}{2}
```

\[
\sin(x)^2 = \frac{1}{2}
\]

The use of dollar signs for math markup is not supported.


# Markdown markup

String formatting: **bold**, *italics*, `code`


itemized lists:

* one
* two

1) One
2) Two

horizontal line

-----

verbatim text

```
verbatim text
```

Quotation

> Four score and seven years ago our fathers brought forth on this continent, 
> a new nation, conceived in Liberty, and dedicated to the proposition that 
> all men are created equal.

Admonition

!!! note "Admonition title"
    this is an admonition

URL:

<https://www.markdownguide.org/basic-syntax/>

[markdown guide](https://www.markdownguide.org/basic-syntax/)

Images

![some image](https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/Tangent_to_a_curve.svg/200px-Tangent_to_a_curve.svg.png)

"""
q1 = numericq(q, ()->1, (); solution="No solution given")

Page("Example of markup", (q1,))

