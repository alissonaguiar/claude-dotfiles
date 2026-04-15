# Bitwarden Secrets Management — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Integrar o Bitwarden CLI ao `claude-dotfiles` para que secrets (API keys de MCP servers) sejam armazenados como itens individuais no Bitwarden e recuperados automaticamente no `install.sh` e `sync.sh`.

**Architecture:** Um arquivo `secrets.json` (commitado) mapeia env vars → nomes de itens no Bitwarden. Um script auxiliar `scripts/bw-helpers.sh` encapsula todas as chamadas ao CLI do Bitwarden. O `install.sh` chama esse helper para gerar o `.env` local; o `sync.sh` chama para criar/atualizar itens no vault.

**Tech Stack:** Bash, Bitwarden CLI (`bw`), Python 3 (já usado no install.sh para substituição de vars), jq (parsing JSON em shell)

---

## File Map

| Ação | Arquivo | Responsabilidade |
|---|---|---|
| Criar | `secrets.json` | Mapa de env vars → itens Bitwarden |
| Criar | `scripts/bw-helpers.sh` | Funções reutilizáveis do Bitwarden CLI |
| Modificar | `install.sh` | Usar bw-helpers para gerar .env |
| Modificar | `sync.sh` | Usar bw-helpers para push de secrets |
| Modificar | `README.md` | Atualizar instruções de restore |
| Manter | `.env.example` | Fallback de documentação (sem mudanças) |

---

## Task 1: Criar `secrets.json`

**Files:**
- Create: `secrets.json`

- [ ] **Step 1: Criar o arquivo**

```json
{
  "STITCH_X_GOOG_API_KEY": {
    "item": "Stitch MCP - API Key",
    "field": "password",
    "notes": "Obter em stitch.withgoogle.com → Settings → API Keys"
  }
}
```

Salvar em `~/GitHub/claude-dotfiles/secrets.json`.

- [ ] **Step 2: Verificar que .gitignore NÃO ignora secrets.json**

```bash
cd ~/GitHub/claude-dotfiles
cat .gitignore | grep secrets
```
Esperado: nenhuma saída (secrets.json não está ignorado — é o mapa, não os valores).

- [ ] **Step 3: Commit**

```bash
cd ~/GitHub/claude-dotfiles
git add secrets.json
git commit -m "feat: add secrets.json mapping for Bitwarden items"
```

---

## Task 2: Criar `scripts/bw-helpers.sh`

**Files:**
- Create: `scripts/bw-helpers.sh`

Este script expõe funções reutilizáveis. É sourced pelos outros scripts, não executado diretamente.

- [ ] **Step 1: Criar o diretório e o arquivo**

```bash
mkdir -p ~/GitHub/claude-dotfiles/scripts
```

Criar `scripts/bw-helpers.sh`:

```bash
#!/bin/bash
# Bitwarden helper functions — source this file, don't execute directly
# Usage: source scripts/bw-helpers.sh

# Verifica se bw está instalado e o vault está desbloqueado.
# Retorna 0 se ok, 1 se não instalado, 2 se não autenticado/bloqueado.
bw_check_auth() {
  if ! command -v bw &>/dev/null; then
    echo "[erro] Bitwarden CLI não instalado. Rode: brew install bitwarden-cli"
    return 1
  fi

  local status
  status=$(bw status 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin).get('status','locked'))" 2>/dev/null || echo "locked")

  if [ "$status" = "unauthenticated" ]; then
    echo "[erro] Bitwarden não autenticado. Rode: bw login"
    return 2
  fi

  if [ "$status" = "locked" ]; then
    echo "[erro] Vault bloqueado. Rode: export BW_SESSION=\$(bw unlock --raw)"
    return 2
  fi

  return 0
}

# Garante que a pasta $1 existe no vault.
# Imprime o folder ID.
bw_ensure_folder() {
  local folder_name="$1"
  local folder_id

  folder_id=$(bw list folders 2>/dev/null \
    | python3 -c "
import sys, json
folders = json.load(sys.stdin)
match = next((f for f in folders if f['name'] == '$folder_name'), None)
print(match['id'] if match else '')
" 2>/dev/null)

  if [ -z "$folder_id" ]; then
    folder_id=$(bw create folder "$folder_name" 2>/dev/null \
      | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])" 2>/dev/null)
    echo "[ok] Pasta '$folder_name' criada no Bitwarden" >&2
  fi

  echo "$folder_id"
}

# Busca o valor de um item pelo nome.
# $1 = nome do item (ex: "Stitch MCP - API Key")
# Imprime o valor ou string vazia se não encontrado.
bw_get_secret() {
  local item_name="$1"
  bw get password "$item_name" 2>/dev/null || echo ""
}

# Nota: create/update de itens é feito diretamente em Python no sync.sh
# por ser mais robusto para manipulação de JSON complexo.
```

- [ ] **Step 2: Tornar executável**

```bash
chmod +x ~/GitHub/claude-dotfiles/scripts/bw-helpers.sh
```

- [ ] **Step 3: Teste manual das funções de auth**

```bash
cd ~/GitHub/claude-dotfiles
source scripts/bw-helpers.sh
bw_check_auth
echo "Exit code: $?"
```

Esperado com vault desbloqueado: `Exit code: 0`  
Esperado com vault bloqueado: `[erro] Vault bloqueado...` + `Exit code: 2`

- [ ] **Step 4: Commit**

```bash
cd ~/GitHub/claude-dotfiles
git add scripts/bw-helpers.sh
git commit -m "feat: add bw-helpers.sh with Bitwarden CLI functions"
```

---

## Task 3: Atualizar `install.sh` para usar Bitwarden

**Files:**
- Modify: `install.sh`

- [ ] **Step 1: Substituir o bloco de `.env` no install.sh**

Substituir o bloco atual (linhas que fazem `if [ -f "$DOTFILES_DIR/.env" ]`) pelo novo bloco que usa bw-helpers:

```bash
#!/bin/bash
# Claude Code dotfiles installer
# Usage: ./install.sh
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "==> Claude Dotfiles Installer"
echo "    Source: $DOTFILES_DIR"
echo "    Target: $CLAUDE_DIR"
echo ""

# --- Secrets via Bitwarden ---
source "$DOTFILES_DIR/scripts/bw-helpers.sh"

echo "--> Carregando secrets do Bitwarden..."
if bw_check_auth; then
  # Gerar .env a partir do secrets.json
  python3 - <<'PYEOF'
import json, subprocess, os, sys

secrets_path = os.path.join(os.environ.get('DOTFILES_DIR', '.'), 'secrets.json')
env_path = os.path.join(os.environ.get('DOTFILES_DIR', '.'), '.env')

with open(secrets_path) as f:
    secrets = json.load(f)

lines = []
missing = []
for env_var, meta in secrets.items():
    item_name = meta['item']
    result = subprocess.run(
        ['bw', 'get', 'password', item_name],
        capture_output=True, text=True
    )
    value = result.stdout.strip()
    if value:
        lines.append(f'{env_var}={value}')
        print(f'    [ok] {env_var} ({item_name})')
    else:
        missing.append(item_name)
        print(f'    [warn] não encontrado no Bitwarden: {item_name}', file=sys.stderr)

with open(env_path, 'w') as f:
    f.write('\n'.join(lines) + '\n')

if missing:
    print(f'\n    [warn] {len(missing)} secret(s) ausente(s) — configure no Bitwarden e re-rode install.sh')
PYEOF
  export $(grep -v '^#' "$DOTFILES_DIR/.env" | xargs) 2>/dev/null || true
  echo "    [ok] .env gerado"
else
  echo "    [warn] Bitwarden não disponível — tentando .env local..."
  if [ -f "$DOTFILES_DIR/.env" ]; then
    export $(grep -v '^#' "$DOTFILES_DIR/.env" | xargs)
    echo "    [ok] .env local carregado"
  else
    echo "    [warn] Sem .env e sem Bitwarden — MCP servers sem autenticação"
  fi
fi
echo ""
```

O restante do `install.sh` (steps 1-6: settings, skills, memories, claude.json) permanece **idêntico** ao atual.

- [ ] **Step 2: Verificar sintaxe do script**

```bash
bash -n ~/GitHub/claude-dotfiles/install.sh
echo "Syntax OK: $?"
```

Esperado: `Syntax OK: 0`

- [ ] **Step 3: Teste de dry-run (sem executar de verdade)**

```bash
cd ~/GitHub/claude-dotfiles
DOTFILES_DIR=$(pwd) bash -c 'source scripts/bw-helpers.sh && bw_check_auth && echo "auth ok"'
```

Esperado: `auth ok`

- [ ] **Step 4: Commit**

```bash
cd ~/GitHub/claude-dotfiles
git add install.sh
git commit -m "feat: install.sh fetches secrets from Bitwarden"
```

---

## Task 4: Atualizar `sync.sh` para fazer push de secrets ao Bitwarden

**Files:**
- Modify: `sync.sh`

- [ ] **Step 1: Substituir o conteúdo do sync.sh**

```bash
#!/bin/bash
# Sync current ~/.claude config into this dotfiles repo + push secrets to Bitwarden
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "==> Sincronizando ~/.claude -> $DOTFILES_DIR"

# --- 1. Sync secrets para o Bitwarden ---
source "$DOTFILES_DIR/scripts/bw-helpers.sh"

echo "--> Sincronizando secrets no Bitwarden..."
if bw_check_auth; then
  if [ ! -f "$DOTFILES_DIR/.env" ]; then
    echo "    [warn] .env não encontrado — pulando sync de secrets"
  else
    FOLDER_ID=$(bw_ensure_folder "claude-dotfiles")

    python3 - <<PYEOF
import json, subprocess, os

secrets_path = os.path.join('$DOTFILES_DIR', 'secrets.json')
env_path = os.path.join('$DOTFILES_DIR', '.env')
folder_id = '$FOLDER_ID'

with open(secrets_path) as f:
    secrets = json.load(f)

# Parse .env
env_values = {}
with open(env_path) as f:
    for line in f:
        line = line.strip()
        if line and not line.startswith('#') and '=' in line:
            key, _, val = line.partition('=')
            env_values[key.strip()] = val.strip()

for env_var, meta in secrets.items():
    if env_var not in env_values:
        print(f'    [warn] {env_var} não está no .env — pulando')
        continue

    item_name = meta['item']
    username = env_var
    password = env_values[env_var]
    notes = meta.get('notes', '')

    # Verifica se item existe
    result = subprocess.run(
        ['bw', 'list', 'items', '--search', item_name],
        capture_output=True, text=True
    )
    items = json.loads(result.stdout or '[]')
    match = next((i for i in items if i['name'] == item_name), None)

    if match:
        # Atualizar
        item = match.copy()
        item['login']['password'] = password
        item['login']['username'] = username
        encoded = subprocess.run(['bw', 'encode'], input=json.dumps(item),
                                  capture_output=True, text=True).stdout.strip()
        subprocess.run(['bw', 'edit', 'item', match['id']], input=encoded,
                       capture_output=True, text=True)
        print(f'    [ok] atualizado: {item_name}')
    else:
        # Criar
        new_item = {
            'organizationId': None,
            'folderId': folder_id,
            'type': 1,
            'name': item_name,
            'notes': notes,
            'login': {
                'username': username,
                'password': password,
                'uris': []
            }
        }
        encoded = subprocess.run(['bw', 'encode'], input=json.dumps(new_item),
                                  capture_output=True, text=True).stdout.strip()
        subprocess.run(['bw', 'create', 'item'], input=encoded,
                       capture_output=True, text=True)
        print(f'    [ok] criado: {item_name}')

PYEOF

    bw sync > /dev/null 2>&1
    echo "    [ok] Bitwarden sincronizado"
  fi
else
  echo "    [warn] Bitwarden não disponível — pulando sync de secrets"
fi

# --- 2. Sync arquivos de config ---
echo ""
echo "--> Sincronizando arquivos de config..."

cp "$CLAUDE_DIR/settings.json"       "$DOTFILES_DIR/settings.json"
cp "$CLAUDE_DIR/settings.local.json" "$DOTFILES_DIR/settings.local.json"
cp "$CLAUDE_DIR/history.jsonl"       "$DOTFILES_DIR/history.jsonl"
echo "  [ok] settings + history"

# Skills
rm -rf "$DOTFILES_DIR/skills"
mkdir -p "$DOTFILES_DIR/skills"
for skill_dir in "$CLAUDE_DIR/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  cp -r "$skill_dir" "$DOTFILES_DIR/skills/$skill_name"
  echo "  [ok] skill: $skill_name"
done

# Project memories
rm -rf "$DOTFILES_DIR/projects"
cp -r "$CLAUDE_DIR/projects" "$DOTFILES_DIR/projects"
echo "  [ok] project memories"

echo ""
echo "==> Done. Review com: git diff"
echo "    Commit com: git add -A && git commit -m 'sync: \$(date +%Y-%m-%d)' && git push"
```

- [ ] **Step 2: Verificar sintaxe**

```bash
bash -n ~/GitHub/claude-dotfiles/sync.sh
echo "Syntax OK: $?"
```

Esperado: `Syntax OK: 0`

- [ ] **Step 3: Commit**

```bash
cd ~/GitHub/claude-dotfiles
git add sync.sh
git commit -m "feat: sync.sh pushes secrets to Bitwarden"
```

---

## Task 5: Popular o secret do Stitch no Bitwarden e testar end-to-end

**Files:** nenhum — teste de integração

- [ ] **Step 1: Garantir que o Bitwarden está desbloqueado**

```bash
export BW_SESSION=$(bw unlock --raw)
```

Inserir a master password quando solicitado.

- [ ] **Step 2: Rodar sync.sh para criar o item no Bitwarden**

Garantir que o `.env` local tem o valor real:
```bash
cat ~/GitHub/claude-dotfiles/.env
```
Esperado: linha com `STITCH_X_GOOG_API_KEY=AQ.Ab8RN...` (valor real).

Rodar o sync:
```bash
cd ~/GitHub/claude-dotfiles
./sync.sh
```

Esperado:
```
--> Sincronizando secrets no Bitwarden...
    [ok] criado: Stitch MCP - API Key
    [ok] Bitwarden sincronizado
```

- [ ] **Step 3: Verificar no Bitwarden CLI**

```bash
bw list items --folderID $(bw list folders | python3 -c "import sys,json; folders=json.load(sys.stdin); print(next(f['id'] for f in folders if f['name']=='claude-dotfiles'))")
```

Esperado: JSON com item `"Stitch MCP - API Key"` listado.

- [ ] **Step 4: Simular restore — deletar .env e rodar install.sh**

```bash
rm ~/GitHub/claude-dotfiles/.env
cd ~/GitHub/claude-dotfiles
./install.sh
```

Esperado:
```
--> Carregando secrets do Bitwarden...
    [ok] STITCH_X_GOOG_API_KEY (Stitch MCP - API Key)
    [ok] .env gerado
```

- [ ] **Step 5: Verificar que o .env foi recriado com o valor correto**

```bash
cat ~/GitHub/claude-dotfiles/.env
```

Esperado: `STITCH_X_GOOG_API_KEY=AQ.Ab8RN...` (mesmo valor de antes).

- [ ] **Step 6: Commit final + push**

```bash
cd ~/GitHub/claude-dotfiles
git add -A
git commit -m "sync: $(date +%Y-%m-%d) — post Bitwarden integration"
git push
```

---

## Task 6: Atualizar README

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Atualizar seção "Restaurar em máquina nova"**

Substituir o bloco de restore no README pelo seguinte:

```markdown
## Restaurar em máquina nova

### 1. Pré-requisitos

\`\`\`bash
# Claude Code CLI
# Instalar em: https://claude.ai/download

# Node.js + Bitwarden CLI
brew install node bitwarden-cli

# gcloud CLI
brew install --cask google-cloud-sdk
gcloud auth login --account alisson@webjump.ai
gcloud config set project solid-choir-461101-t3
gcloud auth application-default login --account alisson@webjump.ai
\`\`\`

### 2. Clonar e autenticar

\`\`\`bash
git clone git@github.com:alissonaguiar/claude-dotfiles.git ~/GitHub/claude-dotfiles
cd ~/GitHub/claude-dotfiles

# Autenticar no Bitwarden (uma vez)
bw login
export BW_SESSION=$(bw unlock --raw)
\`\`\`

### 3. Instalar (secrets buscados automaticamente do Bitwarden)

\`\`\`bash
./install.sh
\`\`\`

### 4. Instalar plugins

\`\`\`bash
# Marketplaces customizados (adicionar primeiro)
claude plugin marketplace add everything-claude-code https://github.com/affaan-m/everything-claude-code
claude plugin marketplace add bmad-method https://github.com/bmad-code-org/bmad-method
claude plugin marketplace add bitwize-music https://github.com/bitwize-music-studio/claude-ai-music-skills

# Plugins
claude plugin install superpowers@claude-plugins-official
claude plugin install frontend-design@claude-plugins-official
claude plugin install everything-claude-code@everything-claude-code
claude plugin install bmad-method-lifecycle@bmad-method
claude plugin install bitwize-music@bitwize-music
\`\`\`

### 5. Extensão do Chrome

Instalar **Playwright MCP Bridge** no Chrome: ID `mmlmfjhmonkocbjadbfplnigmagldckm`

---

## Sincronizar (atualizar backup + Bitwarden)

\`\`\`bash
export BW_SESSION=$(bw unlock --raw)
cd ~/GitHub/claude-dotfiles && ./sync.sh && git add -A && git commit -m "sync: $(date +%Y-%m-%d)" && git push
\`\`\`

---

## Adicionar novo secret

1. Adicionar entrada em \`secrets.json\`
2. Adicionar \`KEY=valor\` no \`.env\` local
3. Rodar sync — cria item no Bitwarden e commita o mapa

\`\`\`bash
export BW_SESSION=$(bw unlock --raw)
cd ~/GitHub/claude-dotfiles && ./sync.sh && git add -A && git commit -m "feat: add <nome> secret" && git push
\`\`\`
```

- [ ] **Step 2: Commit**

```bash
cd ~/GitHub/claude-dotfiles
git add README.md
git commit -m "docs: update README with Bitwarden workflow"
git push
```
