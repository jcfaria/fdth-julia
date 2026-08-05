"""
    fdt(x; k=nothing, start=nothing, end_=nothing, h=nothing,
        breaks=Sturges, right=false, na_rm=false, round_=2)

Build a frequency distribution table for numerical data `x`.

Behaviour aligns with R `fdth::fdt` and Python `fdth.fdt` / `NumericalFDT`:

- default number of classes: Sturges (`ceil(1 + log2(n))`)
- optional `breaks`: `Sturges`, `Scott`, or `FD`
- range padding `±|·|/100` when `start`/`end_` are omitted
- columns: class limits, `f`, `rf`, `rf(%)`, `cf`, `cf(%)`

# Arguments
- `x`: vector of real numbers
- `k`: number of classes
- `start`, `end_`, `h`: class limits / width (same modes as R/Python)
- `breaks`: rule when only `x` is given (default `Sturges`)
- `right`: `false` → `[a,b)`; `true` → `(a,b]`
- `na_rm`: drop non-finite values when `true`; error when `false` and any appear
- `round_`: decimal places in class labels
"""
function fdt(
    x::AbstractVector{<:Real};
    k::Union{Nothing,Integer}=nothing,
    start::Union{Nothing,Real}=nothing,
    end_::Union{Nothing,Real}=nothing,
    h::Union{Nothing,Real}=nothing,
    breaks::BreaksMethod=Sturges,
    right::Bool=false,
    na_rm::Bool=false,
    round_::Integer=2,
    kind::Symbol=:numerical,
)
    if kind === :categorical
        return fdt_cat(string.(x))
    elseif kind !== :numerical && kind !== :auto
        throw(ArgumentError("kind must be :auto, :numerical, or :categorical"))
    end

    v = cleanup_numeric(x; na_rm)
    isempty(v) && throw(ArgumentError("fdt: no finite observations"))

    b = resolve_binning(v; start, end_, h, k, breaks)
    counts = hist_counts(v, b.bins; right)
    return make_numerical_fdt(b, counts; right, round_)
end

function cleanup_numeric(x::AbstractVector{<:Real}; na_rm::Bool)
    has_bad = any(xi -> ismissing(xi) || !isfinite(float(xi)), x)
    if has_bad && !na_rm
        throw(ArgumentError("fdt: data has missing/non-finite values and na_rm=false"))
    end
    return Float64[float(xi) for xi in x if !ismissing(xi) && isfinite(float(xi))]
end

"""
Count observations into equal-width bins.

`right=false` → intervals `[a,b)` with the last edge included.
`right=true` → intervals `(a,b]` with the first edge included (`include_lowest`).
"""
function hist_counts(v::AbstractVector{<:Real}, edges::AbstractVector{<:Real}; right::Bool)
    k = length(edges) - 1
    k < 1 && throw(ArgumentError("need at least two edges"))
    counts = zeros(Int, k)
    e1 = edges[1]
    ek = edges[end]

    if right
        for xi in v
            if xi == e1
                counts[1] += 1
                continue
            end
            # (edges[j], edges[j+1]] → j = searchsortedfirst(edges, xi) - 1
            j = searchsortedfirst(edges, xi) - 1
            if 1 <= j <= k
                counts[j] += 1
            end
        end
    else
        for xi in v
            if xi == ek
                counts[k] += 1
                continue
            end
            # [edges[j], edges[j+1])
            j = searchsortedlast(edges, xi)
            if 1 <= j <= k
                counts[j] += 1
            end
        end
    end
    return counts
end

function make_numerical_fdt(
    b::Binning,
    counts::AbstractVector{<:Integer};
    right::Bool=false,
    round_::Integer=2,
)
    length(counts) == b.k || throw(ArgumentError("counts length must equal number of classes"))
    n = sum(counts)
    n == 0 && throw(ArgumentError("fdt: total frequency is zero"))
    f = Int.(counts)
    rf = f ./ n
    rfp = rf .* 100
    cf = cumsum(f)
    cfp = cf ./ n .* 100
    classes = format_classes(b; round_, right)
    return NumericalFDT(b, classes, f, rf, rfp, cf, cfp, right, n)
end
