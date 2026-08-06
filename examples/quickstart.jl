# Fdth.jl — STATghost / classroom script
# julia --project=. examples/quickstart.jl
# Focused scripts live next to this one; see examples/README.md

using Fdth
using Statistics

println("=== 1. Numerical FDT ===")
t = fdt([1, 2, 6, 8, 10])
display(t)
println()
println("mean=$(mean(t))  median=$(median(t))  sd=$(round(sd(t); digits=3))")
println("mfv=$(mfv(t))  amplitude=$(amplitude(t))")

println("\n=== 2. Binning modes ===")
println(fdt([3, 6, 9, 12, 15, 18, 21]; k=4))
println(fdt([2, 5, 7, 10, 12, 15, 18]; breaks=Scott))
println(fdt([5, 10, 15, 20, 25, 30, 35]; start=0, end_=40, h=10))

println("\n=== 3. Categorical ===")
display(fdt(["A", "B", "A", "C", "B", "A", "A"]))

println("\n=== 4. Multiple + by ===")
X = [1.0 10; 2 20; 3 30; 4 40; 5 50]
m = fdt(X; k=2, colnames=["x", "y"], by=["A", "A", "B", "B", "B"])
display(m)
println("\nmeans: ", mean(m))

println("\n=== 5. make_fdt rebuild ===")
println(make_fdt([1, 2, 2, 2]; start=0, end_=40))

println("\n=== 6. Plot series (13 numerical + 16 categorical types) ===")
s = plot_series(t; type=:fh)
println("fh → $(length(s.y)) bars, ylab=$(s.ylab), style=$(s.style)")
println("numerical types  : ", join(plot_types(t), ", "))
println("categorical types: ", join(plot_types(fdt_cat(["a", "b", "a"])), ", "))
println("with Plots installed: using Plots; plot(t; type=:cfp)")

println("\nDone. More: examples/README.md")
