# Figure gallery — needs the optional Plots.jl extension:
#   julia --project=. -e 'using Pkg; Pkg.add("Plots")'
#   julia --project=. examples/plots_gallery.jl
# Figures are written to examples/output/.

using Fdth

if Base.find_package("Plots") === nothing
    println("Plots.jl is not installed; run: Pkg.add(\"Plots\")")
    exit(0)
end

using Plots
gr()

outdir = joinpath(@__DIR__, "output")
mkpath(outdir)

x = [
    4.2, 5.1, 5.8, 6.0, 6.3, 6.7, 7.1, 7.4, 7.9, 8.2,
    8.5, 8.8, 9.0, 9.4, 9.9, 10.3, 10.8, 11.2, 12.0, 13.5,
]
t = fdt(x; k=5)

println("=== Numerical (13 types) ===")
for type in plot_types(t)
    file = joinpath(outdir, "numerical_$(type).png")
    savefig(plot(t; type=type, title="fdt: $type"), file)
    println("  ", basename(file))
end

tc = fdt_cat(
    ["scratch", "dent", "scratch", "crack", "scratch", "dent", "scratch", "paint"];
    decreasing=true,
)

println("\n=== Categorical (16 types, incl. dotcharts and Pareto) ===")
for type in plot_types(tc)
    file = joinpath(outdir, "categorical_$(type).png")
    savefig(plot(tc; type=type, title="fdt_cat: $type"), file)
    println("  ", basename(file))
end

println("\n=== Multiple: one panel per table ===")
m = fdt(hcat(x, reverse(x)); k=5, colnames=["x", "reversed"])
savefig(plot(m; type=:fh), joinpath(outdir, "multiple_fh.png"))
println("  multiple_fh.png")

println("\nFigures in: ", outdir)
