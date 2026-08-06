@testset "binning internals" begin
    @testset "padded range" begin
        start, end_ = Fdth.padded_range([1, 2, 6, 8, 10])
        @test start ≈ 0.99
        @test end_ ≈ 10.1

        # negative minimum still pads outwards
        lo, hi = Fdth.padded_range([-50, 50])
        @test lo ≈ -50.5
        @test hi ≈ 50.5

        # degenerate all-zero data falls back to a unit-width window
        z0, z1 = Fdth.padded_range([0, 0, 0])
        @test z0 ≈ -0.5
        @test z1 ≈ 0.5
    end

    @testset "linspace binning" begin
        b = Fdth.linspace_binning(; k=4, start=0, end_=40)
        @test b.k == 4
        @test b.h ≈ 10
        @test b.bins == [0.0, 10.0, 20.0, 30.0, 40.0]
        @test length(b.bins) == b.k + 1
        @test b == Fdth.linspace_binning(; k=4, start=0, end_=40)

        bd = Fdth.linspace_binning(; k=2, data=[1, 2, 6, 8, 10])
        @test bd.start ≈ 0.99
        @test bd.end_ ≈ 10.1
        @test bd.h ≈ (10.1 - 0.99) / 2
    end

    @testset "breaks rules" begin
        x = [2, 5, 7, 10, 12, 15, 18]
        @test Fdth.from_sturges(x).k == 4
        @test Fdth.from_scott(x).k == 2
        @test Fdth.from_fd(x).k == 3

        # zero spread: single class regardless of rule
        @test Fdth.from_scott([4, 4, 4, 4]).k == 1
        # zero IQR falls back to Scott
        @test Fdth.from_fd([3, 3, 3, 3]).k == Fdth.from_scott([3, 3, 3, 3]).k
        # single observation
        @test Fdth.from_sturges([9]).k == 1
    end

    @testset "resolve modes" begin
        x = [5, 10, 15, 20, 25, 30, 35]

        # start + end only: k = max(5, ceil(sqrt(|R|)))
        @test Fdth.resolve_binning(x; start=0, end_=40).k == 7
        @test Fdth.resolve_binning(x; start=0, end_=9).k == 5

        # start + end + h
        bh = Fdth.resolve_binning(x; start=0, end_=40, h=10)
        @test bh.k == 4
        @test bh.h ≈ 10

        # k alone uses the padded data range
        bk = Fdth.resolve_binning(x; k=3)
        @test bk.k == 3
        @test bk.start ≈ 4.95
    end

    @testset "class labels" begin
        b = Fdth.linspace_binning(; k=2, start=0, end_=1)
        @test Fdth.format_classes(b; right=false) == ["[0.0, 0.5)", "[0.5, 1.0)"]
        @test Fdth.format_classes(b; right=true) == ["(0.0, 0.5]", "(0.5, 1.0]"]

        bround = Fdth.linspace_binning(; k=3, start=0, end_=1)
        labels = Fdth.format_classes(bround; round_=2)
        @test labels[1] == "[0.0, 0.33)"
        @test length(labels) == 3
    end
end
