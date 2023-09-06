#let loc-tracker = state("loc-tracker", none)

/// Default properties for margin notes. These can be overridden per function call, or
/// globally by calling `set-margin-note-defaults`. Available options are:
/// - `margin-right` (length): Size of the right margin
/// - `margin-left` (length): Size of the left margin
/// - `page-width` (length): Width of the page/container. This is automatically
///   inferrable when using `set-page-properties`
/// - `page-offset-x` (length): Horizontal offset of the page/container. This is
///   generally only useful if margin notes are applied inside a box/rect; at the page
///   level this can remain unspecified
/// - `stroke` (paint): Stroke to use for the margin note's border and connecting line
/// - `rect` (function): Function to use for drawing the margin note's border. This
///   function must accept positional `content` and keyword `width` arguments.
/// - `side` (side): Which side of the page to place the margin note on. Must be `left`
///   or `right`
/// - `hidden` (bool): Whether to hide the margin note. This is useful for temporarily
///   disabling margin notes without removing them from the code
#let margin-note-defaults = state(
  "margin-note-defaults",
  (
    margin-right: 0in,
    margin-left: 0in,
    page-width: none,
    page-offset-x: 0in,
    stroke: red,
    rect: rect,
    side: right,
    hidden: false,
  )
)
#let note-descent = state("note-descent", (left: 0pt, right: 0pt))

#let _run-func-on-first-loc(func) = {
  // Some placements are determined by locations relative to a fixed point. However, typst
  // will automatically re-evaluate that computation several times, since the usage
  // of that computation will change where an element is placed (and therefore update its
  // location, and so on). Get around this with a state that only checks for the first
  // update, then ignores all subsequent updates
  locate(loc => {
    let use-loc = loc
    if loc-tracker.at(loc) != none {
      use-loc = loc-tracker.at(loc)
    } else {
      loc-tracker.update(loc)
    }
    func(use-loc)
  })
  loc-tracker.update(none)
}

/// Place content at a specific location on the page relative to the top left corner
/// of the page, regardless of margins, current container, etc.
/// -> content
#let absolute-place(dx: 0em, dy: 0em, content) = {
  _run-func-on-first-loc(loc => {
    let pos = loc.position()
    place(dx: -pos.x + dx, dy: -pos.y + dy, content)
  })
}

#let _calc-text-resize-ratio(width, spacing, styles) = {
  // Add extra digit to ensure reasonable separation between two adjacent lines
  let num-digits = calc.ceil(calc.log(width)) + 1
  // M is conventionally the widest character so it should leave enough space if determining
  // the scale factor
  let dummy-number = "M"
  for ii in range(1, num-digits) {
    dummy-number += "M"
  }
  let max-width = measure(text(dummy-number), styles).width
  spacing/max-width * 100%
}

#let rule-grid(
  dx: 0pt,
  dy: 0pt,
  color: black,
  width: 100cm,
  height: 100cm,
  spacing: none,
  divisions: none,
  relative: true,
) = {
  // Unfortunately an int cannot be constructed from a length, so get it through a
  // hacky method of converting to a string then an int
  if spacing == none and divisions == none {
    panic("Either `spacing` or `divisions` must be specified")
  }
  if spacing != none and divisions != none {
    panic("Only one of `spacing` or `divisions` can be specified")
  }
  if divisions != none {
    spacing = calc.min(width, height)/divisions
  }
  let to-int(amt) = int(float(repr(amt.abs).slice(0, -2)))
  let x-spacing = spacing
  let y-spacing = spacing
  if type(spacing) == "sequence" {
    x-spacing = spacing.at(0)
    y-spacing = spacing.at(1)
  }
  let width = to-int(width)
  let height = to-int(height)
  
  set text(size: spacing, fill: color)
  set line(stroke: color)
  
  let place-func = if relative {place} else {absolute-place}
  let global-dx = dx
  let global-dy = dy
  style(styles => {
    // text should fit within a spacing rectangle. For now assume it's good enough
    // to just check against x dimension
    let scale-factor = _calc-text-resize-ratio(width, spacing, styles)
    let scaler = scale.with(x: scale-factor, y: scale-factor, origin: top + left)

    locate(loc => {
      let step = to-int(x-spacing)
      for (ii, dx) in range(0, width, step: step).enumerate() {
        place-func(
          dx: global-dx, dy: global-dy,
          line(start: (dx * 1pt, 0pt), end: (dx * 1pt, height * 1pt))
        )
        place-func(
          dx: global-dx + (dx * 1pt), dy: global-dy + 1pt,
          scaler(repr(ii * step))
        )
      }
      let step = to-int(y-spacing)
      for (ii, dy) in range(0, height, step: step).enumerate() {
        place-func(
          dx: global-dx, dy: global-dy,
          line(start: (0pt, dy * 1pt), end: (width * 1pt, dy * 1pt))
          )
        place-func(
          dy: global-dy + dy * 1pt + 1pt, dx: global-dx,
          scaler(repr(ii * step))
        )
      }
    })
  })
}

#let set-margin-note-defaults(..defaults) = {
  defaults = defaults.named()
  margin-note-defaults.update(old => {
    if type(old) != "dictionary" {
      old
      panic("margin-note-defaults must be a dictionary")
    }
    if (old + defaults).len() != old.len() {
      let allowed-keys = array(old.keys())
      let violators = array(defaults.keys()).filter(key => key not in allowed-keys)
      panic("margin-note-defaults can only contain the following keys: " + allowed-keys.join(", ") + ". Got: " + violators.join(", "))
    }
    let out = (:)
    old + defaults
  })
}

#let set-page-properties(margin-right: 0pt, margin-left: 0pt, ..kwargs) = {
  let kwargs = kwargs.named()
  // Wrapping in "place" prevents a linebreak from adjusting
  // the content
  place(
    layout(layout-size => {
      set-margin-note-defaults(
        margin-right: margin-right,
        margin-left: margin-left,
        page-width: layout-size.width,
        ..kwargs
      )
    })
  )
}

#let margin-lines(stroke: gray + 0.5pt) = {
  locate(loc => {
    let r-margin = margin-note-defaults.at(loc).margin-right
    let l-margin = margin-note-defaults.at(loc).margin-left
    place(dx: -2%, rect(height: 100%, width: 104%, stroke: (left: stroke, right: stroke)))

    // absolute-place(dx: 100% - l-margin, line(end: (0%, 100%)))
  })
}

#let _path-from-diffs(start: (0pt, 0pt), ..diffs) = {
    let diffs = diffs.pos()
    let out-path = (start, )
    let next-pt = start
    for diff in diffs {
      next-pt = (next-pt.at(0) + diff.at(0), next-pt.at(1) + diff.at(1))
      out-path.push(next-pt)
    }
    out-path
}

#let _get-page-pct(props) = {
  let page-width = props.page-width
  if page-width == none {
    panic("drafting's default `page-width` must be specified and non-zero before creating a note")
  }
  page-width/100
}

#let _update-descent(side, dy, anchor-y, note-rect) = {
  style(styles => {
    let height = measure(note-rect, styles).height
    let dy = measure(v(dy + height), styles).height + anchor-y
    note-descent.update(old => {
      old.insert(side, calc.max(dy, old.at(side)))
      old
    })
  })
}

#let _margin-note-right(body, dy, anchor-x, anchor-y, ..props) = {
  props = props.named()
  let pct = _get-page-pct(props)
  let dist-to-margin = 101*pct - anchor-x + props.margin-left
  let text-offset = 0.5em
  let right-width = props.margin-right - 4*pct

  let path-pts = _path-from-diffs(
    // make an upward line before coming back down to go all the way to
    // the top of the lettering
    (0pt, -1em),
    (0pt, 1em + text-offset),
    (dist-to-margin, 0pt),
    (0pt, dy),
    (1*pct + right-width / 2, 0pt)
  )
  dy += text-offset
  let note-rect = props.at("rect")(
    stroke: props.stroke, width: right-width, body
  )
  // Boxing prevents forced paragraph breaks
  box[
    #place(path(stroke: props.stroke, ..path-pts))
    #place(dx: dist-to-margin + 1*pct, dy: dy, note-rect)
  ]
  _update-descent("right", dy, anchor-y, note-rect)
}

#let _margin-note-left(body, dy, anchor-x, anchor-y, ..props) = {
  props = props.named()
  let pct = _get-page-pct(props)
  let dist-to-margin = -anchor-x + 1*pct
  let text-offset = 0.4em
  let box-width = props.margin-left - 4*pct
  let path-pts = _path-from-diffs(
    (0pt, -1em),
    (0pt, 1em + text-offset),
    (-anchor-x + props.margin-left + 1*pct, 0pt),
    (-2*pct, 0pt),
    (0pt, dy),
    (-1*pct - box-width / 2, 0pt),
  )
  dy += text-offset
  let note-rect = props.at("rect")(
    stroke: props.stroke,  width: box-width, body
  )
  // Boxing prevents forced paragraph breaks
  box[
    #place(path(stroke: props.stroke, ..path-pts))
    #place(dx: dist-to-margin + 1*pct, dy: dy, note-rect)
  ]
  _update-descent("left", dy, anchor-y, note-rect)
}

/// Places a boxed note in the left or right page margin.
///
/// - body (content): Margin note contents, usually text
/// - dy (length): Vertical offset from the note's location -- negative values
///   move the note up, positive values move the note down
/// - ..kwargs (dictionary): Additional properties to apply to the note. Accepted values are keys from `margin-note-defaults`.
#let margin-note(body, dy: auto, ..kwargs) = {
  _run-func-on-first-loc(loc => {
    let pos = loc.position()
    let properties = margin-note-defaults.at(loc) + kwargs.named()
    let (anchor-x, anchor-y) = (pos.x - properties.page-offset-x, pos.y)
    
    if properties.hidden {
      return
    }

    // `let` assignment allows mutating argument
    let dy = dy
    if dy == auto {
      let cur-descent = note-descent.at(loc).at(repr(properties.side))
      dy = calc.max(0pt, cur-descent - loc.position().y)
      // Notes at the beginning of a line misreport their y position, since immediately
      // after they are placed, a new line is created which moves the note down.
      // A hacky fix is to subtract a line's worth of space from the y position when
      // detecting a note at the beginning of a line.
      // TODO: When https://github.com/typst/typst/issues/763 is resolved,
      // `get` this value from `par.leading` instead of hardcoding`
      if anchor-x == properties.margin-left {
        dy -= 0.65em
      }
    }

    let margin-func = if properties.side == right {
      _margin-note-right
    } else {
      _margin-note-left
    }
    margin-func(
      body, dy, anchor-x, anchor-y, ..properties
    )
  })
}

/// Place a note inline with the text body.
///
/// - body (content): Margin note contents, usually text
/// - par-break (bool): Whether to break the paragraph after the note, which places
///   the note on its own line. Beware: inline notes with `par-break: false` cannot
///   have a fill and will behave strangely when oversized content is present.
/// - ..kwargs (dictionary): Additional properties to apply to the note.
///
#let inline-note(body, par-break: true, ..kwargs) = {
  locate(loc => {
    let properties = margin-note-defaults.at(loc) + kwargs.named()
    if properties.hidden {
      return
    }

    let rect-func = properties.at("rect")
    if par-break {
      return rect-func(body, stroke: properties.stroke)
    }
    // else
    let dummy-rect = rect-func(stroke: properties.stroke)[Dummy content]
    let s = dummy-rect.stroke
    // Underline/overline stroke should inherit their properties from when users
    // specify `set rect(stroke: ...)` which is accomplished by grabbing defaults
    // from a dummy rect.
    let stroke-props = (
      paint: s.paint,
      thickness: s.thickness,
      cap: s.cap,
      miter-limit: s.miter-limit,
      dash: s.dash,
    )
    let bottom = 0.5em
    let top = 1em
    set text(top-edge: "ascender", bottom-edge: "descender")
    let cap-line = {
      let t = s.thickness / 2
      show "|": it => box(height: top, outset: (bottom: bottom + t, top: t), stroke: s)
      [|]
    }
    let new-body = underline(stroke: stroke-props, [ #body ], offset: bottom)
    new-body = [
      #underline([#cap-line#new-body#cap-line], stroke: stroke-props, offset: -top)
    ]
    new-body

  })
}
