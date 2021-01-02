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


export Page
export randomizer,  randomq, numericq, stringq, plotq, essayq
export radioq, multiplechoiceq
export iframe, label,  hint
export List,  Formula,  Interval, Plot
export @L_str, @L_mstr
export @q_str
export @MT_str
export @mt_str, @jmt_str

#include("markdown-additions.jl")
include("commonmark-additions.jl")
include("answers.jl")
include("page.jl")



end
