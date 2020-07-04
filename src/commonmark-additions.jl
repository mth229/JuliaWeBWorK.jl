
# using CommonMark
# import CommonMark: Writer, Node, Document, Text, SoftBreak, LineBreak, Code, HtmlInline, Link, Image, Emph, Strong, Paragraph, Heading, BlockQuote, Item, ThematicBreak, CodeBlock, HtmlBlock
# Public.

function Base.show(io::IO, ::MIME"text/pg", ast::CommonMark.Node, env=Dict{String,Any}())
    writer = CommonMark.Writer(Pg(), io, env)
    write_pg(writer, ast)
    return nothing
end
pg(args...) = writer(MIME"text/pg"(), args...)

# Internals.

mime_to_str(::MIME"text/pg") = "pg"


mutable struct Pg
    list_depth::Int
    list_item_number::Vector{Int}
    Pg() = new(0, [])
end

function write_pg(writer::CommonMark.Writer, ast::CommonMark.Node)
    for (node, entering) in ast
        if entering
            meta = node.meta
            if haskey(meta, "id")
                ## Could evaluate code, ....
                CommonMark.literal(writer, "\\protect\\hyperlabel{", meta["id"], "}{}")
            end
        end
        write_pg(node.t, writer, node, entering)
    end
end

write_pg(::CommonMark.Document, w, node, ent) = nothing

write_pg(::CommonMark.Text, w, node, ent) = pg_escape(w, node.literal)

write_pg(::CommonMark.SoftBreak, w, node, ent) = CommonMark.cr(w)
write_pg(::CommonMark.LineBreak, w, node, ent) = CommonMark.cr(w) #CommonMark.literal(w, "") #raw"$BR")

function write_pg(::CommonMark.Code, w, node, ent)
    CommonMark.literal(w, "\\(\\verb~")
    pg_escape(w, node.literal)
    CommonMark.literal(w, "~\\)")
end

write_pg(::CommonMark.HtmlInline, w, node, ent) = CommonMark.literal(w, node.literal) # nothing

function write_pg(link::CommonMark.Link, w, node, ent)
    if ent
        CommonMark.literal(w, """\\{ htmlLink( "javascript:windowpopup('$(link.destination)')",'""")
    else
        CommonMark.literal(w, """$(link.title)' ); \\}""")
        CommonMark.cr(w)
    end
end

function write_pg(::CommonMark.Image, w, node, ent)

    id =  randstring('a':'z',10)
    url =  node.t.destination 
    alt = node.t.title
    tex_url = match(r"^data:image/gif", url) == nothing ? url : "Image goes here"

    ## XXX alt does not show up in  title...
    if ent
        CommonMark.cr(w)
        CommonMark.literal(w, """
END_TEXT
\$$id = MODES(
HTML=>'<figure><img src="$(url)"  alt="$(alt)"><figcaption>$(alt)</figcaption></figure>',
TeX=>'[$(alt)]($tex_url)',
);
BEGIN_TEXT
\$$id
""")
        CommonMark.cr(w)
    else
        CommonMark.cr(w)
    end
end

write_pg(::CommonMark.Emph, w, node, ent) = CommonMark.literal(w, ent ? raw"$BITALIC " : raw" $EITALIC")

write_pg(::CommonMark.Strong, w, node, ent) = CommonMark.literal(w, ent ? raw"$BBOLD " : raw" $EBOLD")

function write_pg(::CommonMark.Paragraph, w, node, ent)
    CommonMark.literal(w, ent ? "" : raw" $PAR")
    CommonMark.cr(w)
end

function write_pg(::CommonMark.Heading, w, node, ent)
    n = node.t.level
    if ent
        CommonMark.cr(w)
        n == 1 && CommonMark.literal(w, "\$PAR\n\$BBOLD ")
        n == 2 && CommonMark.literal(w, "\$PAR\n\$BITALIC ")
        n >= 3 && CommonMark.literal(w, "\$PAR\n§ ")
    else
        n == 1 && CommonMark.literal(w, "\$EBOLD\n\$PAR\n ")
        n == 2 && CommonMark.literal(w, "\$EITALIC\n\$PAR\n ")
        n >= 3 && CommonMark.literal(w, "\$PAR ")
        CommonMark.cr(w)
    end
end

function write_pg(::CommonMark.BlockQuote, w, node, ent)
    CommonMark.cr(w)
    CommonMark.literal(w, ent ? raw"$BBLOCKQUOTE" : raw"$EBLOCKQUOTE")
    CommonMark.cr(w)
end

function write_pg(list::CommonMark.List, w, node, ent)
    CommonMark.cr(w)
    command = list.list_data.type === :bullet ? "itemize" : "enumerate"
    if ent
        w.format.list_depth += 1
        push!(w.format.list_item_number, list.list_data.start)
    else
        w.format.list_depth -= 1
        pop!(w.format.list_item_number)
    end
    CommonMark.cr(w)
end

function write_pg(item::CommonMark.Item, w, node, ent)
    #   form hmtl writer
    bullets = ['\u25CF', '\u25CB', '\u25B6', '\u25B7', '\u25A0', '\u25A1']
    bullet = bullets[min(w.format.list_depth, length(bullets))]
    CommonMark.literal(w, ent ? "$bullet" : "")
    CommonMark.cr(w)
end

function write_pg(::CommonMark.ThematicBreak, w, node, ent)
    CommonMark.cr(w)
    CommonMark.literal(w, raw"$HR")
    CommonMark.cr(w)
end

function write_pg(::CommonMark.CodeBlock, w, node, ent)
    CommonMark.cr(w)
    for line in eachline(IOBuffer(node.literal))
        CommonMark.literal(w, "|\\( \\verb~ ") # ⋮ is an issue with knowLink
        CommonMark.literal(w, line)
        CommonMark.literal(w, "~\\) \$BR")
        CommonMark.cr(w)
    end
    CommonMark.literal(w, "\$PAR")
end

write_pg(::CommonMark.HtmlBlock, w, node, ent) = nothing

let chars = Dict(
        '^'  => "\\^{}",
        '\\' => "{\\textbackslash}",
        '~'  => "{\\textasciitilde}",
    )
    for c in "&%\$#_{}"
        chars[c] = "\\$c"
    end
    chars = Dict()
    global function pg_escape(w::CommonMark.Writer, s::AbstractString)
        for ch in s
            CommonMark.literal(w, get(chars, ch, ch))
        end
    end
end
