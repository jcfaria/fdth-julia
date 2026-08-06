@testset "summary / display" begin
    t = fdt([1, 2, 6, 8, 10])

    @testset "numerical table" begin
        s = summary(t)
        @test occursin("Class limits", s)
        @test occursin("NumericalFDT", s)
        @test occursin("rf(%)", s)
        @test occursin("n=5", s)
        # title + header + rule + one line per class + closing rule
        @test count(==('\n'), s) == length(t) + 3

        s2 = summary(t; columns=[1, 2, 5])
        @test occursin("cf", s2)
        @test !occursin("rf(%)", s2)

        @test occursin("h=2.3", summary(t; digits=1))
    end

    @testset "categorical table" begin
        tc = fdt_cat(["a", "b", "a"])
        @test occursin("Category", summary(tc))
        @test occursin("CategoricalFDT", sprint(show, MIME("text/plain"), tc))
        @test sprint(show, tc) == "CategoricalFDT(2 categories, n=3)"
    end

    @testset "compact show" begin
        @test sprint(show, t) == "NumericalFDT(4 classes, n=5)"
        @test occursin("NumericalFDT", sprint(show, MIME("text/plain"), t))
    end

    @testset "multiple table" begin
        m = fdt([1 10; 2 20; 3 30; 4 40; 5 50]; k=2, colnames=["x", "y"])
        s = summary(m)
        @test occursin("MultipleFDT with 2 table(s)", s)
        @test occursin("── x ──", s)
        @test occursin("── y ──", s)
        @test sprint(show, m) == "MultipleFDT(2 tables: x, y)"
        @test occursin("MultipleFDT", sprint(show, MIME("text/plain"), m))
    end
end
