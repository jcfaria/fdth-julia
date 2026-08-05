# fdth (Julia) — early examples
# Activate the package first, from the repo root:
#   julia --project=.
#   julia> using Fdth
#
# Or:
#   julia --project=. examples/quickstart.jl

using Fdth

data = [1, 5, 8, 3, 12, 7, 4, 9]
table = fdt(data)
println(table)
