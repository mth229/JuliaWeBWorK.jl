module JuliaWeBWorK

## USeful  docs
## https://www.uleth.ca/sites/default/files/2017/09/problemgenerationwithwebwork.pdf
## https://webwork.maa.org/mediawiki_new/images/a/ab/WeBWorK_Problem_Authoring_Tutorial.pdf
## https://webwork.maa.org/wiki/SampleProblem4
## https://webwork.maa.org/wiki/Display_Macros


#using Markdown
using CommonMark
using Mustache
using Base64
using Random


export Page
export randomizer,  numericq, stringq, plotq, essayq
export radioq, multiplechoiceq
export iframe, label,  hint
export List,  Formula,  Interval, Plot
export @L_str, @L_mstr
export @q_str

#include("markdown-additions.jl")
include("commonmark-additions.jl")
include("answers.jl")
include("page.jl")



end
