using Test
using Fdth
using Statistics

@testset "Fdth.jl" begin
    include("numerical.jl")
    include("summaries.jl")
    include("categorical.jl")
    include("multiple.jl")
    include("display_plots.jl")
end
