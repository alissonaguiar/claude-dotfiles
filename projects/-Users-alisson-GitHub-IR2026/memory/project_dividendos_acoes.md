---
name: Dividendos ações — BRSR3/BRSR6 e namespace ATIVO↔Conferência
description: Problemas corrigidos no tratamento de dividendos de ações com mesmo CNPJ e classes diferentes
type: project
---

## Problema: CNPJ compartilhado entre classes de ação (BRSR3/BRSR6)
Banrisul tem BRSR3 e BRSR6 com mesmo CNPJ (92702067000196).

Correções aplicadas:
1. Fallback CNPJ em `reconciliar_isentos_dividendos` agora filtra por ticker — BRSR3 não herda informes do BRSR6
2. `xp_claimed` set: XP Proventos BANRISUL atribuído só ao ticker SF de maior valor (BRSR6), não duplica no BRSR3
3. Governo (pré-preenchida) tem valor=0.00 para CNPJ Banrisul — status `divergente` é esperado, não bug

## Problema: item_key ATIVO ≠ Conferência
- ATIVO usava `div_isento_{row_id}` para dividendos
- Conferência usa `div_{TICKER}`
- Resoluções feitas no ATIVO não refletiam na Conferência

Correção: `_item_key_isento` agora usa `div_{ticker}` quando ticker disponível (código 09).

**Why:** Os dois eram namespaces incompatíveis — correção unifica para `div_{TICKER}` em ambas as páginas.

**How to apply:** Se outros ativos mostrarem a mesma desconexão ATIVO↔Conferência, verificar se o item_key está sendo gerado com ticker ou com row ID.
