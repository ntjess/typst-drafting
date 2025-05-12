#set page(margin: (x: 5cm), width: 25cm, height: 10cm)

#import "../drafting.typ": *

#set-margin-note-defaults(link: "index")

= `link = "index"`
#lorem(40)
#margin-note[Hello world]
#margin-note[Stacked]
#lorem(40)

== Custom numbering
#set-margin-note-defaults(inline-numbering: i => [*<#i>*], note-numbering: i => [*TODO #i:* ])
#margin-note[#lorem(18)][Yep]
#lorem(20)
#set-margin-note-defaults(inline-numbering: auto, note-numbering: auto)

#pagebreak()

= `link = "line"`
#set-margin-note-defaults(link: "line")

#lorem(40)
#margin-note[Hello world]
#margin-note[Stacked]

#lorem(40)
#margin-note[#lorem(18)][Yep]
#lorem(20)
