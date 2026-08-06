@testset "invariants (randomised)" begin
    rng = MersenneTwister(20260805)

    @testset "table structure" begin
        for _ in 1:30
            n = rand(rng, 5:200)
            x = randn(rng, n) .* rand(rng, 1:10) .+ rand(rng, -20:20)
            for breaks in (Sturges, Scott, FD)
                t = fdt(x; breaks=breaks)
                k = length(t)
                @test k >= 1
                @test t.n == n
                @test sum(t.counts) == n
                @test all(>=(0), t.counts)
                @test length(t.classes) == k
                @test length(t.binning.bins) == k + 1
                @test issorted(t.binning.bins)
                @test t.binning.k == k
                @test t.cf == cumsum(t.counts)
                @test issorted(t.cf)
                @test t.cf[end] == n
                @test sum(t.rf) ≈ 1
                @test t.rfp ≈ t.rf .* 100
                @test t.cfp[end] ≈ 100
                @test t.binning.h ≈ (t.binning.end_ - t.binning.start) / k
                @test all(diff(t.binning.bins) .≈ t.binning.h)
            end
        end
    end

    @testset "grouped vs raw statistics" begin
        # grouped summaries approximate the raw ones as classes get narrower
        for _ in 1:20
            x = randn(rng, 400) .* 5 .+ 50
            t = fdt(x; k=40)
            @test mean(t) ≈ mean(x) atol = 0.5
            @test std(t) ≈ std(x) atol = 0.5
            @test median(t) ≈ median(x) atol = 0.8
            @test t.binning.start < minimum(x)
            @test t.binning.end_ > maximum(x)
        end
    end

    @testset "monotone quantiles" begin
        for _ in 1:20
            x = rand(rng, 50) .* 100
            t = fdt(x)
            qs = quantile(t, 0:0.1:1)
            @test issorted(qs)
            @test qs[1] ≈ t.binning.start
            @test qs[end] ≈ t.binning.end_
            @test all(t.binning.start .<= qs .<= t.binning.end_)
        end
    end

    @testset "categorical counts" begin
        for _ in 1:20
            labels = rand(rng, ["a", "b", "c", "d"], rand(rng, 5:100))
            t = fdt(labels)
            @test t isa CategoricalFDT
            @test t.n == length(labels)
            @test sum(t.counts) == length(labels)
            @test sort(t.categories) == sort(unique(labels))
            @test issorted(t.counts)                    # default: ascending frequency
            @test t.counts[end] == maximum(t.counts)
            @test mfv(t) ⊆ t.categories
            @test all(count(==(c), labels) == t.counts[i] for (i, c) in enumerate(t.categories))
        end
    end

    @testset "make_fdt round-trip" begin
        for _ in 1:20
            x = randn(rng, 100) .* 3
            t = fdt(x)
            back = make_fdt(t.counts, t.binning; right=t.right)
            @test back.counts == t.counts
            @test back.binning == t.binning
            @test back.classes == t.classes
            @test mean(back) ≈ mean(t)
            @test median(back) ≈ median(t)
            @test var(back) ≈ var(t)
        end
    end
end
