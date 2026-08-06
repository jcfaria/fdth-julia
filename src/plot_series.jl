"""
Backend-agnostic plot series. `plot_series` returns the numbers a plot needs;
the `Plots` extension (or any other backend) turns them into a figure.
"""

"""
    PlotSeries

Data for one FDT plot.

- `x`: class midpoints / class limits (numerical) or categories (categorical)
- `y`: values to draw
- `ylab`: default axis label
- `style`: `:bar`, `:line`, `:dot` or `:pareto`
- `edges`: bin edges (numerical only, `nothing` for categorical)
- `y2` / `y2lab`: secondary series, used by the Pareto chart

Iterating a `PlotSeries` yields `(x, y, ylab, style, edges)`, so
`x, y, ylab, style, edges = plot_series(t)` keeps working.
"""
struct PlotSeries{X}
    x::Vector{X}
    y::Vector{Float64}
    ylab::String
    style::Symbol
    edges::Union{Nothing,Vector{Float64}}
    y2::Union{Nothing,Vector{Float64}}
    y2lab::Union{Nothing,String}
end

function PlotSeries(
    x::AbstractVector,
    y::AbstractVector{<:Real},
    ylab::AbstractString,
    style::Symbol,
    edges=nothing;
    y2=nothing,
    y2lab=nothing,
)
    return PlotSeries(
        collect(x),
        collect(Float64, y),
        String(ylab),
        style,
        edges === nothing ? nothing : collect(Float64, edges),
        y2 === nothing ? nothing : collect(Float64, y2),
        y2lab === nothing ? nothing : String(y2lab),
    )
end

Base.length(::PlotSeries) = 5
Base.getindex(s::PlotSeries, i::Integer) = getfield(s, Int(i))
Base.iterate(s::PlotSeries, i::Int=1) = i > 5 ? nothing : (getfield(s, i), i + 1)

function Base.show(io::IO, s::PlotSeries)
    print(io, "PlotSeries(style=:$(s.style), n=$(length(s.y)), ylab=\"$(s.ylab)\")")
end

"""
    plot_series(t; type=:fh)

Series for one plot type. See `plot_types(t)` for the available codes.
"""
function plot_series end

"""
    plot_types(t)

Plot type codes accepted by `plot_series` for this table, in R/Python order.
"""
function plot_types end
