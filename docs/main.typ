#import "../drafting.typ": margin-note, rule-grid, absolute-place, set-page-properties, set-margin-note-defaults

#let (l-margin, r-margin) = (0.8in, 2in)
#set page(margin: (left: l-margin, right: r-margin, rest: 0.1in), paper: "us-letter", height: auto)
#set-page-properties(margin-left: l-margin, margin-right: r-margin)

#let code-example(body) = {
  box(fill: gray.lighten(70%), outset: 0.35em, radius: 0.5em, raw(lang: "typst", body))
}

= Margin Notes
The easiest way to add margin notes is by simply calling:

#code-example("#margin-note[content]")

#lorem(18)
#margin-note[This is a margin note.]
#lorem(2)
#margin-note(dy: 3em, stroke: aqua)[Overlapping notes? Use `dy: <amount>` to adjust the vertical spacing.]

#lorem(3)
#margin-note(side: left, dy: -40pt)[Shake things with notes on both sides of the page.]
#lorem(27)

#let reviewer-a = margin-note.with(stroke: blue)
#let reviewer-b = margin-note.with(stroke: purple)
Multiple reviewers? Customize your margin note colors:

#code-example("#let reviewer-a = margin-note.with(stroke: blue)")#reviewer-a[Hi there]

#code-example("#let reviewer-b = margin-note.with(stroke: purple)")#reviewer-b(side: left, dy: 10pt)[Hello]

Don't like the default color or side?
Update them to something more appealing:

#code-example("#set-margin-note-defaults(stroke: yellow, side: left)")
#set-margin-note-defaults(stroke: yellow, side: left)

#text(fill: red)[
Todo: #margin-note[Yellow on the left by default]
- Auto-track the lowest current note per side so manual adjustment of `dy` isn't necessary
- Incorporate logic from #link("https://github.com/typst/typst/issues/1882") when it's resolved to avoid users explicitly calling `drafting.set-page-properties`
]

= Positioning
Need to measure space for fine-tuned positioning? You can use `rule-grid`.
Just note that dimensions can't be specified using `%`:

#code-example("#rule-grid(width: 10cm, height: 3cm, spacing: 20pt)")

#rule-grid(width: 10cm, height: 3cm, spacing: 20pt)
#place(
  dx: 180pt,
  dy: 40pt,
  rect(fill: white, stroke: red, width: 1in, "This will originate at (180pt, 40pt)")
)
// The rule grid doesn't take up space, so add it explicitly
#v(3cm + 1em)

What about absolutely positining something regardless of margin and relative location? `absolute-place` is your friend. You can put content anywhere:

#code-example(
"#absolute-place(
  dx: dx, dy: dy,
  rect(fill: white, stroke: red, width: 1in, [content])
)"
)

#let (dx, dy) = (5in, 81%)
#absolute-place(
  dx: dx,
  dy: dy,
  rect(
    fill: green.lighten(60%),
    radius: 0.5em,
    width: 2.25in,
    "This absolutely-placed box will originate at (" + repr(dx) + ", " + repr(dy) + ") in page coordinates")
)

The "rule-grid" also supports absolute placement at the top-left of the page by passing `relative: false`. This is helpful for "rule"-ing the whole page.

#text(fill: red)[
Todo: 
- Allow percentage-based dimensions for `rule-grid`
- Allow independent (x, y) divisions or spacing rather than forcing square units
]
