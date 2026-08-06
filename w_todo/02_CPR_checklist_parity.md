# CPR — Controlo de Produção / Paridade Fdth.jl

Validação humana final: **STATghost**.  
Cadeia: **VP-FDTH-JL**.

---

## P0 — Binning + tabela

- [x] Padding, arestas, `right`, colunas, Sturges/Scott/FD, modos, `na_rm`, `make_fdt`, testes

## P1 — Medidas

- [x] `mean`, `median`, `var`, `std`/`sd`, `quantile`, `mfv`, `amplitude`/`ta`

## P2 — Multi / by

- [x] Matrix / Dict → `MultipleFDT`, `by`, summaries, extensão DataFrames

## P3 — Plots / print

- [x] `plot_series` + extensão Plots
- [x] Catálogo completo: 13 tipos numéricos + 16 categóricos (dotchart + Pareto)
- [x] Ogivas (`cdp`, `cfp`, `cfpp`) sobre os limites de classe, como no R
- [x] `plot_types`, `PlotSeries` (com `y2` do Pareto), grelha para `MultipleFDT`
- [x] `summary` / `display` formatados
- [ ] LaTeX export (adiado — não bloqueia STATghost)

## P4 — Polish + publicação

- [x] `fdt_cat`, auto kind
- [x] NEWS.md, CI workflow
- [x] GitHub público
- [x] Glossário PT-BR/EN adaptado para Julia
- [x] Exemplos por concern + catálogo/galeria de plots
- [x] Testes ampliados (~2400): binning, erros, invariantes aleatórias
- [ ] Julia General

## Decisões

| Tópico | Decisão |
|--------|---------|
| Paridade numérica | Python (Scott ddof=0, start+end, quantile `pos; by`) |
| Plots/DataFrames | weakdeps + extensions |
| Publicação | GitHub público; General após CI verde |
| Tamanho de ficheiros | **D5 [F]** pequenos/médios (≤~160 linhas por concern; estilo STATghost) |

## VPs

| VP | Notas |
|----|-------|
| VP0–VP3 | core → multiple/plots |
| VP4 | display + NEWS + CI → **checkpoint STATghost** |
