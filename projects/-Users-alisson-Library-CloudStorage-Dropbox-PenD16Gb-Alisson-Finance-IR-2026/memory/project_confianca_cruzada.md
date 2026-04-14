---
name: Modelo de confiança cruzada IRPF 2026
description: Hierarquia de fontes para cross-referencing: XP (custodiante) > SmartFolio/Investidor10 (controle) > administradoras (confirmação)
type: project
---

A confiança de um item é definida pela hierarquia de fontes:

- **XP** (custodiante, fonte principal da verdade): PDFs com prefixo `XP*`. É o custodian do usuário.
- **Investidor10** (sistema de controle paralelo): PDFs com prefixo `Guia*` — são os "Guia Bens e Direitos", "Guia Rendimentos Isentos", "Guia Rendimentos Exclusivos" exportados do Investidor10. Fontes nomeadas "Investidor10 — Guia *".
- **SmartFolio** (sistema de controle paralelo): PDFs com prefixo `smartfolio*`. Tabela `smartfolio_ref`.
- **Administradoras** (PDFs diretos dos fundos/bancos): SAFRA, NOMAD, BB, BTG, APEX, DAYCOVAL, etc. Devem bater com o que está na XP.

**Regras de confiança:**
- 🟢 confirmado: item em XP + confirmado por controle (SmartFolio/Investidor10) OU por administradora
- 🟡 parcial: item em XP apenas (XP é o custodiante, portanto confiável, mas sem cross-check)
- 🔴 alto risco: item NÃO está em XP mas aparece em controle ou administradora — possível dado faltando na extração XP

**Classes de fonte** (calculado via CASE no SQL das views):
- `'xp'`: arquivo_pdf LIKE 'XP%'
- `'controle'`: arquivo_pdf LIKE 'smartfolio%' OR LIKE 'investidor10%' OR LIKE 'Guia%'
- `'administradora'`: todos os demais (SAFRA, NOMAD, BB, BTG, APEX, etc.)

**Chave de matching**: `COALESCE(ticker, cnpj, descricao)` — ticker tem prioridade pois XP Histórico armazena só ticker (sem CNPJ), enquanto Guia Bens armazena ambos. Ticker-first garante matching correto para ações e FIIs.

**SmartFolio**: dados em `smartfolio_ref` (ticker, categoria, valor). Categorias: dividendo→cod 09, fii_isento→cod 26, jcp→cod 10, trib_exterior→cod 12.

**Why:** O sistema anterior contava n_fontes (número de arquivos distintos), o que era enganoso — múltiplos PDFs da XP (Histórico + Guia Bens) contavam como 2 fontes, dando falsa sensação de confirmação. O correto é contar classes distintas.

**How to apply:** Sempre que projetar novos parsers ou lógica de cross-reference, usar a hierarquia xp > controle > administradora. Items com tem_xp=0 são prioridade de revisão.
