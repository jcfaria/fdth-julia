# Grouped-data summaries: mean, variance, quantiles, mode, amplitude
# julia --project=. examples/summaries.jl

using Fdth
using Statistics

x = [
    4.2, 5.1, 5.8, 6.0, 6.3, 6.7, 7.1, 7.4, 7.9, 8.2,
    8.5, 8.8, 9.0, 9.4, 9.9, 10.3, 10.8, 11.2, 12.0, 13.5,
]
t = fdt(x)
display(t)

println("\n=== Central tendency (grouped vs raw) ===")
println("mean   grouped=$(round(mean(t); digits=4))   raw=$(round(mean(x); digits=4))")
println("median grouped=$(round(median(t); digits=4))   raw=$(round(median(x); digits=4))")
println("mfv    grouped=", round.(mfv(t); digits=4))

println("\n=== Dispersion ===")
println("var (n-1)=$(round(var(t); digits=4))   var (n)=$(round(var(t; corrected=false); digits=4))")
println("sd  (n-1)=$(round(sd(t); digits=4))    std == sd → ", std(t) == sd(t))
println("amplitude (class range) = $(round(amplitude(t); digits=3))   alias ta → ", ta(t) == amplitude(t))

println("\n=== Quantiles: three equivalent APIs ===")
println("proportions : ", round.(quantile(t, [0.25, 0.5, 0.75]); digits=4))
println("quartiles   : ", round.(quantile(t, [1, 2, 3]; by=4); digits=4))
println("percentiles : ", round.(quantile(t, [25, 50, 75]; by=100); digits=4))
println("deciles     : ", round.(quantile(t, 1:9; by=10); digits=2))

println("\n=== Boundaries fall on the class limits ===")
println("quantile(t, 0) = $(quantile(t, 0.0)) == start = $(t.binning.start)")
println("quantile(t, 1) = $(quantile(t, 1.0)) == end   = $(t.binning.end_)")

println("\n=== Narrow classes converge to the raw statistics ===")
for k in (4, 10, 40)
    tk = fdt(x; k=k)
    println("k=$(rpad(k, 3)) mean=$(round(mean(tk); digits=4))  sd=$(round(sd(tk); digits=4))")
end
println("raw     mean=$(round(mean(x); digits=4))  sd=$(round(std(x); digits=4))")
