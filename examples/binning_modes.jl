# Binning: the four ways to choose classes (R/Python parity)
# julia --project=. examples/binning_modes.jl

using Fdth

x = [
    4.2, 5.1, 5.8, 6.0, 6.3, 6.7, 7.1, 7.4, 7.9, 8.2,
    8.5, 8.8, 9.0, 9.4, 9.9, 10.3, 10.8, 11.2, 12.0, 13.5,
]

println("=== 1. Rules (no arguments) ===")
for rule in (Sturges, Scott, FD)
    b = fdt(x; breaks=rule).binning
    println(rpad(string(rule), 8), "k=$(b.k)  h=$(round(b.h; digits=3))")
end

println("\n=== 2. Number of classes: k ===")
for k in (3, 5, 8)
    println("k=$k → ", fdt(x; k=k).counts)
end

println("\n=== 3. start + end (k = max(5, ceil(sqrt(range)))) ===")
b3 = fdt(x; start=4, end_=14).binning
println("k=$(b3.k)  h=$(round(b3.h; digits=3))")

println("\n=== 4. start + end + h ===")
display(fdt(x; start=4, end_=14, h=2))

println("\n=== Padded range keeps every observation inside ===")
b = fdt(x).binning
println("data range : ", extrema(x))
println("class range: ($(round(b.start; digits=3)), $(round(b.end_; digits=3)))")

println("\n=== Rebuilding a table from frequencies (make_fdt) ===")
t = make_fdt([3, 7, 6, 4]; start=0, end_=40)
display(t)
println("\nSame, reusing an existing Binning:")
display(make_fdt([3, 7, 6, 4], t.binning))
