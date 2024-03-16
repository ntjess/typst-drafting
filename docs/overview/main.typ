#import "/drafting.typ" as drafting: *
#import "../utils.typ": dummy-page
#import "@preview/showman:0.1.1"

#show <example-output>: set text(font: "Linux Libertine")

#let template(doc) = {
  showman.formatter.template(
    // theme: "dark",
    eval-kwargs: (direction: ttb, scope: (drafting: drafting), unpack-modules: true),
    doc
  )
}
#show: template

#set page(
  margin: (right: 2in, y: 0.8in),
  paper: "us-letter",
  height: auto,
)
#set-page-properties()

#include("content.typ")