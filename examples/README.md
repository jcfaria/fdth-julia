# Examples

Run any script from the package root:

```bash
julia --project=. examples/quickstart.jl
```

| Script | Shows |
| --- | --- |
| `quickstart.jl` | one-page tour of the whole API |
| `numerical_fdt.jl` | numerical table, columns, class limits, missing data |
| `binning_modes.jl` | Sturges / Scott / FD, `k`, `start`+`end`, `h`, `make_fdt` |
| `summaries.jl` | mean, variance, quantiles, `mfv`, `amplitude` on grouped data |
| `categorical_fdt.jl` | ordering, mode, median category, automatic kind detection |
| `multiple_fdt.jl` | one table per column, grouping with `by`, mixed columns |
| `plot_catalogue.jl` | every plot type as plain numbers (no backend needed) |
| `plots_gallery.jl` | figures via the optional `Plots` extension |

`plots_gallery.jl` needs `Plots`:

```bash
julia --project=. -e 'using Pkg; Pkg.add("Plots")'
julia --project=. examples/plots_gallery.jl
```

It writes PNGs to `examples/output/` (git-ignored).

## Plot types

Numerical (13, as in R `plot.fdt`): `fh`, `fp`, `rfh`, `rfp`, `rfph`, `rfpp`,
`d`, `cdh`, `cdp`, `cfh`, `cfp`, `cfph`, `cfpp`.

Categorical (16, as in R `plot.fdt_cat`): bars `fb`, `rfb`, `rfpb`, `cfb`,
`cfpb`; polygons `fp`, `rfp`, `rfpp`, `cfp`, `cfpp`; dotcharts `fd`, `rfd`,
`rfpd`, `cfd`, `cfpd`; Pareto `pa`.
