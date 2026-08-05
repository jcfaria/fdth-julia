"""
    MultipleFDT

Container of named frequency tables (R `fdt.multiple` / Python `MultipleFDT`).
"""
struct MultipleFDT <: AbstractFDT
    names::Vector{String}
    tables::Dict{String,AbstractFDT}
end

Base.length(m::MultipleFDT) = length(m.names)
Base.keys(m::MultipleFDT) = m.names
Base.haskey(m::MultipleFDT, k) = haskey(m.tables, string(k))
Base.getindex(m::MultipleFDT, k) = m.tables[string(k)]
Base.iterate(m::MultipleFDT, state=1) =
    state > length(m.names) ? nothing :
    ((m.names[state] => m.tables[m.names[state]]), state + 1)

"""Build one FDT from a column (numeric → numerical, otherwise categorical)."""
function _fdt_column(col::AbstractVector; kwargs...)
    if _is_numeric_column(col)
        return fdt(col; kwargs...)
    else
        cat_kw = _filter_cat_kwargs(kwargs)
        return fdt_cat(col; cat_kw...)
    end
end

function _is_numeric_column(col::AbstractVector)
    T = nonmissingtype(eltype(col))
    if T <: Real
        return true
    end
    # duck-typed: all non-missing values finite numbers?
    seen = false
    for x in col
        ismissing(x) && continue
        seen = true
        x isa Real && isfinite(float(x)) || return false
    end
    return seen
end

function _filter_num_kwargs(kwargs)
    skip = (:sort, :decreasing, :kind, :by, :colnames)
    return (; (k => v for (k, v) in pairs(kwargs) if !(k in skip))...)
end

function _filter_cat_kwargs(kwargs)
    keep = (:sort, :decreasing)
    return (; (k => v for (k, v) in pairs(kwargs) if k in keep)...)
end

"""
    fdt(X::AbstractMatrix; colnames=nothing, by=nothing, kwargs...)

One numerical/categorical FDT per column. Optional grouping vector `by`
(same length as `nrows`) produces keys `"level.colname"` (R style).
"""
function fdt(
    X::AbstractMatrix;
    colnames=nothing,
    by=nothing,
    kwargs...,
)
    n, p = size(X)
    names = if colnames === nothing
        ["V$i" for i in 1:p]
    else
        length(colnames) == p || throw(ArgumentError("colnames length must equal number of columns"))
        string.(collect(colnames))
    end

    if by === nothing
        return _multiple_from_columns(names, (X[:, j] for j in 1:p); kwargs...)
    else
        length(by) == n || throw(ArgumentError("`by` length must equal number of rows"))
        return _multiple_grouped(names, X, by; kwargs...)
    end
end

"""
    fdt(cols::AbstractDict; by=nothing, kwargs...)

Column dictionary (name => vector). Values may be numeric or categorical.
"""
function fdt(cols::AbstractDict; by=nothing, kwargs...)
    names = string.(collect(keys(cols)))
    isempty(names) && throw(ArgumentError("fdt: empty column dict"))
    n = length(first(values(cols)))
    all(length(v) == n for v in values(cols)) ||
        throw(ArgumentError("all columns must have the same length"))

    if by === nothing
        return _multiple_from_columns(names, (cols[k] for k in keys(cols)); kwargs...)
    else
        length(by) == n || throw(ArgumentError("`by` length must equal number of rows"))
        # materialize as matrix of columns in `names` order — mixed types: use vectors
        return _multiple_grouped_cols(names, Dict(string(k) => cols[k] for k in keys(cols)), by; kwargs...)
    end
end

function _multiple_from_columns(names, col_iter; kwargs...)
    tables = Dict{String,AbstractFDT}()
    order = String[]
    num_kw = _filter_num_kwargs(kwargs)
    for (name, col) in zip(names, col_iter)
        tables[name] = _is_numeric_column(col) ? fdt(collect(col); num_kw...) :
                       fdt_cat(collect(col); _filter_cat_kwargs(kwargs)...)
        push!(order, name)
    end
    return MultipleFDT(order, tables)
end

function _multiple_grouped(names, X::AbstractMatrix, by; kwargs...)
    levels = unique(by)
    tables = Dict{String,AbstractFDT}()
    order = String[]
    num_kw = _filter_num_kwargs(kwargs)
    for lev in levels
        rows = findall(==(lev), by)
        for (j, name) in enumerate(names)
            key = string(lev, ".", name)
            col = X[rows, j]
            tables[key] = fdt(collect(col); num_kw...)
            push!(order, key)
        end
    end
    return MultipleFDT(order, tables)
end

function _multiple_grouped_cols(names, cols::Dict, by; kwargs...)
    levels = unique(by)
    tables = Dict{String,AbstractFDT}()
    order = String[]
    for lev in levels
        rows = findall(==(lev), collect(by))
        for name in names
            key = string(lev, ".", name)
            col = collect(cols[name])[rows]
            tables[key] = _fdt_column(col; kwargs...)
            push!(order, key)
        end
    end
    return MultipleFDT(order, tables)
end

# Summaries over numerical members
function Statistics.mean(m::MultipleFDT)
    return Dict(n => mean(m[n]) for n in m.names if m[n] isa NumericalFDT)
end

function Statistics.median(m::MultipleFDT)
    return Dict(n => median(m[n]) for n in m.names if m[n] isa NumericalFDT)
end

function Statistics.var(m::MultipleFDT; corrected::Bool=true)
    return Dict(n => var(m[n]; corrected) for n in m.names if m[n] isa NumericalFDT)
end

function Statistics.std(m::MultipleFDT; corrected::Bool=true)
    return Dict(n => std(m[n]; corrected) for n in m.names if m[n] isa NumericalFDT)
end

sd(m::MultipleFDT; corrected::Bool=true) = std(m; corrected)

function mfv(m::MultipleFDT)
    return Dict(n => mfv(m[n]) for n in m.names)
end

function amplitude(m::MultipleFDT)
    return Dict(n => amplitude(m[n]) for n in m.names if m[n] isa NumericalFDT)
end
