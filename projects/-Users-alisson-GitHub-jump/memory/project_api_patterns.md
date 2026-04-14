---
name: API Enterprise — Padrões e Armadilhas
description: Padrões técnicos e armadilhas descobertas durante o refactor da API enterprise (Fractal, HashId, testes, sanitizeInput)
type: feedback
---

Padrões consolidados para controllers da API enterprise no Jump:

**Why:** Descobertos durante o refactor de 183 controllers — erros recorrentes que custaram tempo.

**How to apply:** Seguir esses padrões em qualquer novo controller de API ou ao revisar código existente.

---

**Transformer:** Sempre estende `TransformerAbstract` + `HashIdTrait`. IDs sempre via `$this->encode($model->id)`.

**ControllerApi response methods:**
- `responseWithSuccessCode(Transformers::class, $data)` → 200
- `responseWithSuccessCreatedCode(Transformers::class, $data)` → 201
- `responseNoContentStatuscode()` → 204

**@SuppressWarnings:** Obrigatório em TODOS os controllers com `run()` que não usa o `$request` diretamente (Index e FindById).

**sanitizeInput vs validated():** Quando a web Request tem FK em `$decode` mas NÃO em `rules()`, usar `sanitizeInput(['campo'])` — `validated()` descarta campos que não estão em `rules()`.

**CreateSkillTask:** Retorna `['skill' => $model, ...]` — controller deve usar `$result['skill']`.

**Testes — guard 'api':** `$this->actingAs($user, 'api')` — sem o guard 'api', o teste falha silenciosamente.

**Testes — HashId em URLs:** `Hashids::encode($model->id)` para rotas com `{id}`. TimeEntries é exceção — usa int puro.

**Testes — paginação:** `assertJsonStructure(['data', 'meta', 'available_includes'])` — `meta` obrigatório.

**Destroy tasks:** Chamar `findById($id)` antes de `delete($id)` para garantir 404 se não encontrado.
