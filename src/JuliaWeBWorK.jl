module JuliaWeBWorK

## USeful  docs
## https://www.uleth.ca/sites/default/files/2017/09/problemgenerationwithwebwork.pdf
## https://webwork.maa.org/mediawiki_new/images/a/ab/WeBWorK_Problem_Authoring_Tutorial.pdf
## https://webwork.maa.org/wiki/SampleProblem4
## https://webwork.maa.org/wiki/Display_Macros


using Markdown
using Mustache

export Page
export radioq, numericq, multinumericq
export iframe
export List,  Formula,  Interval 

include("markdown-additions.jl")
include("answers.jl")
include("page.jl")




end
