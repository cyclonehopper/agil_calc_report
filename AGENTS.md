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
- **Keep the quantity through fractional powers.** `sqrt`, `x^0.5` and `x^(1//3)` work directly on quantities; only an irrational exponent (`x^π`) or a genuine bare-number boundary needs `upreferred` first. Never strip by hand.

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

### R1 — Never strip units; normalise with `upreferred`

`ustrip` and `uconvert` are **banned**. `ustrip` does not convert to SI — it
drops the unit and keeps the number in whatever unit the value happened to be
stored in, so units never cancel. The only permitted normalisation is
`upreferred`, which rewrites the quantity in SI base units and hands back a
plain `Float64` as soon as the result is dimensionless.

```julia
# WRONG — the result depends on how each value happened to be stored
r = ustrip(x) / ustrip(y)        # 0.5u"m" / 500u"mm" → 0.001   (should be 1.0)
r = ustrip(x) * ustrip(y)        # 2u"kN" * 300u"mm" → 600, not 0.6 N·m
r = ustrip(x / y)                # 500u"kN" / 1.0u"MN" → 500.0 (should be 0.5)

# RIGHT — upreferred normalises the ratio and already returns a plain Float64
r = upreferred(x / y)            # 500u"kN" / 1.0u"MN" → 0.5

# RIGHT — products keep their dimensions; keep the Quantity
t = x * y                        # 2u"kN" * 300u"mm" → 0.6 kg m^2 s^-2
```

Every dimensionless result — utilisation `M/(ϕM_s)`, slenderness
`(b/t)·√(f_y/250)`, strain, `a/d`, `I/A`, `k = I/A`, `M/EI` — must be built this
way, or simply left as a `Quantity` and compared/plotted as a quantity.

### R2 — `ustrip` and `uconvert` are banned

- `ustrip(u"mm", x)` and `ustrip(x)` are both forbidden: they keep whichever
  unit the value happened to carry and silently change the number.
- `uconvert` is forbidden too. There is no "convert for display" path — display
  a quantity by interpolating it (R3).
- To express a value in another unit, do the arithmetic inside the unit system
  (`x / 1.0mm`, `x / kNm`) or keep it as a `Quantity`; never convert it to a
  bare number.

### R3 — Display a quantity by interpolating it

Unitful already renders the unit, so stripping only risks the printed unit
disagreeing with the number:

```julia
# WRONG / redundant
"$(ustrip(u"mm", L))mm"    # suffix can drift out of sync with the conversion
"$(ustrip(θ))°"            # prints radians next to a degree sign

# RIGHT
"$L"                       # "500.0 mm"
"$(L |> f2)"               # "500.00 mm"   (rounded via MyUnits.f2, unit retained)
```

`f2`/`fround` from `MyUnits` round the value and re-attach the unit, so the
label carries both. Keep data in the unit you want to print (`x = [1.0, 2.0]m`)
instead of converting at print time.

### R4 — Foreign API boundaries

Only a foreign API that cannot accept a `Quantity` (a Python call, a numeric
solver) may see a bare number. Isolate it in one adapter function that names
the unit it expects, normalises with `upreferred` first, and re-attaches the
unit on return. Never strip inside calculation code.

### R5 — One unit system per foreign call

Python round-trips (sectionproperties / concreteproperties) are fed **mm, N, MPa,
N·mm** here. Never mix a value normalised in one system with a bare number
computed in another.

### Using Unitful — CRITICAL

- **DO NOT USE `uconvert` OR `ustrip` BY ANY MEANS.** Units can be stripped only by normalising with `upreferred`, except when dealing with angles — they have their own rules.
- When a code formula specifies a base unit (e.g. `sqrt(250/Fy)`, where `Fy` must be in `MPa`), then normalise by `upreferred(250/(Fy/MPa))^0.5`.
- **DO NOT STRIP UNITS, BY ALL MEANS** — keep `Unitful` quantities through all calculations.
- **Do not strip units for fractional powers.** `sqrt`, `x^0.5` and `x^(1//3)` all
  work on quantities — Unitful keeps fractional dimensions — so keep the quantity.
  If an irrational exponent (`x^π`) or a bare number is genuinely required,
  normalise with `upreferred` first and use the dimensionless result.
- **Use `MyUnits.jl` and always append units, for example length unit meter as `m` instead of `u"m"`.**
- **Use priority units in `MyUnits.jl`, then in `Unitful.DefaultSymbols`.**
  `MyUnits` must be loaded **after** `Unitful` so its shorthands (`m`, `kPa`, `kN_per_m`, `kNm`, `yr`, `m_per_s`, `f2`, `fround`, etc.) take priority
  (see the module's import list). Do not add `using Unitful` after `using MyUnits`.
  Examples: `γ = 18kN/m^3`, `D = 0.6m`, `Ht = 7.4m`, `p = 50kPa`, `q = 15kN_per_m`.
- All dimensions/forces/pressures are `Unitful` quantities. Never mix raw floats into quantities.
- Rounding helpers from `MyUnits`: `f2(x)` → 2 decimals (`x |> f2`), `fround(x,n)`, `f0/f1/f3`.
  They are **unit-preserving** (round the value, re-attach the unit), so **never decompose a
  quantity to format a label/string** — interpolate the rounded quantity and let
  `Unitful` print the unit:
  `label = " (ϕi=$(ϕi |> f1))"` → `" (ϕi=35.5°)"` when the quantity is stored in `°`
  (angles follow their own rules below). Never `string(ustrip(...))` and never re-attach
  units by hand (`* u"m"`, `* 1°`). Note `round(q; digits=n)` on a `Quantity` is **not** a
  substitute: it errors, or (for dimensionless units like `°`) rounds the SI-base value
  and drops the unit (`round(35.5°; digits=1) == 0.6`).
- **Angles** stored as `Unitful` angles (`θR = 29°`, `δ = 30°`). **DO NOT** output angle results as radians.
- **Julia trig functions are unit-aware — DO NOT convert angles to rad manually.**
  `sin`, `cos`, `tan`, `sind`, `cosd`, `tand` etc. accept `Unitful` angle Quantities and
  return the correct value whether the input is `°` or `rad` (`sin(30°) = 0.5`). Never
  write `sin(ustrip(u"rad", x))` / `_to_rad(x)`-style conversions — keep the Quantity.
  CAUTION with **inverse** trig: `asin`, `acos`, `atan` return a **bare rad Float64 with
  no units attached**, and `asind`/`acosd`/`atand` return bare degrees (also no units).
  Before mixing an inverse-trig result back into angle arithmetic, re-attach units
  (`uconvert(°, asin(x))`), because a bare Float64 added to a `°` Quantity is interpreted
  as **rad** and silently corrupts the result.
- Vectors that carry `Unitful` for Plots must be **typed** (e.g. `typeof(1.0m)[]`, `typeof(1.0kPa)[]`) to avoid `Vector{Any}` `DimensionError` in `Plots.jl` `UnitfulExt`.
