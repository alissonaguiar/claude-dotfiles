---
name: API Enterprise Refactor Status
description: Status do refactor da API enterprise no Jump — PR #752 aberto para develop, aguardando revisão do arquiteto
type: project
---

O refactor completo da API enterprise foi concluído e está no PR webjump/Jump#752 (`feature/api-enterprise` → `develop`).

**Why:** O arquiteto rejeitou a implementação original (PR #752 com Passport + Resources + acesso direto a Models) e pediu refactor seguindo o `.github/copilot-instructions.md`.

**O que foi feito:**
- Laravel Passport removido, Sanctum `auth:api` restaurado
- Todos os 183 controllers de API refatorados para usar Tasks + Fractal Transformers + web Requests
- 24 Transformers novos criados
- `app/Http/Resources/` deletado completamente
- Subdiretórios `app/Http/Requests/*/api/` deletados (exceto TimeEntries e OvertimeRequests — usam guard de employee)
- 1095 testes passando (585 unit + 510 feature), GrumPHP verde

**Exceções documentadas:**
- `TimeEntries` e `OvertimeRequests` mantêm Requests API-específicos (web requests usam guard de employee, não admin)
- `GetLatestAllocationMonthApiRequest` mantido (ainda referenciado)

**How to apply:** Ao retomar, verificar se o arquiteto deu feedback no PR #752 antes de continuar.
