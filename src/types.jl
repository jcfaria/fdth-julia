"""FDT types — growing toward R/Python parity."""

abstract type AbstractFDT end

"""
    NumericalFDT

Frequency distribution table for a numerical variable.

Columns mirror R/Python: class limits, `f`, `rf`, `rf(%)`, `cf`, `cf(%)`.
"""
struct NumericalFDT <: AbstractFDT
    binning::Binning
    classes::Vector{String}
    counts::Vector{Int}          # f
    rf::Vector{Float64}
    rfp::Vector{Float64}         # rf(%)
    cf::Vector{Int}
    cfp::Vector{Float64}         # cf(%)
    right::Bool
    n::Int
end

Base.length(t::NumericalFDT) = length(t.counts)

"""
    CategoricalFDT

Frequency distribution table for a categorical variable.
"""
struct CategoricalFDT <: AbstractFDT
    categories::Vector{String}
    counts::Vector{Int}
    rf::Vector{Float64}
    rfp::Vector{Float64}
    cf::Vector{Int}
    cfp::Vector{Float64}
    n::Int
end

Base.length(t::CategoricalFDT) = length(t.counts)

"""Backward-compatible access to bin edges on numerical tables."""
function Base.getproperty(t::NumericalFDT, name::Symbol)
    name === :breaks && return getfield(t, :binning).bins
    return getfield(t, name)
end
