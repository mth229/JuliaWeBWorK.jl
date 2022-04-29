var documenterSearchIndex = {"docs":
[{"location":"#JuliaWeBWorK.jl","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"","category":"section"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"(source) JuliaWeBWorK.jl","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"The JuliaWeBWorK package is a means to author .pg file for WeBWorK from a Julia script.","category":"page"},{"location":"#Elements-of-a-page","page":"JuliaWeBWorK.jl","title":"Elements of a page","text":"","category":"section"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"The script should call the package","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"using JuliaWeBWorK","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"The basic flow is a \"page\" is defined in the script which when shown writes out the pg text.","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"A page consists of","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"an introduction\nquestions\nmetadata","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"A \"page\" is created by a call like:","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"p =  Page(intro, qs;  [context], [answer_context], meta...)","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"The show method for a page writes out the page in pg format for saving and uploading into WeBWorK.","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"A page has a context and answer_context instructing WeBWorK as to how it should process the student's answer. The value numbers_only for answer_context is used to turn off the simplification pass by WeBWorK (so students answers like 2+2 are distinct from 4).","category":"page"},{"location":"#An-introduction","page":"JuliaWeBWorK.jl","title":"An introduction","text":"","category":"section"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"A introduction is just markdown text. Typically this is done in a raw text block so that backslashes need not be escaped. However, it can be useful to interpolate Julia values, in which case raw would not be used.","category":"page"},{"location":"#Questions","page":"JuliaWeBWorK.jl","title":"Questions","text":"","category":"section"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"Questions consist of a question and a means to grade student answers.","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"Questions come in a few different types:","category":"page"},{"location":"#randomq","page":"JuliaWeBWorK.jl","title":"randomq","text":"","category":"section"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"Most questions can be randomized. As we expect answers to be computed using Julia code, the resulting pg file contains all possible combinations and WeBWorK simply chooses a random index. (Hence, the number of possible random outcomes shouldn't be too big.)","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"The randomization is specified using a tuple of iterables, as in (1:5,) or (1:5, 1:5). (Note the trailing comma in the first to make a tuple.) Randomization can be shared amongst questions using a randomizer object.","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"Within a question, the randomized variables are referred to by Mustache variables numbered {{:a1}}, {{:a2}}, etc. (upto 16).","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"The answer to be graded is computed by an n-ary function with n the number of randomized variables (0 to 16).","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"The randomq(question, answer_fn, randomizer; ...) constructor allows this. This first example has no randomization (as specified by () for the third position argument).","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"using SpecialFunctions\nrandomq(\"What is the *value*  of  `airy(pi)`?\", () -> airyai(pi), ())","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"This example has randomization over two variables:","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"randomq(\"What is ``{{:a1}} + {{:a2}}``?\",  (a,b) -> a+b, (1:5, 1:5))","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"The above two examples expect a numeric output. For the first, a tolerance would be expected. The numericq constructor has the keyword argument tolerance defaulting to 1e-4 for an absolute tolerance.","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"For students, answers have:","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"scientific notation in answers must use an E (not e)\nInf is used for infinity","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"Other answer types than numbers can be specified:","category":"page"},{"location":"#Lists","page":"JuliaWeBWorK.jl","title":"Lists","text":"","category":"section"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"Student answers can be comma separated lists of numbers. The List function is used to specify the list.","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"question = raw\"\"\"What are the elements of  ``\\{1,2, {{:a1}}  \\}``?\"\"\"\nanswer(a) = List(1,2, a)\nrnd = (3:5,)\nrandomq(question, answer, rnd)","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"The keyword argument ordered::Bool can be specified if the list should be in some specific order, otherwise these are graded as sets.","category":"page"},{"location":"#Intervals","page":"JuliaWeBWorK.jl","title":"Intervals","text":"","category":"section"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"An interval or list of intervals may be specified as an answer. When indicating an interval, we have Interval(a,b). This will match regardless of open or closed, except when infinities are involved.","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"question = raw\"On what  intervals is ``f(x)=(x+1) \\cdot x \\cdot (x-1)`` positive?\"\nanswer() =  List([Interval(-1, 0), Interval(1,Inf)])\nrnd = ()\nrandomq(question, answer, rnd)","category":"page"},{"location":"#stringq","page":"JuliaWeBWorK.jl","title":"stringq","text":"","category":"section"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"To fill in from a limited set of strings, as computed by the possible range of the answer function over the random set.","category":"page"},{"location":"#Choice-questions","page":"JuliaWeBWorK.jl","title":"Choice questions","text":"","category":"section"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"Choice questions only have their selection of answer(s) randomized. The questions do not have any templated values for substitution, as randomq questions may.","category":"page"},{"location":"#radioq","page":"JuliaWeBWorK.jl","title":"radioq","text":"","category":"section"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"For multiple choice questions (1 of many). Also yesnoq(questions, answer::Bool) The choices to choose from are specified as an iterable of choices. If that iterable contains nested iterables, those will be shuffled. The correct answer is specified by index relative to the flattened collection:","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"radioq(\"Pick \\\"three\\\"\", (\"one\", \"two\",\"three\"), 3)           # none randomized\nradioq(\"Pick \\\"three\\\"\", ((\"one\", \"two\",\"three\"),), 3)        # all randomized\nradioq(\"Pick third\", ((\"one\", \"two\"),\"three\"),  3)            # \"three\" at end\nradioq(\"Pick third\", ((\"one\",\"two\"),  (\"three\",  \"four\")), 3) # randomized each pair","category":"page"},{"location":"#multiplechoiceq","page":"JuliaWeBWorK.jl","title":"multiplechoiceq","text":"","category":"section"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"for multiple choice questions (1 or more of many) the answers should be a tuple of needed selections.","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"multiplechoiceq(\"Select all three\", (raw\"\\\\(1\\\\)\", \"**two**\", \"3\"), (1,2,3)) # not randomised\nmultiplechoiceq(\"Some question\", ((\"one\",\"two\",\"three\"),\"four\"), 4) # first three randomized\nmultiplechoiceq(\"Some question\", ((\"one\",\"two\",\"three\"),(\"four\",\"five\")), (4,5)) # randomized first three, last two","category":"page"},{"location":"#Essayq","page":"JuliaWeBWorK.jl","title":"Essayq","text":"","category":"section"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"For longer form text answers that are graded individually. Only 1 per page is allowed.","category":"page"},{"location":"#Output-only","page":"JuliaWeBWorK.jl","title":"Output only","text":"","category":"section"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"A WeBWorK question has 3 possible places of inclusion: the answer, the question or what the student sees, and a solution. Sometimes just output is needed.","category":"page"},{"location":"#plotq","page":"JuliaWeBWorK.jl","title":"plotq","text":"","category":"section"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"For randomized plots in a question, plotq can be used to display the plots. Another question must be used to ask the question and gather the answer. The randomizer must be used to share randomization between the two.","category":"page"},{"location":"#jsxgraph","page":"JuliaWeBWorK.jl","title":"jsxgraph","text":"","category":"section"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"The page can include interactive graphics using jsxgraph. While not as interactive as the geogebra use within WeBWorK, this does allows interactive demonstrations. The JuliaWeBWorK.INCLUDE declaration creates a function which can make working with separate .js files easier within a script.","category":"page"},{"location":"#hint","page":"JuliaWeBWorK.jl","title":"hint","text":"","category":"section"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"A hint shows a little inline popup.","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"There are a few helpers for questions:","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"Plot allows for inclusion of a Plots object into a pg file. Plots are encoded and embedded.\nFile allows for inclusion of images stored in files into a pg file. Images are encoded and embedded.\nJuliaWeBWorK.QUESTIONS() creates a container for questions that can be easily pushed onto via a pipe.\nletters = JuliaWeBWorK.letters() creates a function, letters which returns an incremented letter each time it is called. Useful to multi-part questions.\nThe jmt string macro allows interpolation using $; does not need backslashes escaped; and parses to Mustache tokens.","category":"page"},{"location":"#Meta-data","page":"JuliaWeBWorK.jl","title":"Meta data","text":"","category":"section"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"Each pg file may have meta data in its contents. Such data is passed to the Page constructor through keyword arguments. For example, the following could be splatted into the call to Page.","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"meta = (\nKEYWORDS  = \"Julia, WeBWorK\",\nDBChapter = \"Sample questions\",\nDBSection = \"section 1\",\nSection = \"1\",\nProblem = \"1\"\n)","category":"page"},{"location":"#Reference","page":"JuliaWeBWorK.jl","title":"Reference","text":"","category":"section"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"Modules =  [JuliaWeBWorK]","category":"page"},{"location":"#JuliaWeBWorK.numbers_only","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.numbers_only","text":"numbers_only\n\nDictionary to pass to answer_context to turn off WeBWorK's simplification pass. There is no means to turn this off per problem, only per page.\n\n\n\n\n\n","category":"constant"},{"location":"#JuliaWeBWorK.AbstractChoiceQ","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.AbstractChoiceQ","text":" AbstractChoiceQ\n\nThe  choices questions don't  readily lend themselves to fit  with  the AbstractRandomizedQ setup,  so the choice questions push randomization on  to WeBWorK.\n\n\n\n\n\n","category":"type"},{"location":"#JuliaWeBWorK.AbstractOutputQ","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.AbstractOutputQ","text":"AbstractOutputQ\n\nType for output only things (Plots, hint, label ...)\n\n\n\n\n\n","category":"type"},{"location":"#JuliaWeBWorK.AbstractQ","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.AbstractQ","text":"AbstractQ\n\nA  question has atleast two part: a question (marked up in julia-flavored markdown) and an answer, which is typically randomized. In  WeBWorK, there are  tpyically 3 places in  the file where a question needs defintions:  in the preamble  the values are defined (written by create_answer);  between BEGIN_TEXT and END_TEXT the question is asked (written by show_answer); and the grading  area  (written by show_answer).  Hints can be added throughhint`.\n\n\n\n\n\n","category":"type"},{"location":"#JuliaWeBWorK.AbstractRandomizedQ","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.AbstractRandomizedQ","text":"AbstractRandomizedQ\n\nA question where randomization is done  by creating an array of all possible values  for the sample space in Julia and having WeBWorK  select  one of the values. The randomizer function can  be   used to share this random selection amongst questions.\n\n\n\n\n\n","category":"type"},{"location":"#JuliaWeBWorK.File-Tuple{Any}","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.File","text":"File(p)\n\nrun Base64.base64encode; wrap  for inclusion into img tag.\n\n\n\n\n\n","category":"method"},{"location":"#JuliaWeBWorK.INCLUDE-Tuple{Any}","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.INCLUDE","text":"INCLUDE(DIR)\n\nReturns a function that will includes the text of a file found relative to the specified directory (which would usually be @__DIR__). Intended for use with jsxgraph to keeps JavaScript files separate from .jl files.\n\nINCLUDE = JuliaWeBWorK.INCLUDE(@__DIR__)\nINCLUDE(\"fname.js\")\n\n\n\n\n\n","category":"method"},{"location":"#JuliaWeBWorK.LETTERS-Tuple{}","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.LETTERS","text":"return iterator over the letters (a), (b), ... Calling function increments letters\n\n\n\n\n\n","category":"method"},{"location":"#JuliaWeBWorK.MathObject-Tuple{JuliaWeBWorK.AbstractRandomizedQ}","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.MathObject","text":"MathObject(r)\n\nWhat type of MathObject to create?  Defaults to \"List\", but \"\" (PlotQ) or \"String\"  (StringQ)  are useful.\n\n\n\n\n\n","category":"method"},{"location":"#JuliaWeBWorK.PAGE-Tuple{Any}","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.PAGE","text":"PAGE(SCRIPTNAME)\n\nWrite a page to a file name based on the value of SCRIPTNAME. Returns an anonymous function  which can be called repeatedly to write a page with a filename based on SCRIPTNAME.\n\nThis is designed to be used as PAGE = JuliaWeBWorK.PAGE(@__FILE__). Then from one script file several related pg files can be generated. This might be useful for authoring exams where it is a good practice to have many separate problems and not one big one with many parts.\n\nusing JuliaWeBWorK\nPAGE = write_page(@__FILE__)\n\nq = numericq(raw\"What is \\({{:a1}} + {{:a2}}\\)?\", (a,b) -> a+b, (1:4, 2:5))\nPAGE(\"Addition\", (q,))  # writes to SCRIPT_BASE_NAME-1.pg\n\nq = numericq(raw\"What is \\({{:a1}} - {{:a2}}\\)?\", (a,b) -> a-b, (1:4, 2:5))\nPAGE(\"subtraction\", (q,))  # writes to SCRIPT_BASE_NAME-2.pg\n\nq = numericq(raw\"What is \\({{:a1}} * {{:a2}}\\)?\", (a,b) -> a*b, (1:4, 2:5))\nPAGE(\"multiplication\", (q,))  # writes to SCRIPT_BASE_NAME-3.pg\n\n\n\n\n\n","category":"method"},{"location":"#JuliaWeBWorK.Plot-Tuple{Any}","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.Plot","text":"Plot(p)\n\nConvert plot  to png  object; run Base64.base64encode; wrap  for inclusion into img tag.\n\nWorks for Plots, and would work for other graphing backends with a show(io, MIME(\"text/png\"), p) method.\n\n\n\n\n\n","category":"method"},{"location":"#JuliaWeBWorK.create_answer_partial-Tuple{JuliaWeBWorK.AbstractRandomizedQ}","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.create_answer_partial","text":"create_answer_partial\n\nAbility to modify just  part of the create_answer_tpl for \"AbstractRandomizedQ\" for a  given type. (e.g., StringQ)\n\n\n\n\n\n","category":"method"},{"location":"#JuliaWeBWorK.essayq-Tuple{Any}","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.essayq","text":"essayq(question; width=60, height=6)\n\nWeBWorK allows for one essay question per page. These will be graded by the instructor.\n\n\n\n\n\n","category":"method"},{"location":"#JuliaWeBWorK.hint","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.hint","text":"hint(text, tag=\"hint...\")\n\nLittle inline popup. docs\n\n\n\n\n\n","category":"function"},{"location":"#JuliaWeBWorK.iframe","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.iframe","text":"iframe(url, [alt]; [width], [height])\n\nEmbed the web page specified in url in the page.\n\nExample (from https://webwork.maa.org/wiki/IframeEmbedding1)\n\nr = iframe(\"https://docs.google.com/presentation/d/1pk0FxsamBuZsVh1WGGmHGEb5AlfC68KUlz7zRRIYAUg/embed#slide=id.i0\";\n    width=555, height=451)\n\n\n\n\n\n","category":"function"},{"location":"#JuliaWeBWorK.jsxgraph-Tuple{Any}","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jsxgraph","text":"jsxgraph(commands; domid=\"jxgbox\", width=600, height=400)\n\nInsert a graphic built using the jsxgraph javascript library.\n\nThe javascript commands below have a DOM id passed to initBoard which is specified to domid, with default of jxgbox. This would need adjusting were two or more graphs in the same page desired.\n\nExample (https://jsxgraph.uni-bayreuth.de/wiki/index.php/Drag_Polygons):\n\nq = jsxgraph(\"\"\"\nvar brd = JXG.JSXGraph.initBoard('jxgbox', {boundingbox: [-10, 10, 10, -10]});\nvar a = brd.create('point', [-2, 1]);\nvar b = brd.create('point', [-4, -5]);\nvar c = brd.create('point', [3, -6]);\nvar d = brd.create('point', [2, 3]);\nvar p = brd.create('polygon', [a, b, c, d], {hasInnerPoints: true});\n\"\"\"; domid=\"jxgbox\")\n\np = Page(\"Dragging polygons\", (q,))\n\nMost of the examples in the jsxgraph wiki work simply by copying the commands into a multi-line string, as in the example.\n\nThe site jsfiddle.net allows for easy testing of js code.\n\n\n\n\n\n","category":"method"},{"location":"#JuliaWeBWorK.label-Tuple{Any}","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.label","text":"label(text)\n\nAdd text area to a  set or questions\n\nExample\n\nClick  [here](www.google.com)\n\n\n\n\n\n","category":"method"},{"location":"#JuliaWeBWorK.multiplechoiceq-Tuple{Any, Any, Any}","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.multiplechoiceq","text":" multiplechoiceq(question, choices, answer; [instruction])\n\nchoices A collection of answers. An answer may be a collection, in which case it will be shuffled.\nanswer: a tuple or vector  of indices of the  correct answers. The  indices refer  to the components stacked in random then fixed order.\n\nExample:\n\nmultiplechoiceq(\"Select all three\", (raw\"\\(1\\)\", \"**two**\", \"3\"), (1,2,3)) # not randomised\nmultiplechoiceq(\"Some question\", ((\"one\",\"two\",\"three\"),\"four\"), 4) # first three randomized\nmultiplechoiceq(\"Some question\", ((\"one\",\"two\",\"three\"),(\"four\",\"five\")), (4,5)) # randomized first three, last two\n\n\n\n\n\n","category":"method"},{"location":"#JuliaWeBWorK.numericq","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.numericq","text":"numericq\n\nAlias for randomq.\n\n\n\n\n\n","category":"function"},{"location":"#JuliaWeBWorK.radioq","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.radioq","text":"radioq(question, choices,  answer, [solution])\n\nchoices. A collection of possible answers. These may be nested collections, in which case the second level is randomized\nanswer. The index, within  the flattened choices, of  the answer  (1-based)\n\nExamples\n\nradioq(\"Pick \"three\"\", (\"one\", \"two\",\"three\"), 3)           # none randomized\nradioq(\"Pick \"three\"\", ((\"one\", \"two\",\"three\"),), 3)        # all randomized\nradioq(\"Pick third\", ((\"one\", \"two\"),\"three\"),  3)            # \"three\" at end\nradioq(\"Pick third\", ((\"one\",\"two\"),  (\"three\",  \"four\")), 3) # randomized each pair\n\nchoices  =  (\"one\", \"two\",\"three\")\nradioq(\"Pick \"three\"\", [choices], 3)\n\n\n\n\n\n","category":"function"},{"location":"#JuliaWeBWorK.randomizer-Tuple","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.randomizer","text":"randomizer(vars...)\n\nA  means to share the randomization across questions.\n\nExample\n\nqs = JuliaWeBWorK.QUESTIONS()\nr = randomizer(1:3) |> qs\nq1 =  randomq(\"What is  ``2-{{:a1}}?``\", (a) -> 2-a,  r) |> qs\nq2 =  randomq(\"What is  ``3-{{:a1}}?``\", (a) -> 3-a,  r) |> qs\nPage(\"test\", qs)\n\n\n\n\n\n","category":"method"},{"location":"#JuliaWeBWorK.randomq","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.randomq","text":"randomq(question, ans_fn, random;  solution,  tolerance=1e-4,  ordered=false)\n\nMeans to ask questions which are randomized within Julia. The basic usage expects one or more numeric values as the answer. The answers may be randomized by specifying random parameter values and an answer function which returns the answer for the range of values specified by the randomized parameters. Besides numeric values, the Formula type can be used to specify an expresion for the answer; the Interval type can be used to specify one or more intervals for an answer (all intervals are assumed open).\n\nThe function numericq is an alias.\n\nArguments:\n\nquestion is a string processed through julia-flavored Markdown\nLaTeX can be included: Use \\(, \\) for inline math and \\[,\\] for display math. Alternatively, enclosing values in double back ticks indicates inline LaTeX markup, and the math literal block syntax (\"math ...\") can be used for display math.\nuse regular markdown for other markup. Eg, code, bold, italics, sectioning, lists.\nThe jmt string macro is helful to avoid escaping backslashes. It allows for string interpolation. Use raw if dollar signs have no meaning.\nReferences to randomized variables are  through Mustache variables numbered sequentially  {{:a1}}, {{:a2}}, {{:a3}}, ... up to 16 (by default).\nans_fn: the answer function is  an n-ary function of the  randomized parameters\nrandom: the random parameters are specified by 0,1,2,or more (up\n\nto 16) iterable objects (e.g., 1:5 or [1,2,3,5]) combined in a tuple (grouped with parentheses; use (itr,) if only 1 randomized parameter). Alternatively, a randomizer object may be passed allowing shared randomization amongst questions.\n\nThe collection of all possible outputs for the given random parameterizations are generated and WeBWorK selects an index from among them.\n\ntolerance is  an absolute tolerance, when the output is numeric.\nordered is only for the case where the output is a list and you want an exact order\n\nExamples\n\nusing SymPy, SpecialFunctions\n# markdown\nrandomq(\"What is the *value*  of  `airy(pi)`?\", () -> airyai(pi), ())\n# latex via back ticks\nrandomq(\"What is ``{{:a1}} + {{:a2}}``?\",  (a,b) -> a+b, (1:5, 1:5))\nrandomq(\"What is ``{{:a1}}*{{:a2}}+{{:a3}}``?\",  (a,b,c) -> a*b+c, (1:5, 1:5,1:5))\n# latex via \\(, \\)\nrandomq(raw\"What is \\({{:a1}}\\cdot{{:a2}} + {{:a3}}\\)?\",  (a,b,c) -> a*b+c, (1:5, 1:5,1:5))\nrandomq(\"Estimate from your graph the \\(x\\)-intercept.\", ()-> 2.3, ();  tolerance=0.5)\n## Dispaly math\nrandomq(\"What is \\[ \\infty  \\]?\",  () ->  Inf, ())\nrandomq(\"What is \\( {1,2,{{:a1}} } \\)?\",  (a) -> List(1,2,a), (3:6), ordered=true)\nrandomq(\"What is the derivative of  \\( \\sin(x) \\)?\", () -> (@syms x;  Formula(diff(sin(x),x))),  ())\n\nPlots may be included in different manners (see the example), but typically include via the Plot function as follows:\n\nusing Plots\np = plot(sin, 0, 2pi);\nplot!(zero);\nq = randomq(\"![A Plot]($(Plot(p))) This is a plot  of ``sin`` over what interval?\", ()->Interval(0, 2pi),())\n\nPlots may be randomized too.  See  Plot, though they will not show in  a hard copy.\n\n!! note \"TODO\"    Should consolidate arguments  to  cmp (tolerance,   ordered)    For Interval types,  may  need  to  set the context.\n\n\n\n\n\n","category":"function"},{"location":"#JuliaWeBWorK.stringq","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.stringq","text":"stringq(question, answer, values)\n\nAnswer among limited set of strings. The strings available are all the possible outputs of answer (a function) over all possible values  in the sample space.\n\nExamples:\n\nq1 = stringq(raw\"Is \\({{:a1}} > 0\\)? (yes/no)\", (a) -> (\"no\",\"yes\")[(a>0) + 1], (-3:3,))\nq2 = stringq(\"Spell  out {{:a1}}\", (a) -> (\"one\",\"two\",\"three\")[a], (1:3,))\n\n!!! Note:     Using yes/no or true/false is common, so for these cases all 4 names are available, even if some do not appear in the collection of all possible outputs.\n\n!!! Note:     If the answers don't include all likely choices, then the student will not have the option of choosing the distractors.... This is not so great.\n\n\n\n\n\n","category":"function"},{"location":"#JuliaWeBWorK.yesnoq","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.yesnoq","text":"yesnoq(question, yes::Bool, r=(), solution=\"\")\n\nA question with non-computed answer \"yes\" (yes=true) or \"no\" (yes=false)\n\n\n\n\n\n","category":"function"},{"location":"#JuliaWeBWorK.@MT_str-Tuple{Any}","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.@MT_str","text":"MT\n\nUse <<...>> or <<{...}>> for substitution before randomimization substitution. Useful for plots\n\n\n\n\n\n","category":"macro"},{"location":"#Example","page":"JuliaWeBWorK.jl","title":"Example","text":"","category":"section"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"A full example script might look like the following:","category":"page"},{"location":"","page":"JuliaWeBWorK.jl","title":"JuliaWeBWorK.jl","text":"using JuliaWeBWorK\nmeta = (\n  KEYWORDS = \"Sample questions\",\n)\n\nqs = JuliaWeBWorK.QUESTIONS()\nletters = JuliaWeBWorK.LETTERS()\n\nintro = \"\"\"\n![WeBWorK](https://webwork.maa.org/images/webwork_logo.svg)\n\nA simple page.\n\"\"\"\n\nnumericq(\"$(letters()) What is ``{{:a1}} + 2``?\",\n         (a) -> a + 2, (1:3,)) |> cs\nradioq(\"$(letters()) Which is better?\",\n       (\"*Dark* chocolate\", \"*White* chocolate\"), 1) |> qs\n\np = Page(intro, qs; meta...)","category":"page"}]
}
