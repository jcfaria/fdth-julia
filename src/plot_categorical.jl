"""Plot series for categorical tables (R `plot.fdt_cat`, 16 types)."""

# type code => (value column, style): b=bar, p=polygon, d=dotchart, pa=Pareto
const _CAT_PLOT_TYPES = (
    fb=(:f, :bar),
    fp=(:f, :line),
    fd=(:f, :dot),
    rfb=(:rf, :bar),
    rfp=(:rf, :line),
    rfd=(:rf, :dot),
    rfpb=(:rfp, :bar),
    rfpp=(:rfp, :line),
    rfpd=(:rfp, :dot),
    cfb=(:cf, :bar),
    cfp=(:cf, :line),
    cfd=(:cf, :dot),
    cfpb=(:cfp, :bar),
    cfpp=(:cfp, :line),
    cfpd=(:cfp, :dot),
    pa=(:f, :pareto),
)

# tolerate the numerical histogram codes on categorical tables
const _CAT_PLOT_ALIASES = (fh=:fb, rfh=:rfb, rfph=:rfpb, cfh=:cfb, cfph=:cfpb)

const _CAT_PLOT_LABELS = (
    f="Frequency",
    rf="Relative frequency",
    rfp="Relative frequency (%)",
    cf="Cumulative frequency",
    cfp="Cumulative frequency (%)",
)

plot_types(::CategoricalFDT) = collect(keys(_CAT_PLOT_TYPES))

function _cat_values(t::CategoricalFDT, col::Symbol)
    col === :f && return Float64.(t.counts)
    col === :rf && return copy(t.rf)
    col === :rfp && return copy(t.rfp)
    col === :cf && return Float64.(t.cf)
    col === :cfp && return copy(t.cfp)
    throw(ArgumentError("unknown value column: $col"))
end

"""
    plot_series(t::CategoricalFDT; type=:fb)

Series for a categorical FDT plot. Codes follow R/Python: bars (`fb`, `rfb`,
`rfpb`, `cfb`, `cfpb`), polygons (`fp`, `rfp`, `rfpp`, `cfp`, `cfpp`),
dotcharts (`fd`, `rfd`, `rfpd`, `cfd`, `cfpd`) and the Pareto chart (`pa`).

`pa` carries the cumulative frequency in `y2`; as in R it uses the table order,
so build it with `fdt_cat(x; decreasing=true)` for a textbook Pareto chart.
"""
function plot_series(t::CategoricalFDT; type::Symbol=:fb)
    code = haskey(_CAT_PLOT_ALIASES, type) ? _CAT_PLOT_ALIASES[type] : type
    haskey(_CAT_PLOT_TYPES, code) || throw(
        ArgumentError(
            "unknown categorical plot type: $type (use $(join(plot_types(t), ", ")))",
        ),
    )
    col, style = _CAT_PLOT_TYPES[code]
    y = _cat_values(t, col)

    if style === :pareto
        return PlotSeries(
            t.categories,
            y,
            _CAT_PLOT_LABELS[col],
            :pareto,
            nothing;
            y2=Float64.(t.cf),
            y2lab="Cumulative frequency, (%)",
        )
    end
    return PlotSeries(t.categories, y, _CAT_PLOT_LABELS[col], style, nothing)
end
