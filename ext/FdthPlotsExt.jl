module FdthPlotsExt

using Fdth
using Plots

"""
    plot(t::NumericalFDT; type=:fh, kwargs...)

Plot a numerical FDT. `type` matches R/Python codes:
`fh`, `fp`, `rfh`, `rfp`, `rfph`, `rfpp`, `d`, `cdh`, `cdp`, `cfh`, `cfp`, `cfph`, `cfpp`.
"""
function Plots.plot(t::Fdth.NumericalFDT; type::Symbol=:fh, kwargs...)
    x, y, ylab, style, edges = Fdth.plot_series(t; type)
    if style === :bar
        # histogram-style bars using class width
        h = t.binning.h
        return bar(
            x,
            y;
            bar_width=0.9 * h,
            xlabel="Class midpoints",
            ylabel=ylab,
            legend=false,
            color=:gray,
            linecolor=:black,
            kwargs...,
        )
    else
        return plot(
            x,
            y;
            seriestype=:path,
            marker=:circle,
            xlabel="Class midpoints",
            ylabel=ylab,
            legend=false,
            kwargs...,
        )
    end
end

function Plots.plot(t::Fdth.CategoricalFDT; type::Symbol=:fh, kwargs...)
    x, y, ylab, style, _ = Fdth.plot_series(t; type)
    if style === :bar
        return bar(
            x,
            y;
            xlabel="Category",
            ylabel=ylab,
            legend=false,
            color=:gray,
            linecolor=:black,
            kwargs...,
        )
    else
        return plot(
            collect(1:length(x)),
            y;
            seriestype=:path,
            marker=:circle,
            xlabel="Category",
            ylabel=ylab,
            legend=false,
            xticks=(1:length(x), x),
            kwargs...,
        )
    end
end

end # module
