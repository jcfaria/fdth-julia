"""Formatted table printing (classroom / STATghost friendly)."""

const _FDT_COL_LABELS = ("Class limits", "f", "rf", "rf(%)", "cf", "cf(%)")
const _CAT_COL_LABELS = ("Category", "f", "rf", "rf(%)", "cf", "cf(%)")

function _fmt_rf(x::Real)
    s = rstrip(rstrip(@sprintf("%.3f", Float64(x)), '0'), '.')
    return isempty(s) || s == "-" ? "0" : s
end

function _fmt_pct(x::Real)
    return @sprintf("%.1f", Float64(x))
end

"""
    summary(t::NumericalFDT; columns=1:6, digits=2)

Formatted frequency table. `columns` selects among
1=Class limits, 2=f, 3=rf, 4=rf(%), 5=cf, 6=cf(%).
"""
function Base.summary(t::NumericalFDT; columns=1:6, digits::Integer=2)
    cols = collect(Int, columns)
    all(1 <= c <= 6 for c in cols) || throw(ArgumentError("columns must be in 1:6"))
    classes = format_classes(t.binning; round_=digits, right=t.right)
    d = Int(digits)
    title = string(
        "NumericalFDT  n=$(t.n)  ",
        "start=$(round(t.binning.start; digits=d))  ",
        "end=$(round(t.binning.end_; digits=d))  ",
        "h=$(round(t.binning.h; digits=d))",
    )
    return _format_fdt_table(
        classes,
        t.counts,
        t.rf,
        t.rfp,
        t.cf,
        t.cfp;
        labels=_FDT_COL_LABELS,
        columns=cols,
        title=title,
    )
end

function Base.summary(t::CategoricalFDT; columns=1:6, digits::Integer=2)
    cols = collect(Int, columns)
    all(1 <= c <= 6 for c in cols) || throw(ArgumentError("columns must be in 1:6"))
    return _format_fdt_table(
        string.(t.categories),
        t.counts,
        t.rf,
        t.rfp,
        t.cf,
        t.cfp;
        labels=_CAT_COL_LABELS,
        columns=cols,
        title="CategoricalFDT  n=$(t.n)",
    )
end

function Base.summary(m::MultipleFDT; kwargs...)
    parts = String["MultipleFDT with $(length(m)) table(s)"]
    for name in m.names
        push!(parts, "")
        push!(parts, "── $name ──")
        push!(parts, summary(m[name]; kwargs...))
    end
    return join(parts, "\n")
end

function _format_fdt_table(
    labels_col::AbstractVector{<:AbstractString},
    f,
    rf,
    rfp,
    cf,
    cfp;
    labels,
    columns::Vector{Int},
    title::AbstractString,
)
    nrows = length(f)
    data = Dict{Int,Vector{String}}()
    data[1] = String[string(labels_col[i]) for i in 1:nrows]
    data[2] = String[string(Int(f[i])) for i in 1:nrows]
    data[3] = String[_fmt_rf(rf[i]) for i in 1:nrows]
    data[4] = String[_fmt_pct(rfp[i]) for i in 1:nrows]
    data[5] = String[string(Int(cf[i])) for i in 1:nrows]
    data[6] = String[_fmt_pct(cfp[i]) for i in 1:nrows]

    widths = Int[]
    mins = (15, 4, 6, 6, 4, 6)
    for c in columns
        w = length(labels[c])
        for row in data[c]
            w = max(w, length(row))
        end
        push!(widths, max(w, mins[c]))
    end

    function fmt_row(vals::Vector{String})
        parts = String[]
        for (j, c) in enumerate(columns)
            s = vals[j]
            if c == 1
                push!(parts, rpad(s, widths[j]))
            else
                push!(parts, lpad(s, widths[j]))
            end
        end
        return join(parts, " ")
    end

    header = fmt_row(String[labels[c] for c in columns])
    rule = "-"^(length(header))
    lines = String[title, header, rule]
    for i in 1:nrows
        push!(lines, fmt_row(String[data[c][i] for c in columns]))
    end
    push!(lines, rule)
    return join(lines, "\n")
end

function Base.show(io::IO, ::MIME"text/plain", t::NumericalFDT)
    print(io, summary(t))
end

function Base.show(io::IO, ::MIME"text/plain", t::CategoricalFDT)
    print(io, summary(t))
end

function Base.show(io::IO, ::MIME"text/plain", m::MultipleFDT)
    print(io, summary(m))
end

function Base.show(io::IO, t::NumericalFDT)
    print(io, "NumericalFDT($(length(t)) classes, n=$(t.n))")
end

function Base.show(io::IO, t::CategoricalFDT)
    print(io, "CategoricalFDT($(length(t)) categories, n=$(t.n))")
end

function Base.show(io::IO, m::MultipleFDT)
    print(io, "MultipleFDT($(length(m)) tables: ", join(m.names, ", "), ")")
end
