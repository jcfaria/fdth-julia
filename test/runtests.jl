using Test
using Fdth

@testset "Fdth.jl" begin
    @testset "fdt numerical stub" begin
        t = fdt([1, 2, 3, 4, 5]; k=2)
        @test t isa NumericalFDT
        @test length(t) == 2
        @test sum(t.counts) == 5

        t1 = fdt([7, 7, 7])
        @test length(t1) == 1
        @test t1.counts == [3]
    end
end
