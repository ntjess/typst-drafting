#import "@preview/tidy:0.4.1"
#import "utils.typ": *
#import "../drafting.typ"
#let module = tidy.parse-module(read("../drafting.typ"), scope: (drafting: drafting, ..dictionary(drafting)))

// Inspiration: https://github.com/typst/packages/blob/main/packages/preview/cetz/0.1.0/manual.typ
// This is a wrapper around typst-doc show-module that
// strips all but one function from the module first.
// As soon as typst-doc supports examples, this is no longer
// needed.
#let show-module-fn(module, fn, ..args) = {
  module.functions = module.functions.filter(f => f.name == fn)
  module.variables = module.variables.filter(v => v.name == fn)
  tidy.show-module(
    module,
    ..args.pos(),
    ..args.named(),
    show-module-name: false,
    show-outline: false,
    enable-cross-references: false,
  )
}

#show raw.where(lang: "standalone"): text => {
  standalone-margin-note-example(raw(text.text, lang: "typ"))
}

#show raw.where(lang: "standalone-ttb"): text => {
  standalone-margin-note-example(raw(text.text, lang: "typ"), direction: ttb)
}

#show raw.where(lang: "example"): content => {
  set text(font: "Libertinus Serif")
  example-with-source(content.text, drafting: drafting, direction: ltr)
}

#show raw.where(lang: "example-ttb"): content => {
  set text(font: "Libertinus Serif")
  example-with-source(content.text, drafting: drafting)
}

#show-module-fn(module, "margin-note-defaults")

#show-module-fn(module, "margin-note")
```standalone
= Document Title
#lorem(3)
#margin-note(side: left)[Left note]
#margin-note[right note]
#margin-note(stroke: green)[Green stroke, auto-offset]
#lorem(10)
#margin-note(side: left, dy: 10pt)[Manual offset]
#lorem(10)
```

#show-module-fn(module, "inline-note")
```example
= Document Title
#lorem(7)
#inline-note[An inline note that breaks the paragraph]
#lorem(6)
#inline-note(par-break: false)[A note with no paragraph break]
#lorem(6)
```

#show-module-fn(module, "rule-grid")
