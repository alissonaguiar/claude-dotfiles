---
name: GEO Scorecard — Deploy Status
description: Estado atual do deploy do projeto no GCP, solução de auth e pipeline CI/CD
type: project
---

Deploy funcionando em produção. Pipeline resolvido em 2026-03-27.

**Why:** `FIREBASE_TOKEN` foi deprecado/quebrado pelo Firebase. Org policy do GCP bloqueia criação de SA keys (`iam.managed.disableServiceAccountKeyCreation`). Firebase-tools CLI não suporta credenciais WIF (`external_account`).

**How to apply:** Se o deploy quebrar de novo, não tentar firebase-tools com GOOGLE_APPLICATION_CREDENTIALS — não funciona com WIF. O script Python é a solução correta. Não criar SA keys (bloqueado por org policy).

## Arquitetura em produção

- **Frontend:** Firebase Hosting → `geoscorecard.webjump.ai`
- **Backend:** Google Apps Script (externo ao GCP) — recebe eventos beacon → Google Sheets
- **CI/CD:** GitHub Actions (`.github/workflows/deploy.yml`) — push no `master` = deploy automático
- **Sem Cloud Functions, sem Firestore** (arquitetura simplificada)

## GCP

- **Projeto:** `devops-prd-460019`
- **Site ID:** `devops-prd-460019`
- Firebase Hosting: ativo, domínio customizado conectado, SSL válido

## Solução de autenticação (2026-03-27)

Migrado de `FIREBASE_TOKEN` (deprecado) para **Workload Identity Federation**:

- WIF pool: `wjump-pool/github-provider` (já existia no GCP, project number `272854887542`)
- SA: `github-actions-deployer@devops-prd-460019.iam.gserviceaccount.com`
  - Role: `firebasehosting.admin`
  - Binding WIF adicionado para `alerodrigues-wj/GEO-scorecard`
- Workflow usa `google-github-actions/auth@v2` com `workload_identity_provider` + `service_account`
- **Nenhum secret no GitHub necessário**

## Deploy script

Firebase-tools CLI não suporta credenciais WIF (tipo `external_account`).
Solução: `scripts/firebase_deploy.py` — deploy direto via Firebase Hosting REST API:
1. `gcloud auth application-default print-access-token` para obter token
2. Cria versão, faz upload dos arquivos (gzip + sha256), finaliza e cria release
3. Detalhe crítico: `gzip.compress(..., mtime=0)` para hash determinístico

## Pendências

- OG Image & Favicon: apontam para CDN externo (`aircompany.ai`) — hospedar localmente quando possível
