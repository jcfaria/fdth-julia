"""Plot series for numerical tables (R `plot.fdt`, 13 types)."""

# type code => (value column, style)
const _NUM_PLOT_TYPES = (
    fh=(:f, :bar),
    fp=(:f, :line),
    rfh=(:rf, :bar),
    rfp=(:rf, :line),
    rfph=(:rfp, :bar),
    rfpp=(:rfp, :line),
    d=(:dens, :bar),
    cdh=(:cdens, :bar),
    cdp=(:cdens, :line),
    cfh=(:cf, :bar),
    cfp=(:cf, :line),
    cfph=(:cfp, :bar),
    cfpp=(:cfp, :line),
)

const _NUM_PLOT_LABELS = (
    f="Frequency",
    rf="Relative frequency",
    rfp="Relative frequency (%)",
    dens="Density",
    cdens="Cumulative density",
    cf="Cumulative frequency",
    cfp="Cumulative frequency (%)",
)

const _NUM_CUMULATIVE = (:cf, :cfp, :cdens)

plot_types(::NumericalFDT) = collect(keys(_NUM_PLOT_TYPES))

function _num_values(t::NumericalFDT, col::Symbol)
    col === :f && return Float64.(t.counts)
    col === :rf && return copy(t.rf)
    col === :rfp && return copy(t.rfp)
    col === :dens && return t.rf ./ t.binning.h
    col === :cdens && return t.cf ./ (t.n * t.binning.h)
    col === :cf && return Float64.(t.cf)
    col === :cfp && return copy(t.cfp)
    throw(ArgumentError("unknown value column: $col"))
end

"""
    plot_series(t::NumericalFDT; type=:fh)

Series for a numerical FDT plot: `fh`, `fp`, `rfh`, `rfp`, `rfph`, `rfpp`,
`d`, `cdh`, `cdp`, `cfh`, `cfp`, `cfph`, `cfpp`.

Cumulative polygons (`cdp`, `cfp`, `cfpp`) are ogives: they follow R and start
at `(start, 0)`, so they carry `k + 1` points over the class limits.
"""
function plot_series(t::NumericalFDT; type::Symbol=:fh)
    haskey(_NUM_PLOT_TYPES, type) || throw(
        ArgumentError(
            "unknown plot type: $type (use $(join(plot_types(t), ", ")))",
        ),
    )
    col, style = _NUM_PLOT_TYPES[type]
    ylab = _NUM_PLOT_LABELS[col]
    y = _num_values(t, col)
    edges = t.binning.bins

    if style === :line && col in _NUM_CUMULATIVE
        return PlotSeries(edges, vcat(0.0, y), ylab, :line, edges)
    end
    return PlotSeries(midpoints(t), y, ylab, style, edges)
end
