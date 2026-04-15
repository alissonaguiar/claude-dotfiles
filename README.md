# claude-dotfiles

Backup portável da configuração do Claude Code, com secrets gerenciados via Bitwarden.

## O que está aqui

| Arquivo/Dir | Descrição |
|---|---|
| `settings.json` | Plugins habilitados, hooks, modelo padrão |
| `secrets.json` | Mapa de env vars → itens do Bitwarden (sem valores) |
| `claude.json.example` | MCP servers com placeholders de vars |
| `skills/` | Skills customizadas (ui-ux-pro-max, air-brand-guidelines) |
| `projects/` | Memórias por projeto (apenas `.md`, sem dados sensíveis) |
| `scripts/bw-helpers.sh` | Funções auxiliares do Bitwarden CLI |
| `install.sh` | Script de restauração numa máquina nova |
| `sync.sh` | Script para atualizar o backup + Bitwarden |

> **Arquivos pessoais** (`history.jsonl`, `settings.local.json`, memórias completas) ficam apenas no repositório privado `claude-dotfiles-private`.

---

## Sincronizar (atualizar backup + Bitwarden)

Rodar sempre que mudar configuração, instalar plugin, acumular memórias, ou alterar um secret:

```bash
export BW_SESSION=$(bw unlock --raw)

# Roda o sync (atualiza ambos os repos localmente + Bitwarden)
cd ~/GitHub/claude-dotfiles && ./sync.sh

# Commit e push do repo público (sem dados pessoais)
git add -A && git commit -m "sync: $(date +%Y-%m-%d)" && git push

# Commit e push do repo privado (backup completo)
cd ~/GitHub/claude-dotfiles-private && git add -A && git commit -m "sync: $(date +%Y-%m-%d)" && git push
```

---

## Restaurar em máquina nova

### 1. Pré-requisitos

```bash
# Claude Code CLI
# Instalar em: https://claude.ai/download

# Node.js + Bitwarden CLI
brew install node bitwarden-cli

# gcloud CLI
brew install --cask google-cloud-sdk
gcloud auth login
gcloud config set project YOUR_GCP_PROJECT_ID
gcloud auth application-default login
```

### 2. Clonar e autenticar no Bitwarden

```bash
git clone git@github.com:YOUR_USER/claude-dotfiles.git ~/GitHub/claude-dotfiles
cd ~/GitHub/claude-dotfiles

bw login
export BW_SESSION=$(bw unlock --raw)
```

### 3. Instalar (secrets buscados automaticamente do Bitwarden)

```bash
./install.sh
```

### 4. Instalar plugins

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

### 5. Extensão do Chrome

Instalar **Playwright MCP Bridge** no Chrome: ID `mmlmfjhmonkocbjadbfplnigmagldckm`

---

## Adicionar novo secret

1. Adicionar entrada em `secrets.json`
2. Adicionar `KEY=valor` no `.env` local
3. Rodar sync — cria item no Bitwarden e commita o mapa

```bash
export BW_SESSION=$(bw unlock --raw)
cd ~/GitHub/claude-dotfiles && ./sync.sh && git add -A && git commit -m "feat: add <secret-name>" && git push
```

---

## Dependências externas

- **Claude Code CLI**: https://claude.ai/download
- **Node.js 18+**: `brew install node`
- **Bitwarden CLI**: `brew install bitwarden-cli`
- **gcloud CLI**: https://cloud.google.com/sdk/docs/install
- **Playwright MCP Bridge** (Chrome): ID `mmlmfjhmonkocbjadbfplnigmagldckm`
