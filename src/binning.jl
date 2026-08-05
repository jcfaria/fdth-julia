"""
    BreaksMethod

Rule used to choose the number of classes when `k` is not supplied.
"""
@enum BreaksMethod begin
    Sturges
    Scott
    FD
end

"""
    Binning

Equal-width bin edges and metadata for a numerical FDT
(`start`, `end`, `h`, `k`, `bins`), aligned with Python `fdth.Binning`.
"""
struct Binning
    start::Float64
    end_::Float64
    h::Float64
    k::Int
    bins::Vector{Float64}
end

function Binning(start::Real, end_::Real, h::Real, k::Integer, bins::AbstractVector{<:Real})
    return Binning(Float64(start), Float64(end_), Float64(h), Int(k), collect(Float64, bins))
end

Base.:(==)(a::Binning, b::Binning) =
    a.start == b.start && a.end_ == b.end_ && a.h == b.h && a.k == b.k && a.bins == b.bins

"""Padded data range: `min - |min|/100`, `max + |max|/100` (R/Python)."""
function padded_range(data::AbstractVector{<:Real})
    lo, hi = extrema(data)
    start = lo - abs(lo) / 100
    end_ = hi + abs(hi) / 100
    if start == end_
        # degenerate (e.g. all zeros): fall back to a unit-width window
        start = lo - 0.5
        end_ = hi + 0.5
    end
    return start, end_
end

"""
    linspace_binning(; k, data=nothing, start=nothing, end_=nothing)

Equal-width bins. If `start`/`end_` are omitted, use the padded range of `data`.
"""
function linspace_binning(;
    k::Integer,
    data::Union{Nothing,AbstractVector{<:Real}}=nothing,
    start::Union{Nothing,Real}=nothing,
    end_::Union{Nothing,Real}=nothing,
)
    k = Int(k)
    k < 1 && throw(ArgumentError("k must be ≥ 1"))

    if start === nothing
        data === nothing && throw(ArgumentError("`data` required when `start` is omitted"))
        start, _ = padded_range(data)
    end
    if end_ === nothing
        data === nothing && throw(ArgumentError("`data` required when `end` is omitted"))
        _, end_ = padded_range(data)
    end

    start_f = Float64(start)
    end_f = Float64(end_)
    end_f <= start_f && throw(ArgumentError("end must be greater than start"))

    h = (end_f - start_f) / k
    bins = collect(range(start_f, end_f; length=k + 1))
    return Binning(start_f, end_f, h, k, bins)
end

function from_sturges(data::AbstractVector{<:Real})
    n = length(data)
    n == 0 && throw(ArgumentError("from_sturges: empty data"))
    n == 1 && return linspace_binning(; data, k=1)
    k = max(1, ceil(Int, 1 + log2(n)))
    return linspace_binning(; data, k)
end

function from_scott(data::AbstractVector{<:Real})
    n = length(data)
    n == 0 && throw(ArgumentError("from_scott: empty data"))
    n == 1 && return linspace_binning(; data, k=1)
    # Match Python: population SD (ddof=0). R uses sample SD.
    μ = sum(data) / n
    sd = sqrt(sum(abs2, x - μ for x in data) / n)
    at = maximum(data) - minimum(data)
    (sd == 0 || at == 0) && return linspace_binning(; data, k=1)
    k = max(1, ceil(Int, at / (3.5 * sd / (n^(1 / 3)))))
    return linspace_binning(; data, k)
end

function from_fd(data::AbstractVector{<:Real})
    n = length(data)
    n == 0 && throw(ArgumentError("from_fd: empty data"))
    n == 1 && return linspace_binning(; data, k=1)
    q25, q75 = quantile(data, (0.25, 0.75))
    iqr = q75 - q25
    iqr == 0 && return from_scott(data)
    at = maximum(data) - minimum(data)
    at == 0 && return linspace_binning(; data, k=1)
    k = max(1, ceil(Int, at / (2 * iqr / (n^(1 / 3)))))
    return linspace_binning(; data, k)
end

function binning_from_breaks(data::AbstractVector{<:Real}, method::BreaksMethod)
    method === Sturges && return from_sturges(data)
    method === Scott && return from_scott(data)
    method === FD && return from_fd(data)
    throw(ArgumentError("unknown breaks method: $method"))
end

"""
    resolve_binning(data; start, end_, h, k, breaks)

Parameter modes aligned with Python `Binning.auto` / R `fdt.default`.
"""
function resolve_binning(
    data::AbstractVector{<:Real};
    start::Union{Nothing,Real}=nothing,
    end_::Union{Nothing,Real}=nothing,
    h::Union{Nothing,Real}=nothing,
    k::Union{Nothing,Integer}=nothing,
    breaks::BreaksMethod=Sturges,
)
    all_none = start === nothing && end_ === nothing && h === nothing && k === nothing
    if all_none
        return binning_from_breaks(data, breaks)
    elseif h === nothing && k !== nothing && start === nothing && end_ === nothing
        return linspace_binning(; data, k=Int(k))
    elseif start !== nothing && end_ !== nothing && h === nothing && k === nothing
        r = Float64(end_) - Float64(start)
        kk = max(5, ceil(Int, sqrt(abs(r))))
        return linspace_binning(; k=kk, start=start, end_=end_)
    elseif start !== nothing && end_ !== nothing && h !== nothing && k === nothing
        kk = max(1, ceil(Int, (Float64(end_) - Float64(start)) / Float64(h)))
        return linspace_binning(; k=kk, start=start, end_=end_)
    else
        throw(ArgumentError("invalid combination of start/end/h/k; see R/Python fdt docs"))
    end
end

function format_classes(b::Binning; round_::Integer=2, right::Bool=false)
    left_d, right_d = right ? ('(', ']') : ('[', ')')
    out = String[]
    for i in 1:(length(b.bins) - 1)
        a = round(b.bins[i]; digits=Int(round_))
        c = round(b.bins[i + 1]; digits=Int(round_))
        push!(out, string(left_d, a, ", ", c, right_d))
    end
    return out
end
