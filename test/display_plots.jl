@testset "plot series" begin
    t = fdt([1, 2, 6, 8, 10])
    x, y, ylab, style, _ = plot_series(t; type=:fh)
    @test length(x) == length(t)
    @test style === :bar
    @test ylab == "Frequency"

    _, y2, _, style2, _ = plot_series(t; type=:fp)
    @test style2 === :line
    @test y2 == y

    tc = fdt_cat(["a", "b", "a"])
    xc, _, _, sc, _ = plot_series(tc; type=:rfh)
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
