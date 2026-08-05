"""
Plotting helpers (backend-agnostic series). Used by the Plots.jl extension.
"""

"""Series for a numerical FDT plot. Returns (x, y, kind_label)."""
function plot_series(t::NumericalFDT; type::Symbol=:fh)
    mids = midpoints(t)
    edges = t.binning.bins
    h = t.binning.h
    n = t.n
    f = Float64.(t.counts)
    rf = t.rf
    rfp = t.rfp
    cf = Float64.(t.cf)
    cfp = t.cfp
    dens = rf ./ h
    cdens = cf ./ (n * h)

    type === :fh && return (mids, f, "Frequency", :bar, edges)
    type === :fp && return (mids, f, "Frequency", :line, edges)
    type === :rfh && return (mids, rf, "Relative frequency", :bar, edges)
    type === :rfp && return (mids, rf, "Relative frequency", :line, edges)
    type === :rfph && return (mids, rfp, "Relative frequency (%)", :bar, edges)
    type === :rfpp && return (mids, rfp, "Relative frequency (%)", :line, edges)
    type === :d && return (mids, dens, "Density", :bar, edges)
    type === :cdh && return (mids, cdens, "Cumulative density", :bar, edges)
    type === :cdp && return (mids, cdens, "Cumulative density", :line, edges)
    type === :cfh && return (mids, cf, "Cumulative frequency", :bar, edges)
    type === :cfp && return (mids, cf, "Cumulative frequency", :line, edges)
    type === :cfph && return (mids, cfp, "Cumulative frequency (%)", :bar, edges)
    type === :cfpp && return (mids, cfp, "Cumulative frequency (%)", :line, edges)
    throw(ArgumentError("unknown plot type: $type (use fh, fp, rfh, rfp, rfph, rfpp, d, cdh, cdp, cfh, cfp, cfph, cfpp)"))
end

function plot_series(t::CategoricalFDT; type::Symbol=:fh)
    x = t.categories
    f = Float64.(t.counts)
    type === :fh && return (x, f, "Frequency", :bar, nothing)
    type === :fp && return (x, f, "Frequency", :line, nothing)
    type === :rfh && return (x, t.rf, "Relative frequency", :bar, nothing)
    type === :rfp && return (x, t.rf, "Relative frequency", :line, nothing)
    type === :rfph && return (x, t.rfp, "Relative frequency (%)", :bar, nothing)
    type === :rfpp && return (x, t.rfp, "Relative frequency (%)", :line, nothing)
    type === :cfh && return (x, Float64.(t.cf), "Cumulative frequency", :bar, nothing)
    type === :cfp && return (x, Float64.(t.cf), "Cumulative frequency", :line, nothing)
    type === :cfph && return (x, t.cfp, "Cumulative frequency (%)", :bar, nothing)
    type === :cfpp && return (x, t.cfp, "Cumulative frequency (%)", :line, nothing)
    throw(ArgumentError("unknown categorical plot type: $type"))
end
