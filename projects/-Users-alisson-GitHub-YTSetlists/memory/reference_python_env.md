---
name: reference_python_env
description: Python environment details — 3.9 via Xcode, package paths, numpy conflict with 3.13
type: reference
---

- Python 3.9 via `/Library/Developer/CommandLineTools/usr/bin/python3`
- Pacotes em `/Users/alisson/Library/Python/3.9/lib/python/site-packages`
- uvicorn em `/Users/alisson/Library/Python/3.9/bin/uvicorn`
- `/opt/homebrew/lib/python3.13/site-packages/` está no sys.path e causa conflitos (numpy, cryptography)
- `google-genai` SDK não funciona (conflito cryptography) — usamos REST direto via httpx
- `faster-whisper` não funciona (conflito numpy) — usamos Gemini audio transcription como fallback
- pip3 instala para Python 3.9
- Servidor: `./run.sh` ou `/Users/alisson/Library/Python/3.9/bin/uvicorn backend.main:app --host 0.0.0.0 --port 8000`
