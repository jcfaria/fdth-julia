@testset "numerical" begin
    @testset "Sturges default + padding" begin
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

    @testset "Scott / FD" begin
        x = [2, 5, 7, 10, 12, 15, 18]
        @test length(fdt(x; breaks=Sturges)) == 4
        @test length(fdt(x; breaks=Scott)) == 2
        @test length(fdt(x; breaks=FD)) == 3
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
        t1 = fdt([7, 7, 7])
        @test length(t1) == 3
        @test t1.counts == [0, 3, 0]
        @test t1.binning.start ≈ 6.93
        @test t1.binning.end_ ≈ 7.07

        t_one = fdt([7])
        @test length(t_one) == 1
        @test t_one.counts == [1]

        @test_throws ArgumentError fdt([1.0, NaN, 2.0]; na_rm=false)
        @test sum(fdt([1.0, NaN, 2.0]; na_rm=true, k=2).counts) == 2
    end

    @testset "legacy k=2 smoke" begin
        t = fdt([1, 2, 3, 4, 5]; k=2)
        @test length(t) == 2
        @test sum(t.counts) == 5
        @test t.breaks == t.binning.bins
    end
end
