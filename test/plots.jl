@testset "plot series" begin
    t = fdt([1, 2, 6, 8, 10])

    @testset "numerical catalogue" begin
        @test plot_types(t) == [
            :fh, :fp, :rfh, :rfp, :rfph, :rfpp,
            :d, :cdh, :cdp, :cfh, :cfp, :cfph, :cfpp,
        ]
        @test length(plot_types(t)) == 13

        for type in plot_types(t)
            s = plot_series(t; type=type)
            @test s isa PlotSeries
            @test length(s.x) == length(s.y)
            @test s.style in (:bar, :line)
            @test !isempty(s.ylab)
            @test s.edges == t.binning.bins
            @test s.y2 === nothing
        end
    end

    @testset "legacy destructuring" begin
        x, y, ylab, style, edges = plot_series(t; type=:fh)
        @test length(x) == length(t)
        @test style === :bar
        @test ylab == "Frequency"
        @test edges == t.binning.bins
        @test y == Float64.(t.counts)

        s = plot_series(t; type=:fh)
        @test length(s) == 5
        @test s[1] == x
        @test s[4] === :bar
        @test occursin("PlotSeries", sprint(show, s))
    end

    @testset "histograms use midpoints" begin
        for (type, expected) in (
            (:fh, Float64.(t.counts)),
            (:rfh, t.rf),
            (:rfph, t.rfp),
            (:d, t.rf ./ t.binning.h),
            (:cdh, t.cf ./ (t.n * t.binning.h)),
            (:cfh, Float64.(t.cf)),
            (:cfph, t.cfp),
        )
            s = plot_series(t; type=type)
            @test s.style === :bar
            @test s.x == Fdth.midpoints(t)
            @test s.y ≈ expected
        end
    end

    @testset "non-cumulative polygons" begin
        for (h, p) in ((:fh, :fp), (:rfh, :rfp), (:rfph, :rfpp))
            sh = plot_series(t; type=h)
            sp = plot_series(t; type=p)
            @test sp.x == sh.x
            @test sp.y == sh.y
            @test sp.ylab == sh.ylab
            @test sp.style === :line
        end
    end

    @testset "cumulative polygons are ogives" begin
        for (type, tail) in (
            (:cfp, Float64.(t.cf)),
            (:cfpp, t.cfp),
            (:cdp, t.cf ./ (t.n * t.binning.h)),
        )
            s = plot_series(t; type=type)
            @test s.style === :line
            @test s.x == t.binning.bins                 # k + 1 class limits
            @test length(s.y) == length(t) + 1
            @test s.y[1] == 0
            @test s.y[2:end] ≈ tail
            @test issorted(s.y)
        end

        @test plot_series(t; type=:cfp).y[end] == t.n
        @test plot_series(t; type=:cfpp).y[end] ≈ 100
    end

    @testset "density scaling" begin
        s = plot_series(t; type=:d)
        @test s.ylab == "Density"
        @test s.y ≈ t.rf ./ t.binning.h
        @test sum(s.y) * t.binning.h ≈ 1

        cd = plot_series(t; type=:cdh)
        @test cd.y ≈ t.cf ./ (t.n * t.binning.h)
        @test cd.y[end] ≈ 1 / t.binning.h
    end
end

@testset "categorical plot series" begin
    tc = fdt_cat(["b", "a", "b", "c", "b", "a"]; decreasing=true)

    @testset "catalogue" begin
        @test length(plot_types(tc)) == 16
        @test issubset(
            [:fb, :fp, :fd, :rfb, :rfp, :rfd, :rfpb, :rfpp, :rfpd,
             :cfb, :cfp, :cfd, :cfpb, :cfpp, :cfpd, :pa],
            plot_types(tc),
        )

        for type in plot_types(tc)
            s = plot_series(tc; type=type)
            @test s.x == tc.categories
            @test length(s.y) == length(tc)
            @test s.style in (:bar, :line, :dot, :pareto)
            @test s.edges === nothing
            @test !isempty(s.ylab)
        end
    end

    @testset "styles per family" begin
        @test plot_series(tc; type=:fb).style === :bar
        @test plot_series(tc; type=:fp).style === :line
        @test plot_series(tc; type=:fd).style === :dot
        @test plot_series(tc; type=:pa).style === :pareto

        # the same column feeds bar / polygon / dotchart
        for (b, p, d) in (
            (:fb, :fp, :fd),
            (:rfb, :rfp, :rfd),
            (:rfpb, :rfpp, :rfpd),
            (:cfb, :cfp, :cfd),
            (:cfpb, :cfpp, :cfpd),
        )
            yb = plot_series(tc; type=b)
            @test plot_series(tc; type=p).y == yb.y
            @test plot_series(tc; type=d).y == yb.y
            @test plot_series(tc; type=d).ylab == yb.ylab
        end
    end

    @testset "columns" begin
        @test plot_series(tc; type=:fb).y == Float64.(tc.counts)
        @test plot_series(tc; type=:rfb).y ≈ tc.rf
        @test plot_series(tc; type=:rfpb).y ≈ tc.rfp
        @test plot_series(tc; type=:cfb).y == Float64.(tc.cf)
        @test plot_series(tc; type=:cfpb).y ≈ tc.cfp
    end

    @testset "pareto" begin
        s = plot_series(tc; type=:pa)
        @test s.y == Float64.(tc.counts)
        @test s.y2 == Float64.(tc.cf)
        @test s.y2lab == "Cumulative frequency, (%)"
        @test issorted(s.y; rev=true)       # decreasing table → textbook Pareto
        @test s.y2[end] == tc.n
    end

    @testset "histogram aliases" begin
        for (alias, canonical) in ((:fh, :fb), (:rfh, :rfb), (:rfph, :rfpb), (:cfh, :cfb), (:cfph, :cfpb))
            @test plot_series(tc; type=alias).y == plot_series(tc; type=canonical).y
            @test plot_series(tc; type=alias).style === :bar
        end
    end
end

@testset "multiple plot series" begin
    m = fdt(
        Dict("u" => [1, 2, 3, 4, 5], "g" => ["a", "a", "b", "b", "b"]);
        k=2,
    )

    series = plot_series(m; type=:fh)
    @test length(series) == length(m)
    @test [name for (name, _) in series] == m.names
    @test all(s isa PlotSeries for (_, s) in series)

    # :fh works on mixed containers through the categorical aliases
    @test issubset([:fh, :fp], plot_types(m))
    @test :d ∉ plot_types(m)

    mn = fdt([1 10; 2 20; 3 30; 4 40; 5 50]; k=2, colnames=["x", "y"])
    @test length(plot_types(mn)) == 13
    @test length(plot_series(mn; type=:cfp)) == 2
end
