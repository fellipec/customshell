#!/usr/bin/env bash
set -euo pipefail

API_URL="https://api.github.com/repos/restic/restic/releases/latest"

echo "🔍 Obtendo última versão do Restic..."
JSON=$(curl -s "$API_URL")

BIN_URL=$(echo "$JSON" \
  | jq -r '.assets[] | select(.name | test("restic_.*_linux_amd64.bz2$")) | .browser_download_url')

SUM_URL=$(echo "$JSON" \
  | jq -r '.assets[] | select(.name == "SHA256SUMS") | .browser_download_url')

if [[ -z "$BIN_URL" || -z "$SUM_URL" ]]; then
  echo "Erro: não foi possível localizar binário ou checksums"
  exit 1
fi

# Extrai o nome real do arquivo a partir da URL
BIN_FILE=$(basename "$BIN_URL")

echo "⬇️ Baixando binário: $BIN_FILE"
curl -L -o "$BIN_FILE" "$BIN_URL"

echo "⬇️ Baixando checksums..."
curl -L -o SHA256SUMS "$SUM_URL"

echo "🔐 Validando checksum..."
grep "$BIN_FILE" SHA256SUMS > SHA256SUMS_filtered

sha256sum -c SHA256SUMS_filtered

echo "📦 Descompactando..."
bunzip2 -f "$BIN_FILE"

# Nome do binário após descompactar (remove .bz2)
RESTIC_BIN="${BIN_FILE%.bz2}"

echo "🔧 Tornando executável..."
chmod +x "$RESTIC_BIN"

sudo mv "$RESTIC_BIN" /usr/local/bin/restic
echo "✔️ Instalação concluída!"
echo "Versão instalada:"
restic version
