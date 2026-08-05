"""
    fdt_cat(x; sort=true, decreasing=false)

Categorical frequency distribution table (R `fdt_cat` / Python `CategoricalFDT`).
"""
function fdt_cat(
    x::AbstractVector;
    sort::Bool=true,
    decreasing::Bool=false,
)
    isempty(x) && throw(ArgumentError("fdt_cat: empty data"))
    # Drop missing
    vals = [xi for xi in x if !ismissing(xi)]
    isempty(vals) && throw(ArgumentError("fdt_cat: no non-missing observations"))

    # Preserve first-seen order, then optionally sort by frequency
    order = unique(vals)
    freq_map = Dict{eltype(order),Int}()
    for v in vals
        freq_map[v] = get(freq_map, v, 0) + 1
    end
    cats = collect(order)
    freqs = [freq_map[c] for c in cats]

    if sort
        perm = sortperm(freqs; rev=decreasing)
        cats = cats[perm]
        freqs = freqs[perm]
    end

    return make_categorical_fdt(cats, freqs)
end

"""
    fdt_cat(freqs::AbstractDict; sort=true, decreasing=false)

Build from a category → frequency map.
"""
function fdt_cat(
    freqs::AbstractDict;
    sort::Bool=true,
    decreasing::Bool=false,
)
    isempty(freqs) && throw(ArgumentError("fdt_cat: empty freqs"))
    cats = collect(keys(freqs))
    counts = Int[freqs[c] for c in cats]
    if sort
        perm = sortperm(counts; rev=decreasing)
        cats = cats[perm]
        counts = counts[perm]
    end
    return make_categorical_fdt(cats, counts)
end

function make_categorical_fdt(cats::AbstractVector, counts::AbstractVector{<:Integer})
    length(cats) == length(counts) || throw(ArgumentError("categories and counts length mismatch"))
    n = sum(counts)
    n == 0 && throw(ArgumentError("fdt_cat: total frequency is zero"))
    f = Int.(counts)
    rf = f ./ n
    rfp = rf .* 100
    cf = cumsum(f)
    cfp = cf ./ n .* 100
    # STATghost / classroom: labels as String for a stable printable API
    return CategoricalFDT(String[string(c) for c in cats], f, rf, rfp, cf, cfp, n)
end

function Statistics.mean(::CategoricalFDT)
    throw(ArgumentError("CategoricalFDT does not have a mean"))
end

function Statistics.var(::CategoricalFDT; kwargs...)
    throw(ArgumentError("CategoricalFDT does not have variance"))
end

function Statistics.std(::CategoricalFDT; kwargs...)
    throw(ArgumentError("CategoricalFDT does not have standard deviation"))
end

sd(t::CategoricalFDT; kwargs...) = std(t; kwargs...)

"""Median category (first class whose cumulative frequency reaches n/2)."""
function Statistics.median(t::CategoricalFDT)
    isempty(t.categories) && throw(ArgumentError("empty CategoricalFDT"))
    pos_count = t.n * 0.5
    idx = findfirst(c -> c >= pos_count, t.cf)
    idx === nothing && (idx = length(t.cf))
    return t.categories[idx]
end

"""Most frequent categor(y/ies)."""
function mfv(t::CategoricalFDT)
    ymax = maximum(t.counts)
    return t.categories[findall(==(ymax), t.counts)]
end
