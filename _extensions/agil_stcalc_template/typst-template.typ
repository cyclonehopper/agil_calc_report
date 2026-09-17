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

// Cover-page date, formatted as in the Word template ("Month, Year").
#let resolve_month_year(d) = {
  if d == [today] {
    datetime.today().display("[month repr:long], [year]")
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

// Size and placement of the cover photo shape on the page.
// The docx shape is 151.9 x 164.5 mm, reduced to 80% here; it is aligned to
// the bottom of the page with the same gap as the Word template.
#let cover-photo-width = 126.5mm
#let cover-photo-height = 136.6mm
#let cover-photo-bottom = 11mm

// Cover photo "tongue" shape, reproduced from the Word template
// (AGIL-ST-CAL-0003). The control points below are taken verbatim from the
// original DrawingML custom-geometry path, so the shape matches the docx.
// It is filled with either the cover image or a grey placeholder.
#let cover-photo-shape(fill: none) = {
  let w = cover-photo-width
  let h = cover-photo-height
  let pw = 5468397
  let ph = 5923502
  let cv(x, y) = (x / pw * w, y / ph * h)
  curve(
    fill: fill,
    curve.move(cv(5468398, 2961704)),
    curve.cubic(cv(5468398, 3256883), cv(5353431, 3534347), cv(5144739, 3743135)),
    curve.line(cv(3135630, 5752148)),
    curve.cubic(cv(3099054, 5788724), cv(3060383, 5822347), cv(3019806, 5853017)),
    curve.cubic(cv(2986183, 5878735), cv(2950940, 5902261), cv(2914936, 5923503)),
    curve.line(cv(0, 5923503)),
    curve.line(cv(0, 0)),
    curve.line(cv(2914841, 0)),
    curve.cubic(cv(2950940, 21241), cv(2986183, 44768), cv(3019806, 70485)),
    curve.cubic(cv(3060383, 101156), cv(3099054, 134779), cv(3135630, 171355)),
    curve.line(cv(5144739, 2180463)),
    curve.cubic(cv(5353431, 2389346), cv(5468398, 2666810), cv(5468398, 2961704)),
    curve.close(),
  )
}

#let disclaimer(company: "Agilitus Pty Ltd", ink: black) = {
  text(size: 7pt, fill: ink)[
    A person using #company documents or data accepts the risks of:
    (a) using the documents or data in electronic form without requesting and
    checking them for accuracy against the original hard copy version; and
    (b) using the documents or data for any purpose not agreed to in writing by
    #company.
  ]
}

// Document control / revision table shown on the contents page.
// Matches the Word template: no shading, no internal vertical rules (only an
// outer border and horizontal separators), text top-aligned. One row is drawn
// per revision in the YAML; each row is tall enough to take a digital
// signature.
#let doc-control-table(
  rev_data: (),
  ink: black,
  row-height: 12mm,
  header-height: 6mm,
) = {
  let border = 0.4pt + ink
  // Vertical cell padding (top + bottom); compensated for below so the
  // rendered row heights are exactly the requested values.
  let vpad = 4pt
  let hcell = calc.max(header-height - vpad, 0pt)
  let rows = ()
  if rev_data != none {
    let n = rev_data.len()
    for (i, rev) in rev_data.enumerate() {
      // The current (latest) revision gets the full row height; older
      // revisions collapse to half height.
      let h = if i < n - 1 { row-height / 2 } else { row-height }
      rows.push(table.hline(stroke: border))
      rows.push(block(height: calc.max(h - vpad, 0pt))[#rev.rev_no])
      rows.push(rev.rev_desc)
      rows.push(resolve_date(rev.rev_date))
      rows.push(rev.rev_prep)
      rows.push(rev.rev_check)
      rows.push(rev.rev_app)
    }
  }
  set text(size: 9pt)
  table(
    // Column proportions follow the Word grid (907:2311:1378:1488:1488:1637).
    columns: (1fr, 2.55fr, 1.52fr, 1.64fr, 1.64fr, 1.8fr),
    stroke: none,
    inset: (x: 5pt, y: 2pt),
    align: left + top,
    table.hline(stroke: border),
    table.cell(colspan: 6)[#block(height: hcell)[#text(weight: "bold")[Document Control]]],
    table.hline(stroke: border),
    table.cell[#block(height: hcell)[Revision]],
    [Issue Reason], [Date], [Prepared], [Reviewed], [Approved],
    ..rows,
    table.hline(stroke: border),
    table.vline(x: 0, stroke: border),
    table.vline(x: 6, stroke: border),
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
  cover_image: none,
  cover_placeholder: false,
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
  show_watermark: false,
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

  // Heading typography matched to the AGIL-ST-CAL template:
  //   H1 16pt Verdana Pro, teal, bold
  //   H2 12pt Arial, black, bold
  //   H3 10pt Arial, black, bold
  //   H4 10pt Arial, black
  set heading(numbering: sectionnumbering)
  show heading: set block(above: 1.6em, below: 0.9em)
  show heading.where(level: 1): set text(
    font: heading-family,
    size: 16pt,
    weight: "bold",
    fill: heading-color,
  )
  show heading.where(level: 2): set text(
    font: font,
    size: 12pt,
    weight: "bold",
    fill: ink-color,
  )
  show heading.where(level: 3): set text(
    font: font,
    size: 10pt,
    weight: "bold",
    fill: ink-color,
  )
  show heading.where(level: 4): set text(
    font: font,
    size: 10pt,
    weight: "regular",
    fill: ink-color,
  )

  // Contents-list entries (mirrors the docx toc 1 / toc 2 styles).
  show outline.entry.where(level: 1): set text(
    size: 12pt,
    fill: heading-color,
    weight: "bold",
  )
  show outline.entry.where(level: 2): set text(
    size: 10pt,
    fill: ink-color,
    weight: "bold",
  )
  show outline.entry.where(level: 3): set text(
    size: 10pt,
    fill: ink-color,
  )

  // Section-based figure numbering (e.g. Figure 2.1)
  set figure(numbering: n => {
    let h1 = counter(heading).get().at(0, default: 0)
    if h1 > 0 {
      numbering("1.1", h1, n)
    } else {
      numbering("1", n)
    }
  })
  show figure.caption: set text(size: 8.5pt, weight: "semibold")

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
  // Cover background: optional cover photo (or grey placeholder) in the docx
  // "tongue" shape, plus the brand strip.
  let background-cover = {
    if cover_image != none {
      place(bottom + left, dx: 0mm, dy: -cover-photo-bottom)[
        #cover-photo-shape(fill: tiling(
          image(cover_image, width: cover-photo-width, height: cover-photo-height, fit: "cover"),
          size: (cover-photo-width, cover-photo-height),
        ))
      ]
    } else if cover_placeholder {
      place(bottom + left, dx: 0mm, dy: -cover-photo-bottom)[
        #cover-photo-shape(fill: rgb("#F0F0F0"))
      ]
    }
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
        #if proj_no != none [#h(0.6em)| #h(0.6em)Project No. #proj_no]
        #if calc_no != none [#h(0.6em)| #h(0.6em)Document No. #calc_no]
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
      margin: (x: 20mm, top: 45mm, bottom: 30mm),
      numbering: none,
      header: running-header,
      footer: none,
      background: background-cover,
    )

    // Cover text is left-aligned (not justified).
    set par(justify: false)

    // Cover text block. Spacing and position mirror the Word template
    // (AGIL-ST-CAL-0003):
    //   after project title ....... 80 twips  ( 4 pt)
    //   after document title ...... 120 twips ( 6 pt)
    //   before "Prepared for" ..... 720 twips (36 pt, from the Subtitle style)
    //   after "Prepared for" ...... 360 twips (18 pt)
    //   date / document no / project no ... consecutive 8 pt lines
    text(font: heading-family, size: 28pt, weight: "bold", fill: ink-color)[
      #if proj_title != none [#proj_title] else [Project Title]
    ]
    v(4pt)
    text(font: heading-family, size: 16pt, weight: "bold", fill: heading-color)[
      #if title != none [#title] else [Document Title]
    ]
    v(30pt)
    text(size: 12pt, weight: "bold")[
      Prepared for #text(fill: link-color)[
        #if client != none [#client] else [Client Name]
      ]
    ]
    v(12pt)
    block[
      #set par(leading: 0.6em)
      #text(size: 8pt, fill: ink-color)[
        #if rev_data != none and rev_data.len() > 0 [
          #resolve_month_year(rev_data.last().rev_date)
        ] else [
          #datetime.today().display("[month repr:long], [year]")
        ]
      ] \
      #text(size: 8pt, fill: ink-color)[
        #if calc_no != none [#calc_no]
      ] \
      #text(size: 8pt, fill: ink-color)[
        Project Number #if proj_no != none [#proj_no] else [XXXX]
      ]
    ]

    if tagline != none {
      // Brand tagline, lower-right just above the gradient strip.
      place(bottom + right, dy: 14mm)[
        #image(tagline, width: 33mm)
      ]
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
    footer: running-footer,
    background: background-plain,
  )

  // The contents page is page 1 (the cover is unnumbered); the body
  // continues from there.
  counter(page).update(1)

  text(font: heading-family, size: 16pt, weight: "bold", fill: heading-color)[#toc_title]
  v(2mm)
  line(length: 100%, stroke: 1.2pt + heading-color)
  v(6mm)

  if toc {
    outline(title: none, depth: toc_depth, indent: toc_indent)
  }

  // Document control table with the disclaimer as small print below it.
  // `v(1fr)` pushes them to the bottom of the contents page when there is
  // room; if the contents overflow onto further pages the table flows on
  // rather than overlapping the entries (which `place(bottom, ...)` would).
  v(1fr)
  doc-control-table(
    rev_data: rev_data,
    ink: ink-color,
  )
  v(4mm)
  disclaimer(
    company: if company != none { company } else { "Agilitus Pty Ltd" },
    ink: ink-color,
  )

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
