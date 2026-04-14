---
name: feedback_design_preferences
description: User's design preferences for the performance output — chronological blocks, line-by-line sync, minimal spontaneous markers
type: feedback
---

Preferências de design aprovadas:
- **Blocos cronológicos:** quando muda de música, novo bloco (mesmo que a música já tenha aparecido antes no medley)
- **Mapa da performance:** grupos coloridos por música com badges de seção (V1, R, P, etc.)
- **Espontâneo ultra-discreto:** ponto vermelho minúsculo (5px, 30% opacity) entre blocos. Texto "~ ministração espontânea ~" em itálico durante playback
- **Repetições completas:** se cantou "Com muito louvor" 6x, mostrar 6 linhas (opção A)
- **Introdução = instrumental:** se [Intro] tem texto cantado, reclassificar para [Estrofe]
- **Sync linha a linha:** cada linha é clicável e posiciona o vídeo no timestamp exato
- **Auto-scroll pausa** quando o usuário rola manualmente (volta após 5s)

**Why:** O output é um roteiro para bandas reproduzirem a performance. Precisa ser fiel ao que aconteceu no vídeo.

**How to apply:** Seguir estas preferências ao renderizar o mapa e as letras. Não colapsar repetições, não omitir linhas, não misturar espontâneo com música.
