# JuliaWeBWorK.jl

[(source) JuliaWeBWorK.jl](https://github.com/mth229/JuliaWeBWorK.jl)

The `JuliaWeBWorK` package is a means to author `.pg` file for [WeBWorK](https://webwork.maa.org/) from a `Julia` script.


## Elements of a page

The script should call the package

```@example julia_webwork
using JuliaWeBWorK
```

The basic flow is a "page" is defined in the script which when `show`n writes out the `pg` text.

----

A page consists of

* an introduction
* questions
* metadata


A "page" is created by a call like:

```
p =  Page(intro, qs;  [context], [answer_context], meta...)
```

The `show` method for a page writes out the page in `pg` format for saving and uploading into `WeBWorK`.

A page has a `context` and `answer_context` instructing `WeBWorK` as to how it should process the student's answer. The value [`numbers_only`](@ref) for `answer_context` is used to turn off the simplification pass by `WeBWorK` (so students answers like `2+2` are distinct from `4`).

### An introduction

A introduction is just markdown text. Typically this is done in a `raw` text block so that backslashes need not be escaped. However, it can be useful to interpolate `Julia` values, in which case `raw` would not be used.


### Questions

Questions consist of a question *and* a means to grade student answers.

Questions come in a few different types:

#### `randomq`

Most questions can be randomized. As we expect answers to be computed using `Julia` code, the resulting `pg` file contains all possible combinations and `WeBWorK` simply chooses a random index. (Hence, the number of possible random outcomes shouldn't be too big.)

The randomization is specified using a tuple of iterables, as in `(1:5,)` or `(1:5, 1:5)`. (Note the trailing comma in the first to make a tuple.) Randomization can be shared amongst questions using a [`randomizer`](@ref) object.

Within a question, the randomized variables are referred to by `Mustache` variables numbered `{{:a1}}`, `{{:a2}}`, etc. (upto 16).

The answer to be graded is computed by an `n`-ary function with `n` the number of randomized variables (0 to 16).


The `randomq(question, answer_fn, randomizer; ...)` constructor allows this. This first example has no randomization (as specified by `()` for the third position argument).

```@example julia_webwork
using SpecialFunctions
randomq("What is the *value*  of  `airy(pi)`?", () -> airyai(pi), ())
```

This example has randomization over two variables:

```@example julia_webwork
randomq("What is ``{{:a1}} + {{:a2}}``?",  (a,b) -> a+b, (1:5, 1:5))
```


The above two examples expect a numeric output. For the first, a tolerance would be expected. The `numericq` constructor has the keyword argument `tolerance` defaulting to `1e-4` for an absolute tolerance.

For students, answers have:

* scientific notation in answers must use an E (not `e`)
* `Inf` is used for infinity

Other answer types than numbers can be specified:

#### Lists

Student answers can be comma separated lists of numbers. The [`List`](@ref) function is used to specify the list.

```@example julia_webwork
question = raw"""What are the elements of  ``\{1,2, {{:a1}}  \}``?"""
answer(a) = List(1,2, a)
rnd = (3:5,)
randomq(question, answer, rnd)
```

The keyword argument `ordered::Bool` can be specified if the list should be in some specific order, otherwise these are graded as sets.

#### Intervals

An interval or list of intervals may be specified as an answer. When indicating an interval, we have `Interval(a,b)`. This will match regardless of open or closed, except when infinities are involved.

```@example julia_webwork
question = raw"On what  intervals is ``f(x)=(x+1) \cdot x \cdot (x-1)`` positive?"
answer() =  List([Interval(-1, 0), Interval(1,Inf)])
rnd = ()
randomq(question, answer, rnd)
```

#### `stringq`

To fill in from a limited set of strings, as computed by the possible range of the answer function over the random set.

### Choice questions

Choice questions only have their selection of answer(s) randomized. The questions do not have any templated values for substitution, as `randomq` questions may.

#### `radioq`

For multiple choice questions (1 of many). Also `yesnoq(questions, answer::Bool)`
The choices to choose from are specified as an iterable of choices. If that iterable contains nested iterables, those will be shuffled. The correct answer is specified by index relative to the flattened collection:

```
radioq("Pick \"three\"", ("one", "two","three"), 3)           # none randomized
radioq("Pick \"three\"", (("one", "two","three"),), 3)        # all randomized
radioq("Pick third", (("one", "two"),"three"),  3)            # "three" at end
radioq("Pick third", (("one","two"),  ("three",  "four")), 3) # randomized each pair
```



#### `multiplechoiceq`

for multiple choice questions (1 *or more* of many) the answers should be a tuple of needed selections.

```
multiplechoiceq("Select all three", (raw"\\(1\\)", "**two**", "3"), (1,2,3)) # not randomised
multiplechoiceq("Some question", (("one","two","three"),"four"), 4) # first three randomized
multiplechoiceq("Some question", (("one","two","three"),("four","five")), (4,5)) # randomized first three, last two
```



#### `Essayq`

For longer form text answers that are graded individually. Only 1 per page is allowed.

### Output only

A WeBWorK question has 3 possible places of inclusion: the answer, the question or what the student sees, and a solution. Sometimes just output is needed.

#### `plotq`

For randomized plots in a question, `plotq` can be used to display the plots. Another question must be used to ask the question and gather the answer. The `randomizer` must be used to share randomization between the two.

#### `jsxgraph`

The page can include interactive graphics using `jsxgraph`. While not as interactive as the geogebra use within WeBWorK, this does allows interactive demonstrations. The `JuliaWeBWorK.INCLUDE` declaration creates a function which can make working with separate `.js` files easier within a script.


#### `hint`

A hint shows a little inline popup.


----

There are a few helpers for questions:

* `Plot` allows for inclusion of a `Plots` object into a `pg` file. Plots are encoded and embedded.
* `File` allows for inclusion of images stored in files into a `pg` file. Images are encoded and embedded.
* `JuliaWeBWorK.QUESTIONS()` creates a container for questions that can be easily `push`ed onto via a pipe.
* `letters = JuliaWeBWorK.letters()` creates a function, `letters` which returns an incremented letter each time it is called. Useful to multi-part questions.
* The `jmt` string macro allows interpolation using `$`; does not need backslashes escaped; and parses to Mustache tokens.


### Meta data

Each `pg` file may have meta data in its contents. Such data is passed to the `Page` constructor through keyword arguments. For example, the following could be splatted into the call to `Page`.

```
meta = (
KEYWORDS  = "Julia, WeBWorK",
DBChapter = "Sample questions",
DBSection = "section 1",
Section = "1",
Problem = "1"
)
```




## Reference

```@autodocs
Modules =  [JuliaWeBWorK]
```

## Example

A full example script might look like the following:

```@example julia_webwork
using JuliaWeBWorK
meta = (
  KEYWORDS = "Sample questions",
)

qs = JuliaWeBWorK.QUESTIONS()
letters = JuliaWeBWorK.LETTERS()

intro = """
![WeBWorK](https://webwork.maa.org/images/webwork_logo.svg)

A simple page.
"""

numericq("$(letters()) What is ``{{:a1}} + 2``?",
         (a) -> a + 2, (1:3,)) |> cs
radioq("$(letters()) Which is better?",
       ("*Dark* chocolate", "*White* chocolate"), 1) |> qs

p = Page(intro, qs; meta...)
```
