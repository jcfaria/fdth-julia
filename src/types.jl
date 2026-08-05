"""Minimal FDT types (stubs — to grow toward R/Python parity)."""

abstract type AbstractFDT end

"""
    NumericalFDT

Frequency distribution table for a numerical variable.
Fields will expand (breaks, counts, relative/cumulative frequencies, …).
"""
struct NumericalFDT <: AbstractFDT
    breaks::Vector{Float64}
    counts::Vector{Int}
end

Base.length(t::NumericalFDT) = length(t.counts)
