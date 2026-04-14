---
name: FII incorporações e renomeações
description: Mapeamento de fundos incorporados/renomeados e correções XP Proventos implementadas
type: project
---

## Renomeações (mesmo CNPJ, ticker diferente)
- RVBI11 → PSEC11 (CNPJ 35507457000171) — aparece em ambos os nomes nos informes

## Incorporações (CNPJs diferentes, fundo absorvido)
- RBRF11 → RBRX11 (out/2025): XP registrava RBRF11 como "FII RBRALPHA" sob ticker RBRX11
- IRDM11 → IRIM11 (out/2025): XP registrava IRDM11 como "FII IRIDIUM" sob ticker IRIM11
- IRIM15 → IRIM11 (dez/2025): certificado transitório da incorporação

## Correções implementadas no engine.py
- `_INCORPORACOES`, `_SOBREVIVENTES`: dicts estáticos mapeando extintos→sobreviventes
- `_XP_NOME_ATIVO_TICKER`: corrige atribuição XP ("FII RBRALPHA"→RBRF11, "FII IRIDIUM"→IRDM11)
- `_xp_fii_por_cnpj`: exclui nome_ativo overridados para evitar duplicação via CNPJ

**Why:** XP Proventos registrava rendimentos do fundo extinto sob o ticker do fundo sobrevivente, inflando os valores do sobrevivente.

**How to apply:** Se outros FIIs mostrarem XP inflado, checar se o nome_ativo no xp_proventos pertence a outro fundo e adicionar em `_XP_NOME_ATIVO_TICKER`.
