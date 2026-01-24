#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ELF_REPO="$ROOT_DIR/Emergent-Learning-Framework_ELF"
OPENCODE_DIR="${OPENCODE_DIR:-$HOME/.opencode}"
ELF_DIR="${ELF_BASE_PATH:-$OPENCODE_DIR/emergent-learning}"
PLUGIN_DIR="$OPENCODE_DIR/plugin"
SCRIPT_DIR="$OPENCODE_DIR/scripts"
PLUGIN_SRC="$ROOT_DIR/ELF_superpowers_plug.js"
BACKUP_DATE="$(date +%Y-%m-%d_%H-%M-%S)"
BACKUP_DIR="$ROOT_DIR/backups/$BACKUP_DATE"

echo "== OPC-ELF install =="

mkdir -p "$PLUGIN_DIR" "$SCRIPT_DIR"

if [ ! -d "$ELF_REPO" ]; then
  echo "ERROR: ELF repo not found at $ELF_REPO"
  exit 1
fi

if [ ! -f "$PLUGIN_SRC" ]; then
  echo "ERROR: Plugin not found at $PLUGIN_SRC"
  exit 1
fi

echo "-- Normalizing .claude → .opencode"
(
  cd "$ELF_REPO"
  if [ -d ".claude" ]; then
    mv ".claude" ".opencode"
  fi
  grep -RIl "\.claude" . | while read -r file; do
    sed -i 's/\.claude/.opencode/g' "$file"
  done
)

echo "-- Backing up databases"
mkdir -p "$BACKUP_DIR"
if [ -d "$ELF_DIR" ]; then
  find "$ELF_DIR" -type f \( -name "*.sqlite3" -o -name "*.db" \) | while read -r db; do
    rel_path="${db#$HOME/}"
    backup_target="$BACKUP_DIR/$rel_path"
    mkdir -p "$(dirname "$backup_target")"
    cp "$db" "$backup_target"
  done
fi

echo "-- Running upstream installer (OpenCode paths)"
(
  cd "$ELF_REPO"
  chmod +x ./install.sh
  OPENCODE_DIR="$OPENCODE_DIR" ELF_BASE_PATH="$ELF_DIR" ./install.sh --mode merge
)

echo "-- Installing OpenCode plugin"
cp -f "$PLUGIN_SRC" "$PLUGIN_DIR/ELF_superpowers_plug.js"

echo "-- Syncing CLAUDE.md → AGENTS.md"
if [ -f "$OPENCODE_DIR/CLAUDE.md" ]; then
  cp -f "$OPENCODE_DIR/CLAUDE.md" "$OPENCODE_DIR/AGENTS.md"
fi

echo "-- Validating install"
if [ ! -d "$ELF_DIR" ]; then
  echo "ERROR: ELF install dir not found at $ELF_DIR"
  exit 1
fi
if [ ! -f "$PLUGIN_DIR/ELF_superpowers_plug.js" ]; then
  echo "ERROR: OpenCode plugin missing"
  exit 1
fi

echo "✅ OPC-ELF install complete"
echo "Backup stored in: $BACKUP_DIR"
