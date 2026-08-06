module FdthPlotsExt

using Fdth
using Plots

const _GRAY = :gray

"""
    plot(t::NumericalFDT; type=:fh, kwargs...)

Plot a numerical FDT. `type` matches the R/Python codes: `fh`, `fp`, `rfh`,
`rfp`, `rfph`, `rfpp`, `d`, `cdh`, `cdp`, `cfh`, `cfp`, `cfph`, `cfpp`.
Cumulative polygons are drawn as ogives over the class limits.
"""
function Plots.plot(t::Fdth.NumericalFDT; type::Symbol=:fh, kwargs...)
    s = Fdth.plot_series(t; type=type)
    if s.style === :bar
        return bar(
            s.x,
            s.y;
            bar_width=0.9 * t.binning.h,
            xlabel="Class limits",
            ylabel=s.ylab,
            legend=false,
            color=_GRAY,
            linecolor=:black,
            kwargs...,
        )
    end
    return plot(
        s.x,
        s.y;
        seriestype=:path,
        marker=:circle,
        xlabel="Class limits",
        ylabel=s.ylab,
        legend=false,
        color=_GRAY,
        kwargs...,
    )
end

"""
    plot(t::CategoricalFDT; type=:fb, kwargs...)

Plot a categorical FDT: bars (`fb`, `rfb`, `rfpb`, `cfb`, `cfpb`), polygons
(`fp`, `rfp`, `rfpp`, `cfp`, `cfpp`), dotcharts (`fd`, `rfd`, `rfpd`, `cfd`,
`cfpd`) and the Pareto chart (`pa`).
"""
function Plots.plot(t::Fdth.CategoricalFDT; type::Symbol=:fb, kwargs...)
    s = Fdth.plot_series(t; type=type)
    s.style === :bar && return _cat_bar(s; kwargs...)
    s.style === :dot && return _cat_dot(s; kwargs...)
    s.style === :pareto && return _cat_pareto(s; kwargs...)
    return _cat_polygon(s; kwargs...)
end

function _cat_bar(s; kwargs...)
    return bar(
        s.x,
        s.y;
        xlabel="Category",
        ylabel=s.ylab,
        legend=false,
        color=_GRAY,
        linecolor=:black,
        kwargs...,
    )
end

function _cat_polygon(s; kwargs...)
    idx = collect(1:length(s.x))
    return plot(
        idx,
        s.y;
        seriestype=:path,
        marker=:circle,
        xlabel="Category",
        ylabel=s.ylab,
        legend=false,
        color=_GRAY,
        xticks=(idx, s.x),
        kwargs...,
    )
end

function _cat_dot(s; kwargs...)
    idx = collect(1:length(s.x))
    return scatter(
        s.y,
        idx;
        xlabel=s.ylab,
        ylabel="Category",
        legend=false,
        color=_GRAY,
        yticks=(idx, s.x),
        kwargs...,
    )
end

function _cat_pareto(s; kwargs...)
    p = bar(
        s.x,
        s.y;
        xlabel="Category",
        ylabel=s.ylab,
        legend=false,
        color=_GRAY,
        linecolor=:black,
        kwargs...,
    )
    cf = s.y2
    cf === nothing && return p
    plot!(
        twinx(p),
        collect(1:length(s.x)),
        cf;
        seriestype=:path,
        marker=:circle,
        ylabel=something(s.y2lab, "Cumulative frequency"),
        ylims=(0, maximum(cf) * 1.1),
        legend=false,
        color=:black,
    )
    return p
end

"""
    plot(m::MultipleFDT; type=:fh, kwargs...)

Grid of plots, one panel per member table.
"""
function Plots.plot(m::Fdth.MultipleFDT; type::Symbol=:fh, kwargs...)
    panels = [plot(m[name]; type=type, title=name) for name in m.names]
    ncols = min(2, length(panels))
    nrows = ceil(Int, length(panels) / ncols)
    return plot(panels...; layout=(nrows, ncols), kwargs...)
end

end # module
