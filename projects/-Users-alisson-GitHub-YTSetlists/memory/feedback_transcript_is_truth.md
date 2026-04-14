---
name: feedback_transcript_is_truth
description: The transcript (what was sung) is the source of truth, not official lyrics — lyrics are only for identification and section type reference
type: feedback
---

A TRANSCRIÇÃO é a fonte da verdade — o output deve mostrar o que foi cantado no vídeo, linha por linha. As letras oficiais (Letras.mus.br, CifraClub) servem APENAS para:
1. Identificar QUAL música está sendo cantada (vs espontâneo)
2. Determinar o TIPO de seção (estrofe, refrão, ponte)

**Why:** O usuário quer que uma banda pegue o output e consiga reproduzir a performance: cantores seguem a letra linha por linha, músicos seguem a estrutura (V1 → R → V2 → R → P → etc). A letra oficial é referência, não o produto.

**How to apply:** Sempre usar `entry.transcript_text` como conteúdo das seções, nunca a letra do Letras.mus.br. Incluir todas as repetições como cantadas. Ministração espontânea é excluída.
