# Fdth.jl changelog

## Unreleased

- Full plot catalogue: 13 numerical types (R `plot.fdt`) and 16 categorical
  types (R `plot.fdt_cat`), including dotcharts (`fd`, `rfd`, `rfpd`, `cfd`,
  `cfpd`) and the Pareto chart (`pa`)
- `plot_series` now returns a `PlotSeries` (still destructurable as
  `x, y, ylab, style, edges`), with `y2`/`y2lab` for the Pareto line
- `plot_types(t)` lists the codes valid for a table; `plot_series(m::MultipleFDT)`
  returns one series per member and `plot(m)` draws a panel grid
- Cumulative polygons (`cdp`, `cfp`, `cfpp`) are ogives over the class limits
  starting at `(start, 0)`, as in R
- Categorical tables accept the histogram codes (`fh`, `rfh`, `rfph`, `cfh`,
  `cfph`) as aliases of the bar codes, so `:fh` works on mixed containers
- Examples split by concern, plus a plot catalogue and a figure gallery
- Test suite expanded to ~2400 assertions: binning internals, error paths and
  randomised invariants (`test/binning.jl`, `test/errors.jl`, `test/invariants.jl`)

## 0.2.0 — 2026-08-05

- Public repository: [jcfaria/fdth-julia](https://github.com/jcfaria/fdth-julia)
- Numerical FDT with Sturges / Scott / FD, padding, full f/rf/cf columns
- Summaries: `mean`, `median`, `var`, `std`/`sd`, `quantile`, `mfv`, `amplitude`/`ta`
- `make_fdt` rebuild from frequencies
- `fdt_cat` / `CategoricalFDT`
- `MultipleFDT` from matrix / dict / `by`
- Auto kind for non-numeric vectors
- Formatted `summary` / `display` tables
- Optional extensions: Plots.jl, DataFrames.jl
- Golden tests aligned with R/Python fdth
- PT-BR / English project glossary adapted for Julia
- GitHub Actions CI on Julia 1.10 and current stable
- D5 project convention: small/medium files by concern; tests split by feature

## 0.1.0 — 2026-08-05

- Initial skeleton: stub numerical `fdt`
