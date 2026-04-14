---
name: project_current_state
description: Current state of YTSetlists app as of 2026-03-29 — architecture, what works, what needs refinement
type: project
---

## Arquitetura atual (2026-03-29)

**Pipeline determinístico (sem LLM para alinhamento):**
1. Transcrição via `youtube-transcript-api` (legendas YT) ou `pytubefix` audio + Gemini transcrição
2. Gemini identifica APENAS títulos + artistas (1 chamada simples)
3. Letras oficiais: Letras.mus.br (texto limpo) + CifraClub (marcadores de seção + tom)
4. `transcript_aligner.py`: SequenceMatcher alinha cada entry da transcrição com a linha mais parecida da letra oficial
5. Section builder agrupa entries consecutivas por seção → mapa da performance

**Stack:** Python FastAPI, Gemini 2.5 Flash (REST direto, sem SDK), vanilla JS frontend, SQLite cache

**O que funciona:**
- Detecção de 3 músicas no medley de teste (Nada Além de Ti, Com Muito Louvor, Creio Que Tu És a Cura)
- Timestamps reais da transcrição (não do LLM)
- Seções verse/chorus detectadas por merge Letras+CifraClub + heurística de stanzas
- YouTube player com sync linha a linha (cada linha clicável com timestamp)
- DB cache (SQLite) — re-análise só quando forçada
- Split-pane layout (letras à esquerda, player à direita)

**O que precisa refinar:**
- Section types nem sempre corretos (intro vs verse, chorus boundaries)
- Blocos curtos espúrios ainda aparecem ocasionalmente
- Sync karaokê funciona mas pode ter gaps em trechos espontâneos
- `song_analyzer.py` ainda existe mas não é mais usado (pode ser removido)

**Why:** Pipeline anterior dependia do Gemini para timestamps, seções e letras — tudo alucinado e inconsistente. Pipeline atual usa Gemini apenas para identificar títulos e o resto é determinístico.

**How to apply:** Ao retomar, focar no refinamento do alinhamento (transcript_aligner.py) e na qualidade dos section types. O frontend está funcional.
