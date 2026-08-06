using Test
using Fdth
using Random
using Statistics

@testset "Fdth.jl" begin
    include("binning.jl")
    include("numerical.jl")
    include("summaries.jl")
    include("categorical.jl")
    include("multiple.jl")
    include("plots.jl")
    include("display.jl")
    include("errors.jl")
    include("invariants.jl")
end
