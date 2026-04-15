# Design: Bitwarden Secrets Management para claude-dotfiles

**Data:** 2026-04-15  
**Status:** Aprovado  

---

## Problema

O `claude-dotfiles` atualmente armazena secrets (API keys de MCP servers) apenas como template em `.env.example`, exigindo preenchimento manual na nova máquina. Isso torna a migração entre máquinas incompleta e sujeita a erro.

## Objetivo

Armazenar secrets de forma segura no Bitwarden, com cada secret como um item individual e legível, permitindo:
- Migração automática entre máquinas (3 comandos)
- Gerenciamento individual de cada chave pelo Bitwarden web
- Extensível para qualquer ferramenta que o Claude Code utilize

---

## Arquitetura

### Componentes

| Componente | Responsabilidade |
|---|---|
| `secrets.json` | Mapa de env vars → itens do Bitwarden (commitado no repo, sem valores) |
| `.env` | Arquivo local gerado em runtime pelo `install.sh` (nunca commitado) |
| Bitwarden vault | Armazenamento seguro E2E encrypted dos valores reais |
| `install.sh` | Lê `secrets.json`, busca cada item no Bitwarden, gera `.env` |
| `sync.sh` | Lê `.env` local, atualiza/cria itens no Bitwarden, commita repo |

### Fluxo de dados

```
secrets.json (mapa)
      +
Bitwarden vault (valores)
      ↓
  install.sh
      ↓
   .env (local, nunca commitado)
      ↓
  claude.json (vars substituídas)
```

---

## secrets.json — Formato

Arquivo commitado no repo. Define o mapeamento entre env vars e itens do Bitwarden.

```json
{
  "STITCH_X_GOOG_API_KEY": {
    "item": "Stitch MCP - API Key",
    "field": "password",
    "notes": "Obter em stitch.withgoogle.com → Settings → API Keys"
  }
}
```

Campos:
- `item`: nome exato do item no Bitwarden (legível, sem abreviações)
- `field`: campo do item a usar — sempre `"password"`
- `notes`: opcional, documenta onde obter/renovar a chave

---

## Organização no Bitwarden

**Pasta:** `claude-dotfiles`  
Todos os itens ficam nessa pasta, isolados de senhas pessoais.

**Tipo de item:** Login  
**Convenção de nome:** `<Ferramenta> - <O que é>`

| Campo do item | Conteúdo |
|---|---|
| Nome | `Stitch MCP - API Key` |
| Username | `STITCH_X_GOOG_API_KEY` (referência rápida) |
| Password | valor real da chave |
| Pasta | `claude-dotfiles` |
| Notes | onde obter/renovar |

---

## install.sh — Fluxo detalhado

```
1. Verifica pré-requisitos: bw instalado, bw status = unlocked
   - Se não autenticado: instrui o usuário a rodar bw login && bw unlock
2. Lê secrets.json
3. Para cada entrada em secrets.json:
   a. bw get password "<item name>"
   b. Se encontrado: escreve KEY=value no .env
   c. Se não encontrado: avisa "[warn] item não encontrado: <name>" e continua
4. Gera .env com todas as vars encontradas
5. Continua com o resto do install:
   - Copia settings.json, settings.local.json, history.jsonl
   - Copia skills/
   - Copia projects/memory/
   - Aplica claude.json com substituição de vars do .env
```

Secrets ausentes não bloqueiam o install — permitem instalar o que existe e resolver o restante depois.

---

## sync.sh — Fluxo detalhado

```
1. Verifica pré-requisitos: bw instalado e unlocked
2. Garante que a pasta claude-dotfiles existe no vault
   - bw list folders → busca por "claude-dotfiles"
   - Se não existe: bw create folder "claude-dotfiles"
3. Lê .env local
4. Para cada KEY em secrets.json:
   a. Busca o item no Bitwarden: bw list items --search "<item name>"
   b. Se existe: bw edit item <id> com novo valor
   c. Se não existe: bw create item (Login, pasta claude-dotfiles, username=KEY, password=valor)
5. bw sync (força sync com servidor)
6. Continua com sync normal:
   - Copia configs e skills atuais para o repo
   - git add -A && git commit && git push
```

### Adicionar novo secret

```
1. Adicionar entrada em secrets.json
2. Adicionar KEY=valor no .env local
3. ./sync.sh  → cria item no Bitwarden + commita repo
```

---

## Fluxo completo — Máquina nova

```bash
# Pré-requisitos
brew install node bitwarden-cli
gcloud auth login --account alisson@webjump.ai

# Clonar e configurar
git clone git@github.com:alissonaguiar/claude-dotfiles.git ~/GitHub/claude-dotfiles
cd ~/GitHub/claude-dotfiles

# Autenticar no Bitwarden (uma vez)
bw login
bw unlock   # gera BW_SESSION — exportar conforme instrução

# Instalar tudo
./install.sh
```

Total: ~7 comandos, sendo 2 manuais de interação (login/unlock do Bitwarden) e o resto executável em sequência.

---

## .gitignore

```
.env
*.bak
projects/**/*.jsonl
projects/**/*.meta.json
```

`.env` nunca é commitado. `secrets.json` (apenas o mapa) é commitado normalmente.

---

## Extensibilidade

Para adicionar qualquer novo secret de MCP server ou ferramenta:
1. Adicionar entrada em `secrets.json`
2. Referenciar a var em `claude.json.example` como `${VAR_NAME}`
3. `./sync.sh` cria o item no Bitwarden e commita

Não há limite de ferramentas — o design escala linearmente.
