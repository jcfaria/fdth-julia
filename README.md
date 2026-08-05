# Fdth.jl — Frequency distribution tables for Julia

**Local development repository** for a Julia port of:

| Language | Project |
|----------|---------|
| R | [jcfaria/fdth](https://github.com/jcfaria/fdth) (CRAN) |
| Python | [jcfaria/fdth-python](https://github.com/jcfaria/fdth-python) (`pip install fdth`) |
| Julia | **this repo** (`Fdth`) — not published yet |

## Status

Early skeleton (`0.1.0`):

- Package module `Fdth`
- Stub `fdt(::AbstractVector{<:Real})` → `NumericalFDT` (Sturges / optional `k`)
- Basic tests

Roadmap (high level): categorical FDT, multi-column / grouping, plots, summary measures, parity checks against R and Python examples.

## Develop

```julia
# from the repository root
julia --project=.
```

```julia
using Pkg
Pkg.instantiate()   # when dependencies are added
Pkg.test()
using Fdth
fdt([1, 2, 3, 4, 5]; k=2)
```

Quick example:

```text
julia --project=. examples/quickstart.jl
```

## Design notes

- Prefer Julia idioms (multiple dispatch) over a 1:1 copy of the Python classes.
- Use R `examples/` and Python `examples/` as behavioural references.
- License: GPL-2.0 (same family as R/Python **fdth**).

## Author / Maintainer

**Faria, J. C.** — UESC / DCEX — Ilhéus, Bahia, Brazil  
joseclaudio.faria@gmail.com
