# claude-dotfiles

Backup portável da configuração do Claude Code.

## O que está aqui

| Arquivo/Dir | Descrição |
|---|---|
| `settings.json` | Plugins habilitados, hooks, modelo padrão |
| `settings.local.json` | Permissões de Bash/WebFetch |
| `history.jsonl` | Histórico de comandos do Claude |
| `claude.json.example` | MCP servers (sem API keys) |
| `.env.example` | Template das API keys necessárias |
| `skills/` | Skills customizadas (ui-ux-pro-max, air-brand-guidelines) |
| `projects/` | Memórias por projeto |
| `install.sh` | Script de restauração numa máquina nova |

## Restaurar em máquina nova

```bash
# 1. Clonar o repo
git clone git@github.com:SEU_USER/claude-dotfiles.git ~/GitHub/claude-dotfiles

# 2. Copiar e preencher as API keys
cp .env.example .env
# editar .env com as chaves reais

# 3. Rodar o installer
chmod +x install.sh
./install.sh
```

## Plugins (instalados separadamente)

Após rodar o `install.sh`:

```bash
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
```

## Dependências externas

- **Claude Code CLI**: instalar via site da Anthropic
- **Node.js 18+**: `brew install node`
- **gcloud CLI**: https://cloud.google.com/sdk/docs/install
- **Playwright MCP Bridge** (Chrome extension): ID `mmlmfjhmonkocbjadbfplnigmagldckm`

## Atualizar o backup

```bash
cd ~/GitHub/claude-dotfiles
./sync.sh   # copia arquivos atuais do ~/.claude para cá
git add -A && git commit -m "sync: $(date +%Y-%m-%d)"
git push
```
