# Fdth.jl changelog

## 0.2.0 — 2026-08-05

- Numerical FDT with Sturges / Scott / FD, padding, full f/rf/cf columns
- Summaries: `mean`, `median`, `var`, `std`/`sd`, `quantile`, `mfv`, `amplitude`/`ta`
- `make_fdt` rebuild from frequencies
- `fdt_cat` / `CategoricalFDT`
- `MultipleFDT` from matrix / dict / `by`
- Auto kind for non-numeric vectors
- Formatted `summary` / `display` tables
- Optional extensions: Plots.jl, DataFrames.jl
- Golden tests aligned with R/Python fdth

## 0.1.0 — 2026-08-05

- Initial skeleton: stub numerical `fdt`
