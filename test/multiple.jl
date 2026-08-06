@testset "multiple / by" begin
    X = [1 10; 2 20; 3 30; 4 40; 5 50]

    @testset "matrix columns" begin
        m = fdt(X; k=2, colnames=["x", "y"])
        @test m isa MultipleFDT
        @test length(m) == 2
        @test collect(keys(m)) == ["x", "y"]
        @test m["x"] isa NumericalFDT
        @test sum(m["x"].counts) == 5
        @test haskey(m, "y")
        @test haskey(m, :y)
        @test !haskey(m, "z")

        # default names when colnames is omitted
        mdef = fdt(X; k=2)
        @test collect(keys(mdef)) == ["V1", "V2"]
        @test mdef["V2"].binning.k == 2
    end

    @testset "iteration" begin
        m = fdt(X; k=2, colnames=["x", "y"])
        pairs_ = collect(m)
        @test length(pairs_) == 2
        @test first(pairs_) isa Pair
        @test first(pairs_)[1] == "x"
        @test first(pairs_)[2] === m["x"]
        @test [name for (name, _) in m] == ["x", "y"]
    end

    @testset "grouping with by" begin
        by = ["A", "A", "B", "B", "B"]
        mg = fdt(X; k=2, colnames=["x", "y"], by=by)
        @test length(mg) == 4
        @test "A.x" in keys(mg)
        @test "B.y" in keys(mg)
        @test sum(mg["A.x"].counts) == 2
        @test sum(mg["B.x"].counts) == 3
        @test sum(mg["A.x"].counts) + sum(mg["B.x"].counts) == size(X, 1)

        mgd = fdt(
            Dict("u" => [1, 2, 3, 4], "g" => ["a", "a", "b", "b"]);
            by=["A", "A", "B", "B"],
            k=2,
        )
        @test length(mgd) == 4
        @test mgd["A.u"] isa NumericalFDT
        @test mgd["A.g"] isa CategoricalFDT
        @test mgd["B.g"].categories == ["b"]
    end

    @testset "mixed dict columns" begin
        md = fdt(
            Dict("u" => [1, 2, 3, 4], "g" => ["a", "a", "b", "b"]);
            decreasing=true,
        )
        @test md["u"] isa NumericalFDT
        @test md["g"] isa CategoricalFDT
        @test md["g"].n == 4
    end

    @testset "aggregate summaries" begin
        m = fdt(
            Dict("u" => [1, 2, 3, 4, 5], "g" => ["a", "a", "b", "b", "b"]);
            k=2,
        )
        @test haskey(mean(m), "u")
        @test !haskey(mean(m), "g")
        @test haskey(median(m), "u")
        @test haskey(var(m), "u")
        @test std(m)["u"] ≈ sqrt(var(m)["u"])
        @test sd(m)["u"] ≈ std(m)["u"]
        @test var(m; corrected=false)["u"] < var(m)["u"]
        @test haskey(amplitude(m), "u")
        @test !haskey(amplitude(m), "g")

        # mfv covers categorical members too
        modes = mfv(m)
        @test haskey(modes, "u")
        @test modes["g"] == ["b"]
    end
end
