#!/bin/bash
# Sync current ~/.claude config into this dotfiles repo + push secrets to Bitwarden
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

# Repo privado (full backup, incluindo history + memories + settings.local)
PRIVATE_DIR="$HOME/GitHub/claude-dotfiles-private"

echo "==> Sincronizando ~/.claude -> $DOTFILES_DIR"

# --- 1. Sync secrets para o Bitwarden ---
source "$DOTFILES_DIR/scripts/bw-helpers.sh"

echo "--> Sincronizando secrets no Bitwarden..."
if bw_check_auth; then
  if [ ! -f "$DOTFILES_DIR/.env" ]; then
    echo "    [warn] .env não encontrado — pulando sync de secrets"
  else
    FOLDER_ID=$(bw_ensure_folder "claude-dotfiles")

    DOTFILES_DIR="$DOTFILES_DIR" FOLDER_ID="$FOLDER_ID" python3 - <<'PYEOF'
import json, subprocess, os

secrets_path = os.path.join(os.environ.get('DOTFILES_DIR', '.'), 'secrets.json')
env_path = os.path.join(os.environ.get('DOTFILES_DIR', '.'), '.env')
folder_id = os.environ.get('FOLDER_ID', '')

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
[ -f "$CLAUDE_DIR/history.jsonl" ] && cp "$CLAUDE_DIR/history.jsonl" "$DOTFILES_DIR/history.jsonl"
echo "  [ok] settings + history"

# Skills
rm -rf "$DOTFILES_DIR/skills"
mkdir -p "$DOTFILES_DIR/skills"
for skill_dir in "$CLAUDE_DIR/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  cp -r "$skill_dir" "$DOTFILES_DIR/skills/$skill_name"
  echo "  [ok] skill: $skill_name"
done

# Project memories (só no repo público — sem jsonl/meta)
rm -rf "$DOTFILES_DIR/projects"
mkdir -p "$DOTFILES_DIR/projects"
find "$CLAUDE_DIR/projects" -name "*.md" | while read -r f; do
  rel="${f#$CLAUDE_DIR/}"
  dest="$DOTFILES_DIR/$rel"
  mkdir -p "$(dirname "$dest")"
  cp "$f" "$dest"
done
echo "  [ok] project memories (*.md only)"

# --- 3. Sync para o repo PRIVADO (tudo, incluindo history + settings.local) ---
if [ -d "$PRIVATE_DIR" ]; then
  echo ""
  echo "--> Sincronizando repo privado ($PRIVATE_DIR)..."

  cp "$CLAUDE_DIR/settings.json"       "$PRIVATE_DIR/settings.json"
  cp "$CLAUDE_DIR/settings.local.json" "$PRIVATE_DIR/settings.local.json"
  [ -f "$CLAUDE_DIR/history.jsonl" ] && cp "$CLAUDE_DIR/history.jsonl" "$PRIVATE_DIR/history.jsonl"

  # Skills no privado também
  rm -rf "$PRIVATE_DIR/skills"
  mkdir -p "$PRIVATE_DIR/skills"
  for skill_dir in "$CLAUDE_DIR/skills"/*/; do
    skill_name=$(basename "$skill_dir")
    cp -r "$skill_dir" "$PRIVATE_DIR/skills/$skill_name"
  done

  # Memórias completas no privado
  rm -rf "$PRIVATE_DIR/projects"
  cp -r "$CLAUDE_DIR/projects" "$PRIVATE_DIR/projects"

  # Copia também scripts/secrets do repo público para manter em sync
  cp "$DOTFILES_DIR/secrets.json"            "$PRIVATE_DIR/secrets.json"
  cp "$DOTFILES_DIR/claude.json.example"     "$PRIVATE_DIR/claude.json.example"
  cp "$DOTFILES_DIR/install.sh"              "$PRIVATE_DIR/install.sh"
  cp "$DOTFILES_DIR/sync.sh"                 "$PRIVATE_DIR/sync.sh"
  cp "$DOTFILES_DIR/README.md"               "$PRIVATE_DIR/README.md"
  cp -r "$DOTFILES_DIR/scripts"              "$PRIVATE_DIR/"
  cp -r "$DOTFILES_DIR/docs"                 "$PRIVATE_DIR/" 2>/dev/null || true

  echo "  [ok] repo privado atualizado"
else
  echo "  [warn] $PRIVATE_DIR não encontrado — pulando sync privado"
fi

echo ""
echo "==> Done. Review com: git diff"
echo "    Commit público: cd $DOTFILES_DIR && git add -A && git commit -m 'sync: \$(date +%Y-%m-%d)' && git push"
echo "    Commit privado: cd $PRIVATE_DIR && git add -A && git commit -m 'sync: \$(date +%Y-%m-%d)' && git push"
