# SAP — Fdth.jl (Julia port)

**Updated:** 2026-08-05  
**Scope:** ready for **final STATghost** smoke-test; then public remote  
**Siblings:** R `fdth` (CRAN), Python `fdth` (PyPI)  
**CPR:** [`02_CPR_checklist_parity.md`](02_CPR_checklist_parity.md)  
**Version:** 0.2.0

## Status

Teachable surface complete for classroom use:

| Área | Estado |
|------|--------|
| Numérico + binning + tabela | OK |
| Medidas resumidas | OK |
| Categórico + auto kind | OK |
| Multiple / by / Dict / matrix | OK |
| `summary` / display formatado | OK |
| Plots / DataFrames | extensões opcionais |
| Testes | suite local |
| CI | workflow pronto (ativa no remoto) |
| Remoto / General | **após** OK no STATghost |

## Para o teste final (STATghost)

```julia
using Pkg
Pkg.activate("/caminho/para/fdth-julia")  # ou --project=
Pkg.instantiate()
Pkg.test()
include("examples/quickstart.jl")
```

## Próximo (após OK humano)

1. `git remote` + GitHub público `jcfaria/fdth-julia`
2. Tag `v0.2.0`
3. Preparar registo Julia General (docs mínimas + CI verde)
