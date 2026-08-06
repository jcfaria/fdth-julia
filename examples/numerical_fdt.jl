# Numerical FDT: table, columns and class limits
# julia --project=. examples/numerical_fdt.jl

using Fdth

x = [
    4.2, 5.1, 5.8, 6.0, 6.3, 6.7, 7.1, 7.4, 7.9, 8.2,
    8.5, 8.8, 9.0, 9.4, 9.9, 10.3, 10.8, 11.2, 12.0, 13.5,
]

println("=== Default table (Sturges) ===")
t = fdt(x)
display(t)

println("\n=== Columns ===")
println("classes : ", t.classes)
println("f       : ", t.counts)
println("rf      : ", round.(t.rf; digits=3))
println("rf(%)   : ", round.(t.rfp; digits=1))
println("cf      : ", t.cf)
println("cf(%)   : ", round.(t.cfp; digits=1))
println("n       : ", t.n)

println("\n=== Binning metadata ===")
println("start=$(t.binning.start)  end=$(t.binning.end_)  h=$(t.binning.h)  k=$(t.binning.k)")
println("bin edges: ", round.(t.binning.bins; digits=2))

println("\n=== Column subsets (summary) ===")
println(summary(t; columns=[1, 2, 5]))

println("\n=== Right-closed classes: (a, b] instead of [a, b) ===")
display(fdt(x; start=4, end_=14, h=2, right=true))

println("\n=== Missing / non-finite data ===")
y = [1.0, 2.0, NaN, 4.0, missing, 6.0]
println("na_rm=true  → n = ", fdt(y; na_rm=true, k=3).n)
try
    fdt(y; na_rm=false)
catch err
    println("na_rm=false → ", err)
end
