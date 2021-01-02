## A test might be comprised of several pg file so that each question
## can be displayed on its own page. However, spreading a test out over
## many scripts might be undesirable. This example shows how to use the
## `JuliaWeBWorK.PAGE` function to create connected pg files
## using one basic script.

using JuliaWeBWorK
PAGE = JuliaWeBWorK.PAGE(@__FILE__)

q = numericq(L"What is \({{:a1}} + {{:a2}}\)?", (a,b) -> a+b, (1:4, 2:5))
PAGE("Addition", (q,)) # writes to SCRIPT_BASE_NAME-1.pg

q = numericq(L"What is \({{:a1}} - {{:a2}}\)?", (a,b) -> a-b, (1:4, 2:5))
PAGE("subtraction", (q,)) # writes to SCRIPT_BASE_NAME-2.pg

q = numericq(L"What is \({{:a1}} * {{:a2}}\)?", (a,b) -> a*b, (1:4, 2:5))
PAGE("multiplication", (q,)) # writes to SCRIPT_BASE_NAME-3.pg
