---
name: .claudeignore in Python projects
description: Python projects need .claudeignore — .gitignore alone does not prevent Claude from scanning .venv
type: feedback
---

Always check for `.claudeignore` in Python projects. `.gitignore` is NOT enough — Claude indexes files independently and will scan `.venv` (can be 10k+ files) unless `.claudeignore` explicitly excludes it.

**Why:** IR 2026 had `.venv` with 9,931 files and no `.claudeignore`, causing Claude to be slow. Discovered and fixed 2026-04-01.

**How to apply:** When opening any Python project, check if `.claudeignore` exists. If not, create one that excludes at minimum: `.venv/`, `__pycache__/`, `*.pyc`, `.pytest_cache/`, `.mypy_cache/`, `dist/`, `build/`.
