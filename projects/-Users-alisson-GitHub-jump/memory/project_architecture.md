---
name: Jump architecture patterns
description: Coding patterns from copilot-instructions.md — controller/task/repository structure, naming conventions, ACL
type: project
---

Full pattern guide is in `.github/copilot-instructions.md`. Reference module: `areas`.

Controller → Task → Repository. Never use DB facade in controllers or tasks.

All controllers are single-action with `run()` method. Naming: `{Acao}{Modulo}Controller`.

Requests extend `BaseRequest` (HashId + Sanitizer traits). Have `$urlParameters` and `$decode` arrays. ACL check in `authorize()`: `Auth::user()->hasPermission('{modulo}.{acao}')`.

Permissions format: `{modulo}.{acao}` (e.g. `areas.edit`). Generate with `php artisan acl:generate`.

Views: `resources/views/app/{modulo}/{acao}-{modulo}.blade.php`. Extend `layouts.master`. Use `$this->callView()` in controllers.

JS assets: `public/assets/js/app/{modulo}/`.

Models use `FilterQueryString` trait. Binding in `RepositoryServiceProvider`.

**Why:** Established codebase convention, enforced via GrumPHP.
**How to apply:** Always follow these patterns when adding new features. Use `areas` module as reference.
