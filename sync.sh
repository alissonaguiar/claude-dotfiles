#!/bin/bash
# Sync current ~/.claude config into this dotfiles repo
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "==> Syncing ~/.claude -> $DOTFILES_DIR"

cp "$CLAUDE_DIR/settings.json"       "$DOTFILES_DIR/settings.json"
cp "$CLAUDE_DIR/settings.local.json" "$DOTFILES_DIR/settings.local.json"
cp "$CLAUDE_DIR/history.jsonl"       "$DOTFILES_DIR/history.jsonl"

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

echo "==> Done. Review changes with: git diff"
echo "    Then commit: git add -A && git commit -m 'sync: \$(date +%Y-%m-%d)'"
