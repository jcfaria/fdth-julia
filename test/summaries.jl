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

    @testset "midpoints and variance divisor" begin
        t = fdt([1, 2, 6, 8, 10])
        mids = Fdth.midpoints(t)
        @test length(mids) == length(t)
        @test mids[1] ≈ (t.binning.bins[1] + t.binning.bins[2]) / 2
        @test issorted(mids)

        # population divisor is smaller than the default n−1
        @test var(t; corrected=false) < var(t)
        @test var(t; corrected=false) ≈ var(t) * (t.n - 1) / t.n
        @test std(t; corrected=false) ≈ sqrt(var(t; corrected=false))
        @test sd(t; corrected=false) ≈ std(t; corrected=false)
    end

    @testset "quantile API" begin
        t = fdt([5, 10, 15, 20, 25, 30, 35]; start=0, end_=40, h=10)

        # boundaries map to the class limits
        @test quantile(t, 0.0) ≈ t.binning.start
        @test quantile(t, 1.0) ≈ t.binning.end_

        qs = quantile(t, [0.25, 0.5, 0.75])
        @test length(qs) == 3
        @test issorted(qs)

        # `by` rescales positions: quartile indices and percentiles agree
        @test quantile(t, [1, 2, 3]; by=4) ≈ qs
        @test quantile(t, 25; by=100) ≈ qs[1]
        @test median(t) ≈ qs[2]
    end

    @testset "single-mode data" begin
        t = fdt([1, 5, 5, 5, 9]; k=3)
        @test length(mfv(t)) == 1
        @test t.binning.start <= mfv(t)[1] <= t.binning.end_
        @test mean(t) ≈ median(t) atol = 1.0
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

        # frequency columns are recomputed, not copied
        t3 = make_fdt([2, 3, 5]; start=0, end_=30)
        @test t3.n == 10
        @test t3.rf ≈ [0.2, 0.3, 0.5]
        @test t3.cf == [2, 5, 10]
        @test t3.cfp[end] ≈ 100
        @test t3.binning.h ≈ 10

        tr = make_fdt([1, 1]; start=0, end_=2, right=true)
        @test startswith(tr.classes[1], "(")
        @test tr.right
    end
end
