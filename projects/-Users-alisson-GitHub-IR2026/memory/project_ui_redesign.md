---
name: UI/UX Redesign — Dark Theme + Dashboard
description: Histórico completo do redesign visual do IR2026 (dark theme glassmorphism + novo dashboard)
type: project
originSessionId: e4456c99-5175-4057-9d3b-e16d45c80f0a
---
## Status: Em andamento (2026-04-14)

Redesign completo da UI executado com o skill `ui-ux-pro-max`. Toda a aplicação usa agora um design system consistente.

**Why:** Aplicação original tinha tema claro, hardcoded colors em vários templates, sem hierarquia visual clara no dashboard.

**How to apply:** Não reverter para cores hardcoded. Sempre usar CSS vars. Não usar emojis como ícones de UI.

---

## Design System (style.css)

Tokens em `:root`:
- `--bg: #0B1222` / `--s1..s3` (superfícies)
- `--accent: #22C55E` (verde) / `--red: #F06969` / `--amber: #F5A623` / `--blue: #72B3F8`
- `--glass: rgba(19,31,53,.72)` + `--blur: blur(14px)` (glassmorphism)
- Font: IBM Plex Sans + IBM Plex Mono
- Sidebar fixa à esquerda (`--sidebar-w: 248px`)

**Regra CSS crítica:** `td` tem `background: var(--s1)` explícito (não transparent). Blocos `<style>` locais dentro de templates têm prioridade na cascade — sempre usar CSS vars e `!important` onde necessário para não vazar cores brancas.

---

## Templates já corrigidos (sem hardcoded colors)

Todos os templates abaixo foram auditados e corrigidos:
- `style.css` — design tokens completos
- `base.html` — sidebar com SVG icons Lucide, active state via `request.path`
- `ficha.html` — `tr.linha-conflito` usa `rgba(245,166,35,.07) !important`
- `conferencia.html` — amber glass cards, pill badges
- `resumo.html` — `.resumo-banner.alerta` usa CSS vars
- `_ativo_ficha.html` — source colors via vars
- `comparativo.html` — dark matrix table
- `_pdf_modal.html` — dark header/nav/body/buttons
- `busca.html` — input com `var(--s2)`, hover `var(--s2) !important`
- `_busca_resultados.html` — `color:var(--txt-3)`
- `_ignorados_ficha.html` — border/color via vars
- `_ativo_secao_footer.html` — "Outro valor" via var
- `preenchida.html`, `novos.html`, `comparativo.html` — muted text via vars
- `fontes.html`, `historico.html`, `ativo.html`, `aliases.html` — todos OK

---

## Conferência — 3 variantes

Rota `/conferencia` aceita `?v=` param (via `app.py`):
- `?v=` (default) → `conferencia.html` — padrão original melhorado + view switcher
- `?v=alert` → `conferencia_alert.html` — KPI dashboard grid no topo, row highlights, risk pills, sticky headers
- `?v=minimal` → `conferencia_minimal.html` — inline stats, conflicts em `<details>`, table sem row backgrounds, só left-border

---

## Dashboard — Novo (dashboard.html)

Substituiu o dashboard antigo. Seções:
1. **Hero row (3 colunas):** Progress ring SVG animado + Conferência KPI boxes + Conflicts/OK card
2. **Fichas grid:** 4 grupos (Tributáveis / Isentos / Excl.Definitiva / Bens), cards com borda superior colorida, SVG icon por ficha, mini progress bar, badge de status
3. **Quick links:** Pill links para todas as rotas

SVG ring: `r=32`, `circum=201.06`, `transform="rotate(-90 40 40)"`, glow via `<feGaussianBlur>`.
Entrada animada: `fadeSlideUp` staggered, respeitando `prefers-reduced-motion`.

---

## Playwright MCP — Token configurado

Token adicionado em:
`/Users/alisson/.claude/plugins/cache/everything-claude-code/everything-claude-code/1.9.0/.mcp.json`

```json
"playwright": {
  "command": "npx",
  "args": ["-y", "@playwright/mcp@0.0.68", "--extension"],
  "env": {
    "PLAYWRIGHT_MCP_EXTENSION_TOKEN": "DJFliFy-wBLZ-US5x5Ogrrf5S6aCYHqrIjq5MtoREjk"
  }
}
```

Requer reinício do Claude Code para o token ser carregado. Após reinício, `browser_navigate` e `browser_snapshot` devem funcionar sem "Extension connection timeout".
