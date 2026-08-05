module FdthDataFramesExt

using Fdth
using DataFrames

"""
    fdt(df::AbstractDataFrame; by=nothing, kwargs...)

Build a `MultipleFDT` from a DataFrame. Numeric columns → numerical FDT;
others → categorical. Optional `by` is a column name (Symbol/String) used
as grouping factor (R-style keys `"level.column"`).
"""
function Fdth.fdt(df::AbstractDataFrame; by=nothing, kwargs...)
    if by === nothing
        cols = Dict{String,Any}(string(n) => df[!, n] for n in names(df))
        return Fdth.fdt(cols; kwargs...)
    else
        byname = string(by)
        byname in names(df) || throw(ArgumentError("grouping column `$byname` not found"))
        g = df[!, by]
        data_names = [string(n) for n in names(df) if string(n) != byname]
        cols = Dict{String,Any}(n => df[!, n] for n in data_names)
        return Fdth.fdt(cols; by=g, kwargs...)
    end
end

end # module
