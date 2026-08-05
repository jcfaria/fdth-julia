"""
    fdt(x; k=nothing)

Build a frequency distribution table for numerical data `x`.

# Arguments
- `x`: vector of real numbers
- `k`: optional number of classes (default: Sturges' rule)

This is a **minimal stub** so the package loads and tests run. Behaviour will
align progressively with R `fdth` and Python `fdth.fdt`.
"""
function fdt(x::AbstractVector{<:Real}; k::Union{Nothing,Integer}=nothing)
    v = Float64[float(xi) for xi in x if !ismissing(xi) && isfinite(float(xi))]
    isempty(v) && throw(ArgumentError("fdt: no finite observations"))

    n = length(v)
    nclass = something(k, max(1, ceil(Int, log2(n) + 1)))  # Sturges
    lo, hi = extrema(v)
    if lo == hi
        # single point: one unit-width class
        breaks = [lo - 0.5, hi + 0.5]
        return NumericalFDT(breaks, [n])
    end

    edges = range(lo, hi; length=nclass + 1) |> collect
    # force last edge to include max
    edges[end] = hi
    counts = zeros(Int, nclass)
    for xi in v
        # rightmost class closed on the right
        j = searchsortedlast(edges, xi)
        j = clamp(j, 1, nclass)
        if xi == hi
            j = nclass
        end
        counts[j] += 1
    end
    return NumericalFDT(edges, counts)
end

function Base.show(io::IO, t::NumericalFDT)
    println(io, "NumericalFDT with $(length(t)) classes")
    for i in eachindex(t.counts)
        a, b = t.breaks[i], t.breaks[i + 1]
        right = i == length(t.counts) ? "]" : ")"
        println(io, "  [$a, $b$right  f = $(t.counts[i])")
    end
end
