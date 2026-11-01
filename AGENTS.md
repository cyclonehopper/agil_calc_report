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

## Unit rules (Unitful.jl)

These rules are mandatory in this package. Breaking them produces **silently
wrong numbers**, not exceptions.

### R1 — Never strip both sides of a `*` or `/` to "cancel" units

`ustrip` does **not** convert to SI. It drops the unit and keeps the number in
whatever unit the value happens to be stored in, so the units do **not** cancel.

```julia
# WRONG — the result depends on how each value happened to be stored
r = ustrip(x) / ustrip(y)        # 0.5u"m" / 500u"mm" → 0.001   (should be 1.0)
r = ustrip(x) * ustrip(y)        # 2u"kN" * 300u"mm" → 600, not 0.6 N·m

# WRONG TOO — dividing quantities first is not enough. The quotient still
# carries a FreeUnits scale factor (e.g. `m mm^-1`) and ustrip throws it away.
r = ustrip(x / y)                # 500u"kN" / 1.0u"MN" → 500.0 (should be 0.5)

# RIGHT — convert to SI base units first, then strip the genuinely
# dimensionless result
r = ustrip(upreferred(x / y))    # → 0.5
r = ustrip(upreferred(x * y))    # products too
```

Every dimensionless result — utilisation `M/(ϕM_s)`, slenderness
`(b/t)·√(f_y/250)`, strain, `a/d`, `I/A`, `k = I/A`, `M/EI` — must be built this
way, or simply left as a `Quantity` and compared/plotted as a quantity.

### R2 — `ustrip(unit, x)` converts; `ustrip(x)` is a trap

- `ustrip(u"mm", x)` converts `x` to mm and then drops the unit — explicit and safe.
- `ustrip(x)` keeps the caller's storage unit. Never use it on a value that will
  be combined with another value, never next to a hard-coded unit suffix, and
  never on a quantity that is really a ratio.

### R3 — Do not strip units just to put a value in a string

Unitful already renders the unit, so stripping only risks the printed unit
disagreeing with the number:

```julia
# WRONG / redundant
"$(ustrip(u"mm", L))mm"    # suffix can drift out of sync with the conversion
"$(ustrip(θ))°"            # prints radians next to a degree sign

# RIGHT
"$L"                       # "500.0 mm"
"$(L |> u\"mm\")"          # "500.0 mm"   (converted to a chosen display unit)
"$(f2(L |> u\"mm\"))"      # "500.0 mm"   (rounded via MyUnits.f2, unit retained)
```

Strip only where a bare `Float64` is genuinely required: a Python/native call, a
numeric solver, an array handed to a plotting library, or a generated Julia code
token that must have no space before its unit (e.g. `500mm`). For that last case
build the number and the unit text from a single source so they cannot drift.

### R4 — Name the unit at every strip boundary

When a value must leave Unitful, name the unit at the boundary and re-attach it
on the way back:

```julia
_d  = ustrip(u"mm", d)                            # out: explicit mm
Ag  = pyconvert(Float64, sec.get_area()) * mm^2   # back: re-attach
```

### R5 — One unit system per external call

Python round-trips (sectionproperties / concreteproperties) are fed **mm, N, MPa,
N·mm** here. Never mix a `u"mm"`-stripped value with a bare number computed in
metres.
