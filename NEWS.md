# Fdth.jl changelog

## 0.2.0 — 2026-08-05

- Public repository: https://github.com/jcfaria/fdth-julia
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
