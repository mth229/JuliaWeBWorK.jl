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

#include("markdown-additions.jl")
include("commonmark-additions.jl")
include("answers.jl")
include("page.jl")

 
import LaTeXStrings
import LaTeXStrings: LaTeXString
latexstring(args...) = latexstring(string(args...))
function latexstring(s::String)
    # the only point of using LaTeXString to represent equations, since
    # IJulia doesn't support LaTeX output other than equations, so add $'s
    # around the string if they aren't there (ignoring \$)
    return (occursin(r"\(", s) || occursin("\\[",s)) ? LaTeXString(s) :  LaTeXString(string(raw"\(", s, raw"\)"))
end
latexstring(s::AbstractString) = latexstring(String(s))

macro L_str(s, flags...) latexstring(s) end
macro L_mstr(s, flags...) latexstring(s) end
export @L_str, @L_mstr

macro q_str(x)  "`$x`" end
export @q_str


end
