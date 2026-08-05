@testset "summaries" begin
    @testset "golden values" begin
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
end
