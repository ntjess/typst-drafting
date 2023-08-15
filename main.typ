#import "drafting.typ"
#import "drafting.typ": margin-note, rule-grid, absolute-place

#let (l-margin, r-margin) = (0.8in, 3in)
#set page(margin: (left: l-margin, right: r-margin), paper: "us-letter")
#drafting.set-page-properties(margin-left: l-margin, margin-right: r-margin)


== Margin Notes

#lorem(20)
#margin-note[This is a margin note.]
#margin-note(dy: 3em)[Overlapping notes? Use `dy: <amount>` to adjust the vertical spacing.]

#lorem(3)
#margin-note(side: left, dy: -40pt)[Shake things with notes on both sides of the page.]
#lorem(27)

#let reviewer-a = margin-note.with(stroke: blue)
#let reviewer-b = margin-note.with(stroke: purple)
Multiple reviewers? Customize your margin note colors:

#raw(lang: "typst", "#let reviewer-a = margin-note.with(stroke: blue)")#reviewer-a[Hi there!]

#raw(lang: "typst", "#let reviewer-b = margin-note.with(stroke: purple)")#reviewer-b(side: left, dy: 10pt)[Hello!]

Don't like the default color or side?
#drafting.margin-note-defaults.update(old => {
  old.insert("stroke", yellow)
  old.insert("side", left)
  old
})
#margin-note(dy: 20pt)[Yellow on the left!]
Update them to something more appealing.

#text(fill: red)[
Todo: 
- Auto-track the lowest current note per side so manual adjustment of `dy` isn't necessary
- Incorporate logic from #link("https://github.com/typst/typst/issues/1882") when it's resolved to avoid users explicitly calling `drafting.set-page-properties`
]

#pagebreak()
// No more need for large margin
#set page(margin: (right: 0.8in))

= Placements
Need to measure space for fine-tuned positioning? You can use `rule-grid`, #underline[but] you can't specify dimensions using `%`:
#v(1em)
#rule-grid(width: 10cm, height: 5cm, spacing: 20pt)
#place(
  dx: 180pt,
  dy: 80pt,
  rect(fill: white, stroke: red, width: 1in, "This will originate at (180pt, 80pt)")
)
// The rule grid doesn't take up space, so add it explicitly
#v(5cm + 1em)

What about absolutely positining something regardless of margin and relative location? `absolute-place` is your friend. You can put content anywhere:

#absolute-place(
  dx: 0%,
  dy: 50%,
  rect(fill: white, stroke: red, width: 1in, "This will originate at (0%, 50%)")
)

#v(10%)
The "rule-grid" also supports absolute placement at the top-left of the page by passing `relative: false`. This is helpful for "rule"-ing the whole page, i.e.:
```typst
#rule-grid(width: 8.5in, height: 11in, relative: false)
```