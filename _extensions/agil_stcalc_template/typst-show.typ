// typst-show.typ
//
// Calls the `article` function defined in `typst-template.typ`, forwarding the
// document metadata and the project brand (colour palette + typography).
//
// `brand-color` and `brand-logo-images` are injected by Quarto immediately
// before this file, so they can be read at runtime here.

#show: doc => article(
$if(calc_title)$
  title: [$calc_title$],
$endif$
$if(by-author)$
  authors: (
$for(by-author)$
$if(it.name.literal)$
    ( name: [$it.name.literal$],
      affiliation: [$for(it.affiliations)$$it.name$$sep$, $endfor$],
      email: [$it.email$] ),
$endif$
$endfor$
    ),
$endif$

$if(company)$
  company: [$company$],
$endif$

$if(proj_no)$
  proj_no: [$proj_no$],
$endif$

$if(calc_no)$
  calc_no: [$calc_no$],
$endif$

$if(proj_title)$
  proj_title: [$proj_title$],
$endif$

$if(client)$
  client: [$client$],
$endif$

$if(proj_phase)$
  proj_phase: [$proj_phase$],
$endif$

$if(logo_company)$
  logo_company: "$logo_company$",
$else$
  logo_company: brand-logo-images.at("agilitus", default: (:)).at("path", default: none),
$endif$
$if(logo_client)$
  logo_client: "$logo_client$",
$endif$
  watermark: brand-logo-images.at("watermark", default: (:)).at("path", default: none),
  tagline: brand-logo-images.at("tagline", default: (:)).at("path", default: none),

$if(revisions)$
  rev_data: (
  $for(revisions)$
  (
      rev_no: [$revisions.rev_no$],
      rev_date: [$revisions.rev_date$],
      rev_desc: [$revisions.rev_desc$],
      rev_prep: [$revisions.rev_prep$],
      rev_check: [$revisions.rev_check$],
      rev_app: [$revisions.rev_app$],
  ),
  $endfor$
  ),
$endif$

$if(brand.typography.base.family)$
  font: $brand.typography.base.family$,
$endif$
$if(brand.typography.headings.family)$
  heading-family: $brand.typography.headings.family$,
$endif$
$if(brand.typography.headings.color)$
  heading-color: $brand.typography.headings.color$,
$endif$
  ink-color: brand-color.at("foreground", default: rgb("#231F20")),
  secondary-color: brand-color.at("secondary", default: rgb("#0066B2")),
  mid-color: brand-color.at("agilitus-mid", default: rgb("#4B929B")),
  accent-color: brand-color.at("agilitus-green", default: rgb("#91C970")),
  link-color: brand-color.at("agilitus-link", default: rgb("#0063FF")),

$if(lang)$
  lang: "$lang$",
$endif$
$if(region)$
  region: "$region$",
$endif$
$if(abstract)$
  abstract: [$abstract$],
$endif$
$if(margin)$
  margin: ($for(margin/pairs)$$margin.key$: $margin.value$,$endfor$),
$endif$
$if(papersize)$
  paper: "$papersize$",
$endif$
$if(mainfont)$
  font: ("$mainfont$",),
$endif$
$if(fontsize)$
  fontsize: $fontsize$,
$endif$
$if(section-numbering)$
  sectionnumbering: "$section-numbering$",
$endif$
$if(mathfont)$
  mathfont: ($for(mathfont)$"$mathfont$",$endfor$),
$endif$
$if(codefont)$
  codefont: ($for(codefont)$"$codefont$",$endfor$),
$elseif(brand.typography.monospace.family)$
  codefont: $brand.typography.monospace.family$,
$endif$
$if(toc)$
  toc: $toc$,
$endif$
$if(toc-title)$
  toc_title: [$toc-title$],
$endif$
$if(toc-depth)$
  toc_depth: $toc-depth$,
$endif$
  cols: $if(columns)$$columns$$else$1$endif$,
  doc,
)
