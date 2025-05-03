
#set page(margin: (x: 5cm), width: 25cm, height: 10cm)

#import "../drafting.typ": *

#set-margin-note-defaults(link: "index")

= `link = "index"`
#lorem(40)
#margin-note[Hello world]
#margin-note[Stacked]
// #margin-note[Notes]
#lorem(40)
#margin-note[#lorem(18)][Yep]
#lorem(40)

#pagebreak()

= `link = "line"`
#set-margin-note-defaults(link: "line")

#lorem(40)
#margin-note[Hello world]
#margin-note[Stacked]
// #margin-note[Notes]
#lorem(40)
#margin-note[#lorem(18)][Yep]
#lorem(40)
