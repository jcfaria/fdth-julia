# Fdth.jl — Frequency distribution tables for Julia

**Local development repository** for a Julia port of:

| Language | Project |
|----------|---------|
| R | [jcfaria/fdth](https://github.com/jcfaria/fdth) (CRAN) |
| Python | [jcfaria/fdth-python](https://github.com/jcfaria/fdth-python) (`pip install fdth`) |
| Julia | [jcfaria/fdth-julia](https://github.com/jcfaria/fdth-julia) (`Fdth`) — GitHub public; Julia General later |

Target classroom / **STATghost** validation. Public GitHub: [jcfaria/fdth-julia](https://github.com/jcfaria/fdth-julia). Julia General registry after CI stays green.

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

See [`NEWS.md`](NEWS.md) and [`w_todo/`](w_todo/).

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
- `end_` = upper class limit (`end` is reserved).
- Plots & DataFrames are **optional extensions** (core stays light for STATghost).
- License: GPL-2.0.

## Author / Maintainer

**Faria, J. C.** — UESC / DCEX — Ilhéus, Bahia, Brazil  
joseclaudio.faria@gmail.com
