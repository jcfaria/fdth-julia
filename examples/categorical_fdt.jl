# Categorical FDT: counts, ordering, mode and median category
# julia --project=. examples/categorical_fdt.jl

using Fdth
using Statistics

defects = [
    "scratch", "dent", "scratch", "crack", "scratch", "dent",
    "scratch", "paint", "dent", "crack", "scratch", "paint",
]

println("=== Ascending frequency (default) ===")
display(fdt_cat(defects))

println("\n=== Decreasing frequency (Pareto order) ===")
tc = fdt_cat(defects; decreasing=true)
display(tc)

println("\n=== First-seen order (sort=false) ===")
display(fdt_cat(defects; sort=false))

println("\n=== Summaries ===")
println("mode(s)          : ", mfv(tc))
println("median category  : ", median(tc))
println("n                : ", tc.n)
try
    mean(tc)
catch err
    println("mean             : ", err)
end

println("\n=== From a category => frequency map ===")
display(fdt_cat(Dict("A" => 12, "B" => 7, "C" => 3); decreasing=true))

println("\n=== Automatic kind detection ===")
println("fdt(strings)              → ", typeof(fdt(defects)))
println("fdt(numbers)              → ", typeof(fdt([1.0, 2.0, 3.0, 4.0])))
println("fdt(numbers, categorical) → ", typeof(fdt([1, 1, 2, 3]; kind=:categorical)))

println("\n=== Missing values are dropped ===")
withmissing = ["a", missing, "b", "a", missing]
println("n = ", fdt(withmissing).n, " (from $(length(withmissing)) rows)")
