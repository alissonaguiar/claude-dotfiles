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

# Load .env if present
if [ -f "$DOTFILES_DIR/.env" ]; then
  export $(grep -v '^#' "$DOTFILES_DIR/.env" | xargs)
  echo "[ok] .env loaded"
else
  echo "[warn] .env not found — copy .env.example to .env and fill in your API keys"
fi

# 1. settings.json
echo ""
echo "--> Copying settings.json..."
cp "$DOTFILES_DIR/settings.json" "$CLAUDE_DIR/settings.json"
echo "    [ok] settings.json"

# 2. settings.local.json
echo "--> Copying settings.local.json..."
cp "$DOTFILES_DIR/settings.local.json" "$CLAUDE_DIR/settings.local.json"
echo "    [ok] settings.local.json"

# 3. history.jsonl
if [ -f "$DOTFILES_DIR/history.jsonl" ]; then
  echo "--> Copying history.jsonl..."
  cp "$DOTFILES_DIR/history.jsonl" "$CLAUDE_DIR/history.jsonl"
  echo "    [ok] history.jsonl"
fi

# 4. Custom skills
echo "--> Copying custom skills..."
mkdir -p "$CLAUDE_DIR/skills"
for skill_dir in "$DOTFILES_DIR/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  cp -r "$skill_dir" "$CLAUDE_DIR/skills/$skill_name"
  echo "    [ok] skill: $skill_name"
done

# 5. Memory (projects)
if [ -d "$DOTFILES_DIR/projects" ]; then
  echo "--> Copying project memories..."
  mkdir -p "$CLAUDE_DIR/projects"
  cp -r "$DOTFILES_DIR/projects/." "$CLAUDE_DIR/projects/"
  echo "    [ok] project memories"
fi

# 6. claude.json (MCP servers) — substitui variáveis de ambiente
echo "--> Configuring ~/.claude.json (MCP servers)..."
if [ -f "$HOME/.claude.json" ]; then
  cp "$HOME/.claude.json" "$HOME/.claude.json.bak"
  echo "    [ok] backup saved to ~/.claude.json.bak"
fi

# Merge mcpServers into existing ~/.claude.json (or create new)
python3 - <<'PYEOF'
import json, os, re

dotfiles = os.path.dirname(os.path.abspath(__file__)) if '__file__' in dir() else os.getcwd()
example_path = os.path.join(os.path.expanduser('~'), 'GitHub', 'claude-dotfiles', 'claude.json.example')
target_path = os.path.expanduser('~/.claude.json')

with open(example_path) as f:
    example = json.load(f)

# Substitute env vars
def sub_env(obj):
    if isinstance(obj, str):
        return re.sub(r'\$\{(\w+)\}', lambda m: os.environ.get(m.group(1), m.group(0)), obj)
    if isinstance(obj, dict):
        return {k: sub_env(v) for k, v in obj.items()}
    if isinstance(obj, list):
        return [sub_env(i) for i in obj]
    return obj

example = sub_env(example)

# Merge into existing .claude.json
target = {}
if os.path.exists(target_path):
    with open(target_path) as f:
        target = json.load(f)

target.setdefault('mcpServers', {}).update(example.get('mcpServers', {}))

with open(target_path, 'w') as f:
    json.dump(target, f, indent=2)

print('    [ok] ~/.claude.json updated with MCP servers')
PYEOF

echo ""
echo "==> Core files installed."
echo ""
echo "==> Next steps — install plugins:"
echo ""
echo "    claude plugin install superpowers@claude-plugins-official"
echo "    claude plugin install frontend-design@claude-plugins-official"
echo "    claude plugin install everything-claude-code@everything-claude-code"
echo "    claude plugin install bmad-method-lifecycle@bmad-method"
echo "    claude plugin install bitwize-music@bitwize-music"
echo ""
echo "    Custom marketplaces (add before installing):"
echo "    claude plugin marketplace add everything-claude-code https://github.com/affaan-m/everything-claude-code"
echo "    claude plugin marketplace add bmad-method https://github.com/bmad-code-org/bmad-method"
echo "    claude plugin marketplace add bitwize-music https://github.com/bitwize-music-studio/claude-ai-music-skills"
echo ""
echo "==> Also install manually:"
echo "    - Playwright MCP Bridge Chrome extension (ID: mmlmfjhmonkocbjadbfplnigmagldckm)"
echo "    - gcloud CLI: https://cloud.google.com/sdk/docs/install"
echo "    - Node.js 18+"
echo ""
echo "Done!"
