# claude-dotfiles

Backup portável da configuração do Claude Code.
Repo: https://github.com/alissonaguiar/claude-dotfiles

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
| `sync.sh` | Script para atualizar o backup |

---

## Sincronizar (atualizar o backup)

Rodar sempre que mudar configuração, instalar plugin, acumular memórias, etc.:

```bash
cd ~/GitHub/claude-dotfiles && ./sync.sh && git add -A && git commit -m "sync: $(date +%Y-%m-%d)" && git push
```

---

## Restaurar em máquina nova

### 1. Pré-requisitos

```bash
# Claude Code CLI
# Instalar em: https://claude.ai/download

# Node.js
brew install node

# gcloud CLI
brew install --cask google-cloud-sdk
gcloud auth login --account alisson@webjump.ai
gcloud config set project solid-choir-461101-t3
gcloud auth application-default login --account alisson@webjump.ai
```

### 2. Clonar e instalar

```bash
git clone git@github.com:alissonaguiar/claude-dotfiles.git ~/GitHub/claude-dotfiles
cd ~/GitHub/claude-dotfiles

# Preencher as API keys
cp .env.example .env
nano .env   # ou code .env

# Instalar
chmod +x install.sh
./install.sh
```

### 3. Instalar plugins

```bash
# Adicionar marketplaces customizados primeiro
claude plugin marketplace add everything-claude-code https://github.com/affaan-m/everything-claude-code
claude plugin marketplace add bmad-method https://github.com/bmad-code-org/bmad-method
claude plugin marketplace add bitwize-music https://github.com/bitwize-music-studio/claude-ai-music-skills

# Instalar os plugins
claude plugin install superpowers@claude-plugins-official
claude plugin install frontend-design@claude-plugins-official
claude plugin install everything-claude-code@everything-claude-code
claude plugin install bmad-method-lifecycle@bmad-method
claude plugin install bitwize-music@bitwize-music
```

### 4. Extensão do Chrome

Instalar a extensão **Playwright MCP Bridge** no Chrome:
- ID: `mmlmfjhmonkocbjadbfplnigmagldckm`
- Chrome Web Store: buscar por "Playwright MCP Bridge"

---

## Variáveis de ambiente necessárias

Ver `.env.example`. Atualmente:

| Variável | Onde obter |
|---|---|
| `STITCH_X_GOOG_API_KEY` | https://stitch.withgoogle.com → Settings → API Keys |
