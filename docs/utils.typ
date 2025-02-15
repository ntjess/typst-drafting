#import "../drafting.typ"
#let example-box = box.with(fill: white.darken(3%), inset: 0.5em, radius: 0.5em, width: 100%)


#let dummy-page(width, height: auto, margin-left, margin-right, content) = (
  context {
    let total-width = width + margin-left + margin-right
    let content-box = box(
      height: height,
      width: width,
      fill: white,
      stroke: (left: black + 0.5pt, right: black + 0.5pt),
      inset: 3pt,
      content,
    )
    let box-height = measure(content-box).height
    let height = if height == auto {
      box-height
    }
    place(example-box(height: height, width: total-width, radius: 0pt))
    pad(
      left: margin-left,
      content-box,
    )
  }
)


#let _build-preamble(scope) = {
  let preamble = ""
  for module in scope.keys() {
    preamble = preamble + "import " + module + ": *; "
  }
  preamble
}

#let eval-example(source, ..scope) = [
  #let preamble = _build-preamble(scope.named())
  #eval(
    (preamble + "[" + source + "]"),
    scope: scope.named(),
  )
  <example-eval-result>
]

#let _bidir-grid(direction, ..args) = {
  let grid-kwargs = (:)
  if direction == ltr {
    grid-kwargs = (columns: 2, column-gutter: 1em)
  } else {
    grid-kwargs = (rows: 2, row-gutter: 1em, columns: (100%,))
  }
  grid(..grid-kwargs, ..args)
}

#let example-with-source(source, inline: false, direction: ttb, ..scope) = {
  let picture = eval-example(source, ..scope)
  let source-box = if inline {
    box
  } else {
    block
  }

  _bidir-grid(direction)[
    #example-box(raw(lang: "typ", source))
  ][
    #example-box(picture)
  ]

}


#let _make-page(source, offset, w, l, r, scope) = {
  let props = (
    "margin-right:" + repr(r) + ", margin-left:" + repr(l) + ", page-width:" + repr(w) + ", page-offset-x: " + repr(offset)
  )
  let preamble = "#let margin-note = margin-note.with(" + props + ")\n"
  let content = eval-example(preamble + source.text, ..scope)
  dummy-page(w, l, r, content)
}

#let standalone-margin-note-example(
  source,
  width: 2in,
  margin-left: 0.8in,
  margin-right: 1in,
  scope: (drafting: drafting),
  direction: ltr,
) = {
  let (l, r) = (margin-left, margin-right)
  let number-args = (width, l, r)
  let content = _make-page(source, 0pt, ..number-args, scope)
  _bidir-grid(
    direction,
    example-box(width: 100%, source),
    context {
      let offset = here().position().x
      set text(font: "Libertinus Serif")
      layout(layout-size => {
        let minipage = content
        let minipage-size = measure(minipage)
        let (width, height) = (minipage-size.width, minipage-size.height)
        let ratio = (layout-size.width / width) * 100%
        let w = width
        let number-args = number-args.map(n => n * ratio)
        minipage = _make-page(source, offset, ..number-args, scope)
        minipage
      })
    },
  )
}
