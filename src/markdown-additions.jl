# Maake "text/pg" translaations from Markdown

## use \( \) and \[ \] for  LaTeX
## use ``literal`` (and not `literal`)  for literal markup

"""
    show(io, ::MIME"text.pg", md::Markdown.MD)

Show *modified* markdown code in format suitable for a `pg` file.

There are necessary modifications due to how `Markdown` parses entities and how `pg` files are parsed. 
As such, only *most* markdown features are available. Here are some differences:

* use "\`\`, \`\`" pairs for *literal* text. (In Markdown this indicates latex)
* use "\\(, \\)" pairs for *inline* latex and  "\\[,\\]" pairs for equation display latex
* Use `{{:a1}}`, …, `{{:a6}}` as placeholders for randomized parameters
* Parsing `\`\` 5*6*7 \`\`` will be fine, it is read as LaTeX by Markdown, but `\\( 5*6*7 \\)` will be a problem, as
  `*6*` will be parsed as italicized. Work around this with `⋅` (`\\cdot[tab]`), say.

"""
function Base.show(io::IO, M::MIME"text/pg", md::Markdown.MD)
    for m in  md.content
        show(io,  M, m)
    end
end

function Base.show(io::IO, mime::MIME"text/pg", header::Markdown.Header{l}) where {l}
    txt = join(header.text)
    if l == 1
        println(io, "\n\$PAR\n\$BBOLD $(txt) \$EBOLD\n\$PAR\n\$PAR")
    end
    if l == 2
        println(io, "\n\$PAR\n\$BITALICS $(txt) \$EITALICS\n\$PAR")        
    end
    if l > 2
        print(io, "\n\$PAR\n§ $(txt)\n\$PAR")
    end
end


function Base.show(io::IO, ::MIME"text/pg", md::Markdown.Paragraph)
    println(io, "\$PAR")
    for md in md.content
      show(io, "text/pg", md)
    end
end

function Base.show(io::IO, ::MIME"text/pg", md::Markdown.BlockQuote)
    println(io,  "\$BEGIN_ONE_COLUMN")
    for item in md.content
        show(io, "text/pg", item)
    end
    println(io,  "\$END_ONE_COLUMN")
end


function Base.show(io::IO, ::MIME"text/pg", md::Markdown.Code)
    println(io, "\n\$PAR")
    for l  in  split(md.code, "\n")
        # within  "\verb~" ~ \$var is not  needed, only $
        lr = replace(l, "\\\$"=> "\$")
        println(io, "⋮\\(\\verb~ $lr ~\\) \$BR")
    end
end


function Base.show(io::IO, M::MIME"text/pg", md::Markdown.List)
    itemized =  md.ordered >=  0
    for (i,  item) in enumerate(md.items)
        if itemized
            print(io, "\$BR $i) ")
        else
            print(io,  "\$BR • ")
        end
        for  i in  item
            if isa(i, Markdown.Paragraph) # avoid $PARR
                for  j in  i.content
                    show(io, M, j)
                end
            else
                show(io, M, i)
            end
        end
    end
end

function Base.show(io::IO, ::MIME"text/pg", md::Markdown.HorizontalRule)
    println(io, "\$HR")
end

function Base.show(io::IO, ::MIME"text/pg", md::Markdown.Bold)
    print(io, "\$BBOLD $(join(md.text)) \$EBOLD")
end

function Base.show(io::IO, ::MIME"text/pg", md::Markdown.Italic)
    print(io, "\$BITALIC $(join(md.text)) \$EITALIC")
end

#  use popup here; why?  why not?
function Base.show(io::IO, ::MIME"text/pg", md::Markdown.Image)
    println(io, """
\\{ htmlLink( "javascript:window.open('$(md.url)');", "$(md.alt)" ) \\}
""")
end

function Base.show(io::IO, ::MIME"text/pg", md::Markdown.Link)
    buf = IOBuffer()
    for m  in md.text # an array!
        print(buf, m)
    end
    text = String(take!(buf))
    println(io, """
\\{ htmlLink( "javascript:windowpopup('$(md.url)');", '$(text)' ) \\}
""")
end

## Hack. We use  ``x`` for literals  
function Base.show(io::IO, ::MIME"text/pg", md::Markdown.LaTeX)
    txt = md.formula
    txt = replace(txt, "\\"=>"")
    print(io, "\\(\\verb~$(txt)~\\)")
end

function Base.show(io::IO, ::MIME"text/pg", md::T) where {T <: AbstractString}
    print(io, md)
end

Base.show(io::IO, M::MIME"text/pg",  x::Symbol) = show(io, M,  string(x))


