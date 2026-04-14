---
name: Projeto IR 2026
description: Pipeline Python para automatizar a declaração do IRPF 2026 (ano-base 2025) a partir de PDFs de informes de rendimentos
type: project
---

Pipeline de automação do IRPF 2026 pessoal (CPF 76057410068).

**Por que existe:** Automatizar a extração e consolidação de rendimentos de múltiplas fontes (XP, BTG, BB, NOMAD, Daycoval, etc.) para preencher o IRPF 2026.

**Como aplicar:** Contexto de declaração de imposto de renda pessoa física, ano-base 2025. Dados sensíveis (CPF, senhas derivadas do CPF) presentes no código.

## Estrutura

### Ingestão (`src/ingestion/`)
- `ingest.py` — pipeline principal: 8 extratores (edge, bb, btg_corretora, apex, rio_bravo, vortex, daycoval, comprovante_dirf, generico)
- `ingest_xp.py` — XP: proventos, day trade, operações normais, previdência, histórico
- `ingest_smartfolio.py` — PDF SmartFolio → tabela `smartfolio_ref`
- `ingest_declaracao.py` — importa declaração anterior (IRPF 2025, ano-base 2024)
- `ingest_nomad.py` — NOMAD (conta exterior): banking income report + investments IR taxes → bens_direitos (Grupo 06/03/07) + rendimentos tributáveis (dividendos exterior)

### Banco de dados (`src/database/`)
- `schema.py` — cria SQLite; tabelas: fontes, rendimentos_tributaveis, rendimentos_isentos, rendimentos_exclusivos, irrf, bens_direitos, smartfolio_ref, decl_anterior_*, xp_proventos, log_extracao, **checklist**
- Views: `v_confianca_bens`, `v_confianca_rendimentos` (usadas pelo módulo web)

### Reconciliação (`src/reconciliation/`)
- `engine.py` — motor de reconciliação: agrega dados por ficha IRPF e detecta divergências; status: ok / aviso (diff <5%) / divergente / sem_oficial; tolerância: R$1,00
- `ficha_map.py` — 7 fichas: tributaveis_pj, isentos_dividendos, isentos_fii, isentos_outros, exclusivo_jcp, exclusivo_aplic, bens_direitos

### Interface web (`src/web/`)
- `app.py` — Flask app com routes:
  - `/` — dashboard: progresso do checklist (pendente/conferido/transportado) e totais de confiança
  - `/ficha/<ficha_key>` — reconciliação por ficha IRPF
  - `/historico` — comparativo 2024 × 2025 por categoria
  - `/conferencia` — visão de cross-reference (reads `v_confianca_bens` + `v_confianca_rendimentos`)
  - `/fontes`, `/fonte/<id>` — lista e detalhe de arquivos importados

### Outros
- `src/confronto/confronto.py` — confronta SmartFolio × informes × XP Proventos (FIIs, dividendos, JCP)
- `src/reports/resumo.py` — relatório consolidado com estimativa do imposto pela tabela progressiva
- `_xp_debug.py` — script de debug para parsear PDFs XP

## Arquivos raiz
- `informes/` — PDFs dos informes (EDGE, XP, BTG, BB, Rio Bravo, Vortex, Daycoval, Apex, Oliveira Trust, MercadoPago, Qualicorp, Magazine Luiza, Transmissora, SmartFolio, NOMAD)
- `data/irpf.db` — banco SQLite com todos os dados extraídos
- `run.sh` — lança a interface web: `.venv/bin/python -m src.web.app`
- `CLAUDE.md` — vazio no momento

## Ambiente Python
Usar sempre `.venv/bin/python` (não o python do sistema/Homebrew). O fitz/PyMuPDF só está instalado no venv.
