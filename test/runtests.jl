using Test
using Fdth
using Statistics

@testset "Fdth.jl" begin
    @testset "Sturges default + padding" begin
        # Golden: x = [1,2,6,8,10] — R ≡ Python
        t = fdt([1, 2, 6, 8, 10])
        @test t isa NumericalFDT
        @test length(t) == 4
        @test t.binning.start ≈ 0.99
        @test t.binning.end_ ≈ 10.1
        @test t.binning.h ≈ 2.2775
        @test t.counts == [2, 0, 1, 2]
        @test t.rf ≈ [0.4, 0.0, 0.2, 0.4]
        @test t.cf == [2, 2, 3, 5]
        @test t.cfp ≈ [40.0, 40.0, 60.0, 100.0]
        @test sum(t.counts) == 5
        @test startswith(t.classes[1], "[")
    end

    @testset "k mode" begin
        t = fdt([3, 6, 9, 12, 15, 18, 21]; k=4)
        @test length(t) == 4
        @test t.binning.start ≈ 2.97
        @test t.binning.end_ ≈ 21.21
        @test t.binning.h ≈ 4.56
        @test t.counts == [2, 2, 1, 2]
    end

    @testset "start + end + h" begin
        t = fdt([5, 10, 15, 20, 25, 30, 35]; start=0, end_=40, h=10)
        @test length(t) == 4
        @test t.counts == [1, 2, 2, 2]
        @test t.rf ≈ [1 / 7, 2 / 7, 2 / 7, 2 / 7]
    end

    @testset "breaks Scott / FD" begin
        x = [2, 5, 7, 10, 12, 15, 18]
        ts = fdt(x; breaks=Sturges)
        @test length(ts) == 4
        tsc = fdt(x; breaks=Scott)
        @test length(tsc) == 2
        tfd = fdt(x; breaks=FD)
        @test length(tfd) == 3
    end

    @testset "right open/closed" begin
        x = [1, 1, 1, 2, 2, 2, 2, 3, 3, 3]
        tl = fdt(x; start=1, end_=4, h=1, right=false)
        @test tl.counts == [3, 4, 3]
        @test startswith(tl.classes[1], "[")

        tr = fdt(x; start=0, end_=3, h=1, right=true)
        @test tr.counts == [3, 4, 3]
        @test startswith(tr.classes[1], "(")
    end

    @testset "constant data + na_rm" begin
        # n=3 → Sturges k=3; all mass in the middle class (R/Python)
        t1 = fdt([7, 7, 7])
        @test length(t1) == 3
        @test t1.counts == [0, 3, 0]
        @test t1.binning.start ≈ 6.93
        @test t1.binning.end_ ≈ 7.07

        t_one = fdt([7])
        @test length(t_one) == 1
        @test t_one.counts == [1]

        @test_throws ArgumentError fdt([1.0, NaN, 2.0]; na_rm=false)
        tnan = fdt([1.0, NaN, 2.0]; na_rm=true, k=2)
        @test sum(tnan.counts) == 2
    end

    @testset "legacy k=2 smoke" begin
        t = fdt([1, 2, 3, 4, 5]; k=2)
        @test length(t) == 2
        @test sum(t.counts) == 5
        @test t.breaks == t.binning.bins
    end

    @testset "summaries (golden)" begin
        t = fdt([1, 2, 6, 8, 10])
        @test mean(t) ≈ 5.77275
        @test median(t) ≈ 6.68375
        @test var(t) ≈ 11.930 atol = 1e-3
        @test sd(t) ≈ 3.454 atol = 1e-3
        @test std(t) ≈ sd(t)
        modes = mfv(t)
        @test length(modes) == 2
        @test modes[1] ≈ 2.12875
        @test modes[2] ≈ 8.581666666 atol = 1e-5
        @test amplitude(t) ≈ 9.11
        @test ta(t) == amplitude(t)
        @test quantile(t, 0.5) ≈ median(t)
        @test quantile(t, 50; by=100) ≈ median(t)
    end

    @testset "make_fdt rebuild" begin
        t0 = fdt([5, 10, 15, 20, 25, 30, 35]; start=0, end_=40, h=10)
        t1 = make_fdt(t0.counts; start=0, end_=40)
        @test t1.counts == t0.counts
        @test t1.binning.start == 0
        @test t1.binning.end_ == 40
        @test mean(t1) ≈ mean(t0)

        t2 = make_fdt(t0.counts, t0.binning)
        @test t2.counts == t0.counts
        @test t2.binning == t0.binning
    end

    @testset "categorical" begin
        tc = fdt_cat(["b", "a", "b", "c", "b", "a"]; sort=true, decreasing=true)
        @test tc isa CategoricalFDT
        @test tc.categories[1] == "b"
        @test tc.counts[1] == 3
        @test sum(tc.counts) == 6
        @test median(tc) == "b"
        @test mfv(tc) == ["b"]
        @test_throws ArgumentError mean(tc)

        td = fdt_cat(Dict("x" => 2, "y" => 5); decreasing=true)
        @test td.categories[1] == "y"
        @test td.counts == [5, 2]
    end

    @testset "auto kind" begin
        @test fdt(["a", "b", "a"]) isa CategoricalFDT
        @test fdt([1, 2, 3]; kind=:categorical) isa CategoricalFDT
    end

    @testset "multiple / by" begin
        X = [1 10; 2 20; 3 30; 4 40; 5 50]
        m = fdt(X; k=2, colnames=["x", "y"])
        @test m isa MultipleFDT
        @test collect(keys(m)) == ["x", "y"]
        @test m["x"] isa NumericalFDT
        @test sum(m["x"].counts) == 5
        @test haskey(mean(m), "x")

        by = ["A", "A", "B", "B", "B"]
        mg = fdt(X; k=2, colnames=["x", "y"], by=by)
        @test "A.x" in keys(mg)
        @test "B.y" in keys(mg)
        @test sum(mg["A.x"].counts) == 2
        @test sum(mg["B.x"].counts) == 3

        md = fdt(Dict("u" => [1, 2, 3, 4], "g" => ["a", "a", "b", "b"]); decreasing=true)
        @test md["u"] isa NumericalFDT
        @test md["g"] isa CategoricalFDT
    end

    @testset "plot_series" begin
        t = fdt([1, 2, 6, 8, 10])
        x, y, ylab, style, edges = plot_series(t; type=:fh)
        @test length(x) == length(t)
        @test style === :bar
        @test ylab == "Frequency"
        x2, y2, _, style2, _ = plot_series(t; type=:fp)
        @test style2 === :line
        @test y2 == y

        tc = fdt_cat(["a", "b", "a"])
        xc, yc, _, sc, _ = plot_series(tc; type=:rfh)
        @test sc === :bar
        @test length(xc) == 2
    end

    @testset "summary / display" begin
        t = fdt([1, 2, 6, 8, 10])
        s = summary(t)
        @test occursin("Class limits", s)
        @test occursin("NumericalFDT", s)
        @test occursin("rf(%)", s)
        s2 = summary(t; columns=[1, 2, 5])
        @test occursin("cf", s2)
        @test !occursin("rf(%)", s2)

        tc = fdt_cat(["a", "b", "a"])
        @test occursin("Category", summary(tc))
        @test occursin("CategoricalFDT", sprint(show, MIME("text/plain"), tc))
    end
end
