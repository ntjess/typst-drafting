#import "../drafting.typ": *

#set page(margin: (right: 2in))
= Test<a-label>

#lorem(10)
#margin-note[
  #lorem(10) #footnote[test footnote] #lorem(10)
]#lorem(30)

#lorem(20)#inline-note(stroke: orange + 3pt, fill: green)[test inline note]
#lorem(10)

#note-outline()
