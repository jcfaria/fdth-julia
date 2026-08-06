@testset "categorical" begin
    @testset "sorting" begin
        x = ["b", "a", "b", "c", "b", "a"]

        tdec = fdt_cat(x; sort=true, decreasing=true)
        @test tdec isa CategoricalFDT
        @test tdec.categories == ["b", "a", "c"]
        @test tdec.counts == [3, 2, 1]

        tasc = fdt_cat(x; sort=true, decreasing=false)
        @test tasc.categories == ["c", "a", "b"]
        @test tasc.counts == [1, 2, 3]

        # sort=false keeps first-seen order
        traw = fdt_cat(x; sort=false)
        @test traw.categories == ["b", "a", "c"]
        @test traw.counts == [3, 2, 1]
    end

    @testset "frequency columns" begin
        t = fdt_cat(["b", "a", "b", "c", "b", "a"]; decreasing=true)
        @test length(t) == 3
        @test t.n == 6
        @test sum(t.counts) == 6
        @test sum(t.rf) ≈ 1
        @test t.rfp ≈ t.rf .* 100
        @test t.cf == cumsum(t.counts)
        @test t.cfp[end] ≈ 100
    end

    @testset "summaries" begin
        t = fdt_cat(["b", "a", "b", "c", "b", "a"]; decreasing=true)
        @test median(t) == "b"
        @test mfv(t) == ["b"]
        @test_throws ArgumentError mean(t)

        # every category tied → all are modes
        tied = fdt_cat(["a", "b", "c"])
        @test length(mfv(tied)) == 3
    end

    @testset "missing and dict input" begin
        t = fdt_cat(["a", missing, "b", "a"])
        @test t.n == 3
        @test t.categories == ["b", "a"]
        @test t.counts == [1, 2]

        td = fdt_cat(Dict("x" => 2, "y" => 5); decreasing=true)
        @test td.categories[1] == "y"
        @test td.counts == [5, 2]

        # non-string keys become printable labels
        ti = fdt_cat(Dict(1 => 2, 2 => 3))
        @test ti.categories == ["1", "2"]
        @test ti.counts == [2, 3]
    end

    @testset "auto kind" begin
        @test fdt(["a", "b", "a"]) isa CategoricalFDT
        @test fdt([1, 2, 3]; kind=:categorical) isa CategoricalFDT
        @test fdt([1.0, 2.0, 3.0]) isa NumericalFDT
        @test fdt(Any[1, 2, 6, 8, 10]) isa NumericalFDT
        @test fdt(["a", "b", "a"]; kind=:auto, decreasing=true).categories[1] == "a"

        # loosely typed numeric column with missing
        mixed = Any[1, 2, missing, 8, 10]
        @test sum(fdt(mixed; na_rm=true, k=2).counts) == 4
        @test_throws ArgumentError fdt(mixed; na_rm=false)
    end
end
