---
name: reference_youtube_cookies
description: YouTube rate-limits yt-dlp; cookies.txt file is required and already configured
type: reference
---

YouTube bloqueia yt-dlp com rate limit. Solução configurada: arquivo `cookies.txt` exportado do Chrome via extensão "Get cookies.txt LOCALLY", salvo na raiz do projeto. Config no `.env`: `YOUTUBE_COOKIES_FILE=cookies.txt`. O `config.py` resolve para caminho absoluto automaticamente.

O servidor roda via uvicorn com Python 3.9 do Xcode CommandLineTools (`/Library/Developer/CommandLineTools/usr/bin/python3`). Pacotes instalados em `/Users/alisson/Library/Python/3.9/lib/python/site-packages`.
