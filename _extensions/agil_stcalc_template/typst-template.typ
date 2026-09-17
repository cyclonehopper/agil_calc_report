// =============================================================================
// Agilitus structural calculation template (Quarto + Typst)
//
// Revised to match the AGIL-ST-CAL-0003 report style:
//   * branded cover page
//   * table of contents page with document control / revision table
//   * body starting at the Introduction
//
// Colours, typography and logos are driven by the project `_brand.yml`.
// Quarto injects `brand-color` (a dictionary of the brand palette) and
// `brand-logo-images` before this template is called, and the brand typography
// is forwarded through `typst-show.typ`.
// =============================================================================

// Fallbacks so the template still compiles if no `_brand.yml` is present.
// Quarto's own definitions (emitted in the header) shadow these when a brand
// is configured.
#let brand-color = (:)
#let brand-logo-images = (:)

// -----------------------------------------------------------------------------
// Small helpers
// -----------------------------------------------------------------------------

#let logo(logo_path: none, width: auto) = {
  if logo_path != none {
    image(logo_path, width: width)
  } else {
    []
  }
}

#let resolve_date(d) = {
  if d == [today] {
    datetime.today().display("[day]/[month]/[year repr:last_two]")
  } else {
    d
  }
}

// Horizontal Agilitus gradient (blue -> teal -> green).
#let brand-gradient(blue, mid, green) = gradient.linear(
  (blue, 0%),
  (mid, 50%),
  (green, 100%),
  angle: 0deg,
)

#let disclaimer(company: "Agilitus Pty Ltd", ink: black) = {
  text(size: 0.95em, fill: ink)[
    A person using #company documents or data accepts the risks of:
    (a) using the documents or data in electronic form without requesting and
    checking them for accuracy against the original hard copy version; and
    (b) using the documents or data for any purpose not agreed to in writing by
    #company.
  ]
}

// Document control / revision table shown on the contents page.
#let doc-control-table(
  rev_data: (),
  ink: black,
  heading-color: rgb("#40A9BB"),
  company: "Agilitus Pty Ltd",
) = {
  let rows = if rev_data != none {
    for rev in rev_data {
      (
        rev.rev_no,
        rev.rev_desc,
        resolve_date(rev.rev_date),
        rev.rev_prep,
        rev.rev_check,
        rev.rev_app,
      )
    }
  } else {
    ()
  }
  set text(size: 8pt)
  table(
    columns: (auto, 1fr, auto, auto, auto, auto),
    stroke: (paint: ink, thickness: 0.4pt),
    inset: 4pt,
    table.cell(
      colspan: 6,
      fill: luma(240),
      align: left,
    )[#text(weight: "semibold", fill: heading-color)[Document Control]],
    table.cell(fill: luma(240))[#text(weight: "semibold")[Revision]],
    table.cell(fill: luma(240))[#text(weight: "semibold")[Issue Reason]],
    table.cell(fill: luma(240))[#text(weight: "semibold")[Date]],
    table.cell(fill: luma(240))[#text(weight: "semibold")[Prepared]],
    table.cell(fill: luma(240))[#text(weight: "semibold")[Reviewed]],
    table.cell(fill: luma(240))[#text(weight: "semibold")[Approved]],
    ..rows,
    table.cell(colspan: 6, align: left)[
      #disclaimer(company: company, ink: ink)
    ],
  )
}

// -----------------------------------------------------------------------------
// Main template
// -----------------------------------------------------------------------------

#let article(
  title: none,
  authors: none,
  company: none,
  proj_no: none,
  calc_no: none,
  proj_title: none,
  client: none,
  proj_phase: none,
  logo_company: none,
  logo_client: none,
  tagline: none,
  watermark: none,
  rev_data: none,
  cols: 1,
  margin: (inside: 1.5cm, outside: 1.5cm, top: 5cm, bottom: 2.5cm),
  paper: "a4",
  lang: "en",
  region: "AU",
  mathfont: none,
  codefont: none,
  font: ("Arial",),
  heading-family: ("Verdana",),
  // Brand colours (forwarded from the brand palette in `typst-show.typ`)
  heading-color: rgb("#40A9BB"),
  ink-color: rgb("#231F20"),
  secondary-color: rgb("#0066B2"),
  mid-color: rgb("#4B929B"),
  accent-color: rgb("#91C970"),
  link-color: rgb("#0063FF"),
  fontsize: 11pt,
  sectionnumbering: "1.1",
  fig-align: center,
  toc: true,
  toc_title: [Contents],
  toc_depth: 3,
  toc_indent: 1.5em,
  cover: true,
  strip_height: 9mm,
  show_watermark: true,
  doc,
) = {
  // ---------------------------------------------------------------------------
  // Base styles
  // ---------------------------------------------------------------------------
  set text(lang: lang, region: region, size: fontsize)
  set text(font: font) if font != none
  show math.equation: set text(font: mathfont) if mathfont != none
  show raw: set text(font: codefont) if codefont != none
  set par(justify: true)

  show link: set text(fill: link-color)
  show ref: set text(fill: link-color)

  set heading(numbering: sectionnumbering)
  show heading: set text(font: heading-family, fill: heading-color, weight: "semibold")
  show heading: set block(above: 1.6em, below: 0.9em)

  // Level-1 entries in the contents list echo the document branding.
  show outline.entry.where(level: 1): set text(fill: heading-color, weight: "semibold")

  // Section-based figure numbering (e.g. Figure 2.1)
  set figure(numbering: n => {
    let h1 = counter(heading).get().at(0, default: 0)
    if h1 > 0 {
      numbering("1.1", h1, n)
    } else {
      numbering("1", n)
    }
  })
  show figure.caption: set text(size: 0.85em, weight: "semibold")

  // Keep Quarto's figure counters reset at each level-1 heading.
  show heading.where(level: 1): it => {
    counter(figure.where(kind: "quarto-float-fig")).update(0)
    counter(figure.where(kind: "quarto-float-tbl")).update(0)
    it
  }

  if rev_data == none {
    rev_data = ()
  }

  // ---------------------------------------------------------------------------
  // Branded page furniture
  // ---------------------------------------------------------------------------
  let band = brand-gradient(secondary-color, mid-color, accent-color)
  let strip = rect(width: 100%, height: strip_height, fill: band)

  // Background used by the cover and contents pages (strip only)...
  let background-plain = {
    place(bottom + left, strip)
  }
  // ...and by the body (faint watermark plus the strip).
  let background-body = {
    if show_watermark and watermark != none {
      place(center + horizon, image(watermark, width: 58%))
    }
    place(bottom + left, strip)
  }

  let running-header = {
    set text(size: 8pt, fill: ink-color)
    align(right)[#logo(logo_path: logo_company, width: 24mm)]
  }

  let running-footer = context {
    set text(size: 7pt, fill: ink-color)
    grid(
      columns: (1fr, auto),
      align(left)[
        #if client != none [#client]
        #if proj_title != none [#h(0.6em)| #h(0.6em)#proj_title]
        #if proj_no != none [#h(0.6em)| #h(0.6em)Proj #proj_no]
        #if calc_no != none [#h(0.6em)| #h(0.6em)Doc #calc_no]
        #if rev_data != none and rev_data.len() > 0 [#h(0.6em)Rev #rev_data.last().rev_no]
      ],
      align(right)[Page #counter(page).display("1")],
    )
  }

  // ---------------------------------------------------------------------------
  // Cover page
  // ---------------------------------------------------------------------------
  if cover {
    set page(
      paper: paper,
      margin: (x: 20mm, top: 42mm, bottom: 30mm),
      numbering: none,
      header: running-header,
      footer: none,
      background: background-plain,
    )

    v(4mm)
    text(size: 9pt, weight: "semibold", tracking: 1.5pt, fill: heading-color)[
      STRUCTURAL CALCULATION
    ]
    v(8mm)
    text(size: 25pt, weight: "bold", fill: ink-color)[
      #if proj_title != none [#proj_title] else [Project Title]
    ]
    v(5mm)
    line(length: 100%, stroke: 1pt + heading-color)
    v(5mm)
    text(size: 15pt, fill: heading-color)[
      #if title != none [#title] else [Document Title]
    ]
    v(20mm)
    text(size: 11pt)[
      Prepared for #text(fill: link-color)[
        #if client != none [#client] else [Client Name]
      ]
    ]
    v(3mm)
    text(size: 9pt, fill: ink-color)[
      #if rev_data != none and rev_data.len() > 0 [Rev #rev_data.last().rev_no] else [Rev A]
      #if rev_data != none and rev_data.len() > 0 [ · #resolve_date(rev_data.last().rev_date)]
    ]
    v(16mm)
    text(size: 9pt)[
      Document Number #if calc_no != none [#calc_no] else [—] \
      Project Number #if proj_no != none [#proj_no] else [—] \
      #if proj_phase != none [Project Phase #proj_phase] \
      #if company != none [Prepared by #company]
    ]

    if tagline != none {
      place(bottom + center, box(inset: (bottom: 16mm))[
        #image(tagline, width: 48mm)
      ])
    }

    pagebreak()
  }

  // ---------------------------------------------------------------------------
  // Contents page
  // ---------------------------------------------------------------------------
  set page(
    paper: paper,
    margin: (x: 20mm, top: 40mm, bottom: 26mm),
    numbering: none,
    header: running-header,
    footer: none,
    background: background-plain,
  )

  text(size: 20pt, weight: "semibold", fill: ink-color)[#toc_title]
  v(2mm)
  line(length: 100%, stroke: 1.2pt + heading-color)
  v(6mm)

  if toc {
    outline(title: none, depth: toc_depth, indent: toc_indent)
  }

  place(bottom, doc-control-table(
    rev_data: rev_data,
    ink: ink-color,
    heading-color: heading-color,
    company: if company != none { company } else { "Agilitus Pty Ltd" },
  ))

  pagebreak()

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------
  set page(
    paper: paper,
    margin: (x: 22mm, top: 38mm, bottom: 26mm),
    numbering: "1",
    header: running-header,
    footer: running-footer,
    background: background-body,
  )

  // Number the body from 1 (the cover and contents pages are unnumbered).
  counter(page).update(1)

  doc
}

// -----------------------------------------------------------------------------
// Non-numbered heading used inside the calculation body.
// -----------------------------------------------------------------------------
#let like_header(it) = {
  v(0.5em)
  box(width: 100%, stroke: (bottom: 1pt), outset: (bottom: -2pt))[
    #set text(weight: "semibold", size: 1.3em)
    #v(0.1em)
    #smallcaps(it)
    #v(0.6em)
  ]
}
