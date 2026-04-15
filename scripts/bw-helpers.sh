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
