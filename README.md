# Agilitus Calculation Report

A **Quarto + Typst** template for Agilitus structural calculations. The layout
mirrors the Word template `AGIL-ST-CAL-0003_1`:

1. a branded **cover page**,
2. a **Contents** page with the document control / revision table, and
3. the **body**, starting at *Introduction*.

Branding (colours, typography and logos) is defined once in `_brand.yml` and is
consumed by both Quarto and the Typst template.

## Requirements

- Quarto `>= 1.8` (Typst is bundled)
- Julia (the example document uses the project's Julia environment)

## Using the template

Create a new document from `template.qmd` and set the metadata in the YAML
header:

```yaml
format:
  agil_calc_report-typst: default
toc: true
toc-title: Contents
company: Agilitus
client: Glencore
proj_no: 26016
proj_title: Glencore Port C2A Conveyor Relocation Engineering
calc_no: 26016-ST-CAL-0002
calc_title: C2A Permanent Installation Structural Design
proj_phase: Detailed Design
revisions:
  - rev_no: A
    rev_date: today
    rev_desc: IFIR
    rev_prep: Josua A
    rev_check: F. Hakim
    rev_app:
```

The template renders the cover and contents pages automatically. The body of
the document should begin with the first level-1 heading (normally
`# Introduction`); do **not** add a manual table of contents or page break at
the start.

Render with:

```bash
quarto render template.qmd
```

## Branding

`_brand.yml` is the single source of truth for the brand:

```yaml
color:
  palette:
    agilitus-blue: "#0066B2"   # gradient start
    agilitus-mid:  "#4B929B"   # gradient middle
    agilitus-green: "#91C970"  # gradient end
    agilitus-teal: "#40A9BB"   # headings / accents
  primary: agilitus-teal
  secondary: agilitus-blue
  foreground: agilitus-ink

typography:
  base:
    family: Arial
  headings:
    family: Verdana
    color: agilitus-teal

logo:
  images:
    agilitus: images/logo-agilitus.png
    watermark: images/brand/agilitus-watermark.svg
    tagline: images/brand/shaping-tomorrow-together.png
    cover: images/brand/cover-image_min-1800x1950px.png
```

Change a value in `_brand.yml` and it flows through to the cover, headings,
and the blue→green gradient strips on every page.

## Cover photo

The cover reproduces the photo shape from the Word template — a
**126.5 × 136.6 mm** "tongue" at the lower left (the original docx shape,
scaled to 80% and grown by 5 mm). It is bottom-aligned on the page and filled
with the image named `cover` in `_brand.yml` — by default
`images/brand/cover-image_min-1500x1620px.png`.

To use your own photo, either replace that file or point the document metadata
at another one:

```yaml
cover-image: images/my-cover.jpg     # or cover_image
```

Provide an image of at least **1500 × 1620 px (300 dpi)**; the image is cropped
(`fit: "cover"`) to fill the shape. To show the grey placeholder shape instead
of a photo, set:

```yaml
cover-placeholder: true
```

### Fonts

The Word template uses *Verdana Pro* (headings) and *Arial* (body). The brand
uses the metric-compatible **Verdana** and **Arial** system fonts. On Debian or
Ubuntu these are provided by `ttf-mscorefonts-installer`:

```bash
sudo apt-get install ttf-mscorefonts-installer
```

If those fonts are not available, set `typography.base.family` and
`typography.headings.family` in `_brand.yml` to an installed family (for
example `Lato`).

## Repository layout

| Path | Purpose |
|------|---------|
| `template.qmd` | Example calculation document |
| `_brand.yml` | Brand colours, typography and logos |
| `_extensions/agil_calc_report/typst-template.typ` | Cover, contents and body layout |
| `_extensions/agil_calc_report/typst-show.typ` | Maps metadata + brand into the template |
| `images/brand/` | Brand assets (watermark, tagline) |
