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

    md = fdt(
        Dict("u" => [1, 2, 3, 4], "g" => ["a", "a", "b", "b"]);
        decreasing=true,
    )
    @test md["u"] isa NumericalFDT
    @test md["g"] isa CategoricalFDT
end
