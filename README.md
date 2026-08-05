# Fdth.jl — Frequency distribution tables for Julia

Public repository for a Julia port of:

| Language | Project |
|----------|---------|
| R | [jcfaria/fdth](https://github.com/jcfaria/fdth) (CRAN) |
| Python | [jcfaria/fdth-python](https://github.com/jcfaria/fdth-python) (`pip install fdth`) |
| Julia | [jcfaria/fdth-julia](https://github.com/jcfaria/fdth-julia) (`Fdth`) — GitHub public; Julia General later |

Target classroom / **STATghost** validation. Julia General registration follows green CI.

## Status

Local **`0.2.0`** — teachable core ready for **final STATghost** testing:

| API | Role |
|-----|------|
| `fdt` | numerical, auto categorical, matrix/dict → `MultipleFDT` |
| `fdt_cat` / `make_fdt` | categorical / rebuild |
| `mean` … `mfv` / `amplitude` | grouped summaries |
| `summary` / `display` | formatted classroom tables |
| `plot_series` / `plot` | Plots.jl extension |
| `fdt(df; by=…)` | DataFrames.jl extension |

See [`NEWS.md`](NEWS.md), [`w_todo/`](w_todo/), and glossary [`acronyms/`](acronyms/).

## Develop

```julia
julia --project=.
```

```julia
using Pkg; Pkg.instantiate(); Pkg.test()
using Fdth, Statistics
t = fdt([1, 2, 6, 8, 10])
mean(t), sd(t), mfv(t)

# multiple + grouping
fdt([1 10; 2 20; 3 30]; colnames=["x","y"], by=["A","A","B"])

# optional
# using Plots; plot(t; type=:fh)
# using DataFrames; fdt(df; by=:group)
```

```text
julia --project=. examples/quickstart.jl
```

## Design notes

- Julia idioms (multiple dispatch); R/Python examples as behavioural reference.
- Small/medium files grouped by concern (STATghost-style); `Fdth.jl` stays a thin include/export hub.
- `end_` = upper class limit (`end` is reserved).
- Plots & DataFrames are **optional extensions** (core stays light for STATghost).

---

## Author / Maintainer

**Faria, J. C.**  
Universidade Estadual de Santa Cruz — UESC  
Departamento de Ciências Exatas — DCEX  
Ilhéus — Bahia — Brazil

- Email: [joseclaudio.faria@gmail.com](mailto:joseclaudio.faria@gmail.com)
- GitHub: [jcfaria](https://github.com/jcfaria)
- R package: [GitHub](https://github.com/jcfaria/fdth) · [CRAN](https://cran.r-project.org/package=fdth)
- Python package: [GitHub](https://github.com/jcfaria/fdth-python) · [PyPI](https://pypi.org/project/fdth/)
- Julia package: [GitHub](https://github.com/jcfaria/fdth-julia)

---

## License

This package is free software under the
**GNU General Public License, version 2** (**GPL-2.0**).

See [LICENSE](LICENSE) for the full text.
