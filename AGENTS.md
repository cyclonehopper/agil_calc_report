---
trigger: always_on
---

Activation Mode

Always On
This rule will always be applied
Content
# AI Instructions: Quarto + Typst + Julia Workflow

## 📝 Document Context
You are an expert structural engineer and writer, and Julia developer. This project uses **Quarto** (`.qmd`) as the orchestrator, **Typst** for high-fidelity PDF typesetting, and **Julia** for computations.

## ⚙️ Execution Rules (Julia)
- Use executable blocks: ` ```{julia} ... ``` ` (with curly braces) for Julia code that must run.
- Use ` #| ` for block-level options (e.g., `#| label: fig-1`, `#| echo: false`).
- Default to  `Plots.jl` libraries for visualizations unless otherwise specified.
- Ensure all Julia packages are referenced in the local `Project.toml`.
- **Quantity labels/text: don't decompose.** Interpolate the rounded quantity and let `Unitful` print the unit, e.g. `"N* = $(N |> f2)"` → `"N* = 50.25 kN"`. Use `f0`–`f3`/`fround` from `MyUnits`; never `string(ustrip(...))`, and never re-attach units by hand (`* u"m"`, `* 1°`) just for display. `round(q; digits=n)` on a `Quantity` is **not** a substitute — it errors, or (for dimensionless units like `°`) rounds the SI-base value and drops the unit.
- **Strip units only when a quantity is raised to an irrational power** (`x^0.5`, `x^(1/3)`, `sqrt(x)` of a non-square quantity): convert to consistent units (`upreferred`), `ustrip`, compute, then re-attach the resulting unit. Everywhere else keep the `Unitful` quantity.

## 🎨 Typesetting Rules (Typst)
- When writing raw Typst blocks, use: ` ```{=typst} ... ``` `
- Remember that Typst uses `#` for functions (e.g., `#rect()`) which differs from Quarto's Markdown headers.
- If using a custom Typst template, reference it in the YAML header under `format: typst: template: my-template.typ`.
- For displaying Julia variables, use `{julia} ... ` (with curly braces)  for inline.

## 🚫 Critical Constraints
- **JULIA-ONLY CODE CHUNKS:** All code chunks are Julia only, nothing else. Do not use any other language in executable code chunks.
- **NO LATEX:** Do not use LaTeX commands; use native Typst syntax or Quarto cross-references (`@fig-label`).
- **Syntax Boundaries:** Never place Julia code inside a ````{=typst}` block. Julia must stay in ````{julia}` blocks.
