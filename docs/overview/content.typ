#let pkg-version = "0.2.0"

#let counter = counter("examples")
#let COMPILE-FOR-README = true
#show raw.where(lang: "example"): it => {
  [#metadata(it.text)<input-text>]
  it
  counter.step()
  if COMPILE-FOR-README [
    ![](example-#counter.display();.png)
  ]
}

= Margin Notes
== Setup
`drafting` exists in the official typst package repository, so the recommended approach is to import it from the `preview` namespace:
#raw(lang: "typst", block: true, "#import \"@preview/drafting:" + pkg-version + "\"")

Margin notes cannot lay themselves out correctly until they know your page size and margins.
To this end, make sure call `#set-page-properties()` *after* configuring your page size/margins:
```typ
// Of course, you can set whatever margin values you prefer
#set page(
  margin: (right: 2in), paper: "us-letter"
)

// This is important! Call it whenever your page is reconfigured.
#set-page-properties()
```
#text(red)[Note:] `drafting` does not yet support `inside`/`outside` margins.
  Follow #link("https://github.com/typst/typst/issues/3636") for updates.

== The basics
```example
#lorem(20)
#margin-note(side: left)[Hello, world!]
#lorem(10)
#margin-note[Hello from the other side]
#margin-note[When notes are about to overlap, they're automatically shifted]
#margin-note(stroke: aqua + 3pt)[To avoid collision]
#lorem(25)
#margin-note(stroke: green, side: left)[You can provide two positional arguments if you want to highlight a phrase associated with your note.][The first is text which should be inline-noted, and the second is the standard margin note.]

#let caution-rect = rect.with(inset: 1em, radius: 0.5em, fill: orange.lighten(80%))
#inline-note(rect: caution-rect)[
  Be aware that `typst` will complain when 4 notes overlap, and stop automatically avoiding collisions when 5 or more notes
  overlap. This is because the compiler stops attempting to reposition notes after a few attempts
  (initial layout + adjustment for each note).

  You can manually adjust the position of notes with `dy` to silence the warning.
]
```

== Adjusting the default style
All function defaults are customizable through updating the module state:

```example
#lorem(14) #margin-note[Default style]
#lorem(10)
#set-margin-note-defaults(stroke: orange, side: left)
#margin-note[Updated style]
#lorem(10)
```

Even deeper customization is possible by overriding the default `rect`:

```example
#import "@preview/colorful-boxes:1.1.0": stickybox

#let default-rect(stroke: none, fill: none, width: 0pt, content) = {
  set text(0.9em)
  stickybox(rotation: 30deg, width: width/1.5, content)
}
#set-margin-note-defaults(rect: default-rect, stroke: none, side: right)

#lorem(20)
#margin-note(dy: -5em)[Why not use sticky notes in the margin?]

// Undo changes from this example
#set-margin-note-defaults(rect: rect, stroke: red)
```

== Multiple document reviewers

```example
#let reviewer-a = margin-note.with(stroke: blue)
#let reviewer-b = margin-note.with(stroke: purple)
#lorem(10)
#reviewer-a[Comment from reviewer A]
#lorem(5)
#reviewer-b(side: left)[Reviewer B comment]
#lorem(10)
```

== Inline Notes
```example
#lorem(10)
#inline-note[The default inline note will split the paragraph at its location]
#lorem(10)
#inline-note(par-break: false, stroke: (paint: orange, dash: "dashed"))[
  But you can specify `par-break: false` to prevent this
]
#lorem(10)
```

== Hiding notes for print preview

```example
#set-margin-note-defaults(hidden: true)

#lorem(20)
#margin-note[This will respect the global "hidden" state]
#margin-note(hidden: false, dy: -2.5em)[This note will never be hidden]
// Undo these changes
#set-margin-note-defaults(hidden: false)
```

#set page(margin: (left: 0.8in, right: 0.8in))

= Positioning
== Precise placement: rule grid
Need to measure space for fine-tuned positioning? You can use `rule-grid` to cross-hatch
the page with rule lines:

```example
#rule-grid(width: 10cm, height: 3cm, spacing: 20pt)
#place(
  dx: 180pt,
  dy: 40pt,
  rect(fill: white, stroke: red, width: 1in, "This will originate at (180pt, 40pt)")
)

// Optionally specify divisions of the smallest dimension to automatically calculate
// spacing
#rule-grid(dx: 10cm + 3em, width: 3cm, height: 1.2cm, divisions: 5, square: true,  stroke: green)

// The rule grid doesn't take up space, so add it explicitly
#v(3cm + 1em)
```

== Absolute positioning
What about absolutely positioning something regardless of margin and relative location? `absolute-place` is your friend. You can put content anywhere:

```example
#context {
  let (dx, dy) = (here().position().x, here().position().y)
  let content-str = (
    "This absolutely-placed box will originate at (" + repr(dx) + ", " + repr(dy) + ")"
    + " in page coordinates"
  )
  absolute-place(
    dx: dx, dy: dy,
    rect(
      fill: green.lighten(60%),
      radius: 0.5em,
      width: 2.5in,
      height: 0.5in,
      [#align(center + horizon, content-str)]
    )
  )
}
#v(0.5in)
```

The "rule-grid" also supports absolute placement at the top-left of the page by passing `relative: false`. This is helpful for "rule"-ing the whole page.
