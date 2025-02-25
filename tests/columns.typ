#import "../drafting.typ": *

#set page(margin: (x: 5cm), width: 25cm, height: 10cm)

#let l = margin-note(side: left)[Specified left]
#let r = margin-note(side: right, stroke: green)[Specified right]
#let a = margin-note(stroke: blue)[Automatically placed]


#set page(columns: 2)
= 2 Page columns
#lorem(10)
#l
#r
#a

#lorem(150)
#l
#r
#a


#set page(columns: 3)
= 3 Page columns
#lorem(10)
#l
#r
#a

#lorem(60)
#l
#r
#a

#lorem(80)
#l
#r
#a

#pagebreak()
#set page(columns: 4)
= 4 Page columns
#lorem(1)
#l
#r
#a

#lorem(40)
#l
#r
#a

#lorem(52)
#l
#r
#a

#lorem(50)
#l
#r
#a

#pagebreak()
#set page(columns: 1)
#show: columns.with(2)
= Columns function
#lorem(10)
#l
#r
#a

#lorem(150)
#l
#r
#a


#colbreak()
= End of line break --- bug
#lorem(30)
#l
#r
#a

#colbreak()
#lorem(30)
#r
