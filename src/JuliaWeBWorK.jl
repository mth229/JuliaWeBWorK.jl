module JuliaWeBWorK


if isdefined(Base, :Experimental) && isdefined(Base.Experimental, Symbol("@optlevel"))
    @eval Base.Experimental.@optlevel 1
end

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


export Page, QUESTIONS
export randomizer,  randomq, numericq, stringq, yesnoq, plotq, essayq
export radioq, multiplechoiceq
export iframe, label,  hint
export List,  Formula,  Interval
export Plot, File
export @L_str, @L_mstr  # deprecate this
export @q_str           # deprecate this
export @MT_str          # deprecate this
export @mt_str
export @jmt_str         # main macro for authoring allows $interpolation, single \
export numbers_only

const SENTINEL = "XXXxxx...xxxXXX"

#include("markdown-additions.jl")
include("commonmark-additions.jl")
include("answers.jl")
include("page.jl")



end
