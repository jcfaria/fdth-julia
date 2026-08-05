"""
    Fdth

Frequency distribution tables, histograms and polygons for Julia.

A planned port of the R package
[fdth](https://github.com/jcfaria/fdth) and the Python package
[fdth](https://github.com/jcfaria/fdth-python) (`pip install fdth`).

Local-first while the API matures; STATghost is the classroom smoke-test.
Optional integrations: `DataFrames`, `Plots` (package extensions).
"""
module Fdth

using Printf
using Statistics

export fdt, make_fdt, fdt_cat
export NumericalFDT, CategoricalFDT, MultipleFDT
export Binning, BreaksMethod, Sturges, Scott, FD
export mfv, amplitude, ta, sd
export plot_series

include("binning.jl")
include("types.jl")
include("numerical.jl")
include("summaries.jl")
include("categorical.jl")
include("multiple.jl")
include("auto.jl")
include("plot_series.jl")
include("display.jl")

end # module
