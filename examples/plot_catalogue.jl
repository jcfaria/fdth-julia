# The full plot catalogue, without any plotting backend.
# `plot_series` returns the numbers; `Plots` (or any backend) draws them.
# julia --project=. examples/plot_catalogue.jl

using Fdth

x = [
    4.2, 5.1, 5.8, 6.0, 6.3, 6.7, 7.1, 7.4, 7.9, 8.2,
    8.5, 8.8, 9.0, 9.4, 9.9, 10.3, 10.8, 11.2, 12.0, 13.5,
]
t = fdt(x; k=5)

println("=== Numerical: $(length(plot_types(t))) types ===")
println("codes: ", join(plot_types(t), ", "), "\n")
for type in plot_types(t)
    s = plot_series(t; type=type)
    println(
        rpad(string(type), 6),
        rpad(string(s.style), 8),
        rpad("points=$(length(s.y))", 12),
        rpad(s.ylab, 26),
        "y=", round.(s.y; digits=2),
    )
end

println("\nHistograms sit on class midpoints; cumulative polygons are ogives")
println("over the class limits, starting at (start, 0):")
println("  cfh (bars)  x = ", round.(plot_series(t; type=:cfh).x; digits=2))
println("  cfp (ogive) x = ", round.(plot_series(t; type=:cfp).x; digits=2))
println("  cfp (ogive) y = ", plot_series(t; type=:cfp).y)

tc = fdt_cat(
    ["scratch", "dent", "scratch", "crack", "scratch", "dent", "scratch", "paint"];
    decreasing=true,
)

println("\n=== Categorical: $(length(plot_types(tc))) types ===")
println("codes: ", join(plot_types(tc), ", "), "\n")
for type in plot_types(tc)
    s = plot_series(tc; type=type)
    println(
        rpad(string(type), 6),
        rpad(string(s.style), 8),
        rpad(s.ylab, 26),
        "y=", round.(s.y; digits=2),
    )
end

println("\n=== Pareto carries the cumulative line in y2 ===")
pa = plot_series(tc; type=:pa)
println("categories: ", pa.x)
println("bars (f)  : ", pa.y)
println("line (cf) : ", pa.y2, "  label: ", pa.y2lab)

println("\n=== Multiple: one series per member table ===")
m = fdt(Dict("u" => x, "g" => ["a", "b"][1 .+ (x .> 8)]); k=4)
for (name, s) in plot_series(m; type=:fh)
    println(rpad(name, 4), " style=$(s.style)  points=$(length(s.y))  ylab=$(s.ylab)")
end
println("types valid for every member: ", join(plot_types(m), ", "))
