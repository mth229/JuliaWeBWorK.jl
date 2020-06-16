# Show how  google drive can be used for file upload
# Make an account for the class
# Suggest making a  course based google  account
# Make a form (forms.google.com)
# Some useful form details can  be pre-filled.  You have access to (at  least):
# * studentName
# * studentLogin
# * studentID
# * setNumber
# * probNum
#
# Replace the pre-filled value in the URL with a PERL reference to a variable  from above. E.g.:
# https://docs.google.com/forms/d/e/1FAIpQLScZXmLG0N4GmbLn1GXMbFkoOXVQb2d37NQug9DkFte48fiEbw/viewform?usp=pp_url&entry.941198495=$studentName&entry.52654376=$setNumber&entry.2147005713=$probNumber
#
# Include a link using  [tag](link) markdown from a question, or a  label, as below

# Variables that 

q = label(raw"""

Upload your file: [upload file](https://docs.google.com/forms/d/e/1FAIpQLScZXmLG0N4GmbLn1GXMbFkoOXVQb2d37NQug9DkFte48fiEbw/viewform?usp=pp_url&entry.941198495=$studentName&entry.52654376=$setNumber&entry.2147005713=$probNum)
""")


Page("File upload example", (q,))
