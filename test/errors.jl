@testset "argument errors" begin
    @testset "binning arguments" begin
        @test_throws ArgumentError Fdth.linspace_binning(; k=0, start=0, end_=1)
        @test_throws ArgumentError Fdth.linspace_binning(; k=2)
        @test_throws ArgumentError Fdth.linspace_binning(; k=2, start=5, end_=5)
        @test_throws ArgumentError Fdth.linspace_binning(; k=2, start=10, end_=1)

        # incomplete / conflicting mode combinations
        x = [1, 2, 3, 4]
        @test_throws ArgumentError Fdth.resolve_binning(x; start=0)
        @test_throws ArgumentError Fdth.resolve_binning(x; end_=10)
        @test_throws ArgumentError Fdth.resolve_binning(x; h=1)
        @test_throws ArgumentError Fdth.resolve_binning(x; k=2, h=1)
    end

    @testset "numerical fdt" begin
        @test_throws ArgumentError fdt(Float64[])
        @test_throws ArgumentError fdt([1.0, Inf]; na_rm=false)
        @test_throws ArgumentError fdt([1, 2, 3]; kind=:nonsense)
        @test_throws ArgumentError fdt([1, 2, 3]; start=0)
    end

    @testset "summaries" begin
        t = fdt([1, 2, 6, 8, 10])
        @test_throws ArgumentError quantile(t, 1.5)
        @test_throws ArgumentError quantile(t, -0.1)
        @test_throws ArgumentError quantile(t, 0.5; by=0)
        @test_throws ArgumentError quantile(t, 0.5; by=-1)

        # variance needs at least two observations
        @test_throws ArgumentError var(fdt([7]))
    end

    @testset "make_fdt" begin
        @test_throws ArgumentError make_fdt(Int[]; start=0, end_=10)
        @test_throws ArgumentError make_fdt([1, 2]; start=10, end_=5)
        @test_throws ArgumentError make_fdt([0, 0]; start=0, end_=10)
    end

    @testset "categorical" begin
        @test_throws ArgumentError fdt_cat(String[])
        @test_throws ArgumentError fdt_cat(Dict{String,Int}())
        @test_throws ArgumentError fdt_cat([missing, missing])

        tc = fdt_cat(["a", "b"])
        @test_throws ArgumentError var(tc)
        @test_throws ArgumentError std(tc)
        @test_throws ArgumentError sd(tc)
    end

    @testset "multiple" begin
        X = [1 2; 3 4]
        @test_throws ArgumentError fdt(X; colnames=["only-one"])
        @test_throws ArgumentError fdt(X; by=["A"])
        @test_throws ArgumentError fdt(Dict{String,Vector{Int}}())
        @test_throws ArgumentError fdt(Dict("a" => [1, 2], "b" => [1, 2, 3]))
    end

    @testset "plots and summary" begin
        t = fdt([1, 2, 6, 8, 10])
        @test_throws ArgumentError plot_series(t; type=:nope)
        @test_throws ArgumentError plot_series(fdt_cat(["a", "b"]); type=:d)
        @test_throws ArgumentError summary(t; columns=[0])
        @test_throws ArgumentError summary(t; columns=[7])
    end
end
