# Multiple FDTs: one table per column, with optional grouping (R fdt.multiple)
# julia --project=. examples/multiple_fdt.jl

using Fdth
using Statistics

height = [1.62, 1.71, 1.55, 1.80, 1.68, 1.75, 1.59, 1.85, 1.66, 1.73]
weight = [58.0, 72.5, 51.0, 88.0, 65.5, 79.0, 54.0, 92.0, 61.0, 75.0]
sex = ["F", "M", "F", "M", "F", "M", "F", "M", "F", "M"]

println("=== Matrix input, named columns ===")
X = hcat(height, weight)
m = fdt(X; k=3, colnames=["height", "weight"])
display(m)

println("\n=== Access and iteration ===")
println("names        : ", keys(m))
println("m[\"height\"]  : ", m["height"])
println("haskey(:weight) → ", haskey(m, :weight))
for (name, table) in m
    println(rpad(name, 8), "k=$(length(table))  n=$(table.n)")
end

println("\n=== Default column names (V1, V2, ...) ===")
println(keys(fdt(X; k=3)))

println("\n=== Aggregate summaries ===")
println("mean      : ", Dict(k => round(v; digits=3) for (k, v) in mean(m)))
println("median    : ", Dict(k => round(v; digits=3) for (k, v) in median(m)))
println("sd        : ", Dict(k => round(v; digits=3) for (k, v) in sd(m)))
println("amplitude : ", Dict(k => round(v; digits=3) for (k, v) in amplitude(m)))

println("\n=== Grouped by a factor: keys become \"level.column\" ===")
mg = fdt(X; k=2, colnames=["height", "weight"], by=sex)
println(keys(mg))
println("F.height counts: ", mg["F.height"].counts)
println("M.height counts: ", mg["M.height"].counts)

println("\n=== Mixed numerical + categorical columns (dict input) ===")
md = fdt(Dict("weight" => weight, "sex" => sex); k=3)
println("weight → ", typeof(md["weight"]))
println("sex    → ", typeof(md["sex"]))
display(md["sex"])
