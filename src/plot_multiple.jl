"""Plot series for `MultipleFDT` (R `plot.fdt.multiple` / `plot.fdt_cat.multiple`)."""

"""
    plot_series(m::MultipleFDT; type=:fh)

One `PlotSeries` per member table, in insertion order. Categorical members
accept the histogram codes as aliases, so the default `:fh` works on mixed
containers.
"""
function plot_series(m::MultipleFDT; type::Symbol=:fh)
    return [name => plot_series(m[name]; type=type) for name in m.names]
end

_accepted_plot_types(t::NumericalFDT) = plot_types(t)
_accepted_plot_types(t::CategoricalFDT) =
    vcat(plot_types(t), collect(keys(_CAT_PLOT_ALIASES)))

"""Plot type codes accepted by every member table."""
function plot_types(m::MultipleFDT)
    isempty(m.names) && return Symbol[]
    common = _accepted_plot_types(m[first(m.names)])
    for name in m.names[2:end]
        allowed = _accepted_plot_types(m[name])
        common = [type for type in common if type in allowed]
    end
    return common
end
