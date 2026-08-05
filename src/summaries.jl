"""Midpoints of class intervals."""
midpoints(t::NumericalFDT) = 0.5 .* (t.binning.bins[1:(end - 1)] .+ t.binning.bins[2:end])

"""
    mean(t::NumericalFDT)

Grouped-data mean: `Σ(f · mid) / n`.
"""
function Statistics.mean(t::NumericalFDT)
    return sum(t.counts .* midpoints(t)) / t.n
end

"""
    var(t::NumericalFDT; corrected=true)

Grouped-data variance. Default divisor `n−1` (R/Python).
"""
function Statistics.var(t::NumericalFDT; corrected::Bool=true)
    t.n < 2 && throw(ArgumentError("var: need at least 2 observations"))
    μ = mean(t)
    ss = sum(((m - μ)^2) * f for (m, f) in zip(midpoints(t), t.counts))
    return corrected ? ss / (t.n - 1) : ss / t.n
end

"""
    std(t::NumericalFDT; corrected=true)

Grouped-data standard deviation (`√var`). Alias conceptually of R/Python `sd`.
"""
Statistics.std(t::NumericalFDT; corrected::Bool=true) = sqrt(var(t; corrected))

"""Alias for `std` (R/Python name)."""
sd(t::NumericalFDT; corrected::Bool=true) = std(t; corrected)

"""
    quantile(t::NumericalFDT, pos; by=1)

Grouped-data quantile(s). Python-style API:

- `pos` in `[0, by]` (default `by=1` → positions in `[0,1]`)
- `by=100` → percentiles; `by=4` → quartile indices 1,2,3

Formula: `L + ((n·p − cf_prev)·h) / f_q`.
"""
function Statistics.quantile(t::NumericalFDT, pos::Real; by::Real=1)
    return _grouped_quantile(t, Float64(pos), Float64(by))
end

function Statistics.quantile(t::NumericalFDT, pos::AbstractVector{<:Real}; by::Real=1)
    b = Float64(by)
    return [_grouped_quantile(t, Float64(p), b) for p in pos]
end

function Statistics.median(t::NumericalFDT)
    return quantile(t, 0.5)
end

function _grouped_quantile(t::NumericalFDT, pos::Float64, by::Float64)
    by <= 0 && throw(ArgumentError("by must be positive"))
    p = pos / by
    (0.0 <= p <= 1.0) || throw(ArgumentError("quantile position out of range: $pos / $by = $p"))

    pos_count = t.n * p
    idx = findfirst(c -> pos_count <= c, t.cf)
    idx === nothing && (idx = length(t.cf))

    ll = t.binning.bins[idx]
    h = t.binning.h
    f_q = t.counts[idx]
    f_q == 0 && return ll
    cf_prev = idx == 1 ? 0 : t.cf[idx - 1]
    return ll + ((pos_count - cf_prev) * h) / f_q
end

"""
    mfv(t::NumericalFDT)

Most frequent value(s) / mode(s) from grouped data (can be multimodal).
"""
function mfv(t::NumericalFDT)
    freqs = t.counts
    ymax = maximum(freqs)
    positions = findall(==(ymax), freqs)
    bins = t.binning.bins
    h = t.binning.h
    out = Float64[]
    for pos in positions
        ll = bins[pos]
        cur = Float64(freqs[pos])
        prev = pos == 1 ? 0.0 : Float64(freqs[pos - 1])
        succ = pos == length(freqs) ? 0.0 : Float64(freqs[pos + 1])
        d1 = cur - prev
        d2 = cur - succ
        if d1 + d2 == 0
            push!(out, ll + h / 2)
        else
            push!(out, ll + (d1 / (d1 + d2)) * h)
        end
    end
    return out
end

"""
    amplitude(t::NumericalFDT)

Class range width: `end − start`. Alias: `ta`.
"""
amplitude(t::NumericalFDT) = t.binning.end_ - t.binning.start
const ta = amplitude

"""
    make_fdt(freqs; start, end_, right=false, round_=2)

Rebuild a `NumericalFDT` from class frequencies and limits (R `make.fdt`).
"""
function make_fdt(
    freqs::AbstractVector{<:Integer};
    start::Real,
    end_::Real,
    right::Bool=false,
    round_::Integer=2,
)
    start_f = Float64(start)
    end_f = Float64(end_)
    end_f <= start_f && throw(ArgumentError("end must be greater than start"))
    k = length(freqs)
    k < 1 && throw(ArgumentError("freqs must be non-empty"))
    b = linspace_binning(; k, start=start_f, end_=end_f)
    return make_numerical_fdt(b, freqs; right, round_)
end

"""
    make_fdt(freqs, binning::Binning; right=false, round_=2)

Rebuild from frequencies and a ready-made `Binning` (Python `freqs=` path).
"""
function make_fdt(
    freqs::AbstractVector{<:Integer},
    binning::Binning;
    right::Bool=false,
    round_::Integer=2,
)
    return make_numerical_fdt(binning, freqs; right, round_)
end
