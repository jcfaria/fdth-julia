"""
    Fdth

Frequency distribution tables, histograms and polygons for Julia.

A planned port of the R package
[fdth](https://github.com/jcfaria/fdth) and the Python package
[fdth](https://github.com/jcfaria/fdth-python) (`pip install fdth`).

This repository is **local-first** while the API and tests take shape.
"""
module Fdth

export fdt, NumericalFDT

include("types.jl")
include("numerical.jl")

end # module
