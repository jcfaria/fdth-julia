"""
    fdt(x::AbstractVector; kind=:auto, kwargs...)

Auto dispatch for non-`Real` vectors (e.g. strings → categorical).
Numeric `Real` vectors still hit the specialised numerical method.
"""
function fdt(x::AbstractVector; kind::Symbol=:auto, kwargs...)
    if kind === :categorical || (kind === :auto && !_is_numeric_column(x))
        return fdt_cat(x; _filter_cat_kwargs(kwargs)...)
    elseif kind === :numerical || kind === :auto
        num_kw = _filter_num_kwargs(kwargs)
        v = Float64[
            float(xi) for xi in x if !ismissing(xi) && (xi isa Real) && isfinite(float(xi))
        ]
        # Honour na_rm like the numerical path when mixed/missing
        na_rm = get(num_kw, :na_rm, false)
        if !na_rm
            for xi in x
                if ismissing(xi) || !(xi isa Real) || !isfinite(float(xi))
                    # allow pure numeric Real vectors to use specialised method instead;
                    # here we only reach for poorly typed columns
                    if ismissing(xi) || (xi isa Real && !isfinite(float(xi)))
                        throw(ArgumentError("fdt: data has missing/non-finite values and na_rm=false"))
                    end
                end
            end
        end
        return fdt(v; num_kw...)
    else
        throw(ArgumentError("kind must be :auto, :numerical, or :categorical"))
    end
end
