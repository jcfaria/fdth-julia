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

    @test fdt(["a", "b", "a"]) isa CategoricalFDT
    @test fdt([1, 2, 3]; kind=:categorical) isa CategoricalFDT
end
