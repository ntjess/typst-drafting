#import "../drafting.typ": *

#set page(margin: (right: 2in), height: auto)
= Default Test

#lorem(10)
#margin-note[
  #lorem(10) #footnote[test footnote] #lorem(10)
]#lorem(30)

#lorem(20)#inline-note(stroke: orange + 3pt, fill: green)[test inline note]
#lorem(10)

#note-outline()

#set page(margin: (inside: 2in, outside: 1in), height: auto)
= Inside/outside margins
== Unspecified side = largest = right
#set-page-properties()
#let body = {
  lorem(20)
  margin-note[Largest side note]
  lorem(20)
  margin-note(side: left)[left note]
  margin-note(side: right)[right note]
  lorem(10)
}
#body
#pagebreak()
= Inside on left
== Unspecified side = largest = left
#body
