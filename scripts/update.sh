#!/usr/bin/env bash
set -euo pipefail

# =========================
# CONFIG
# =========================
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ELF_REPO="$ROOT_DIR/Emergent-Learning-Framework_ELF"
PLUGIN_SRC="$ROOT_DIR/ELF_superpowers_plug.js"

OPENCODE_DIR="${OPENCODE_DIR:-$HOME/.opencode}"
OPENCODE_PLUGIN_DIR="$OPENCODE_DIR/plugin"
ELF_INSTALL_DIR="${ELF_BASE_PATH:-$OPENCODE_DIR/emergent-learning}"

BACKUP_DATE="$(date +%Y-%m-%d_%H-%M-%S)"
BACKUP_DIR="$ROOT_DIR/backups/$BACKUP_DATE"

echo "========================================"
echo " OPC-ELF UPDATE START"
echo "========================================"

# =========================
# 1. UPDATE ELF REPO
# =========================
echo "-- Updating ELF repository"
cd "$ELF_REPO"

git pull || true

# =========================
# 2. NORMALIZE .claude → .opencode
# =========================
echo "-- Normalizing .claude → .opencode"

if [ -d ".claude" ]; then
  echo "   Renaming .claude directory"
  mv ".claude" ".opencode"
fi

echo "   Rewriting .claude references in files"
grep -RIl "\.claude" . | while read -r file; do
  sed -i 's/\.claude/.opencode/g' "$file"
done

# =========================
# 3. INSTALL OPENCODE PLUGIN
# =========================
echo "-- Installing OpenCode plugin"

if [ ! -f "$PLUGIN_SRC" ]; then
  echo "ERROR: ELF_superpowers_plug.js not found at repo root"
  exit 1
fi

mkdir -p "$OPENCODE_PLUGIN_DIR"
cp -f "$PLUGIN_SRC" "$OPENCODE_PLUGIN_DIR/ELF_superpowers_plug.js"

# =========================
# 4. BACKUP DATABASES (.sqlite3 + .db)
# =========================
echo "-- Backing up databases (keeping full paths)"

mkdir -p "$BACKUP_DIR"

if [ -d "$ELF_INSTALL_DIR" ]; then
  find "$ELF_INSTALL_DIR" -type f \( -name "*.sqlite3" -o -name "*.db" \) | while read -r db; do
    # chemin relatif depuis $HOME
    rel_path="${db#$HOME/}"
    backup_target="$BACKUP_DIR/$rel_path"

    echo "   Backup $rel_path"

    mkdir -p "$(dirname "$backup_target")"
    cp "$db" "$backup_target"
  done
else
  echo "   No existing ELF installation found, skipping DB backup"
fi

# =========================
# 5. RUN ELF INSTALLER
# =========================
echo "-- Running ELF install.sh"

cd "$ELF_REPO"
if [ ! -x "./install.sh" ]; then
  chmod +x ./install.sh
fi

OPENCODE_DIR="$OPENCODE_DIR" ELF_BASE_PATH="$ELF_INSTALL_DIR" ./install.sh

# =========================
# 6. BASIC VALIDATION
# =========================
echo "-- Validating OpenCode ELF installation"

if [ ! -d "$ELF_INSTALL_DIR" ]; then
  echo "ERROR: $ELF_INSTALL_DIR not found after install"
  exit 1
fi

if [ ! -f "$OPENCODE_PLUGIN_DIR/ELF_superpowers_plug.js" ]; then
  echo "ERROR: OpenCode plugin not installed"
  exit 1
fi

echo "========================================"
echo " OPC-ELF UPDATE COMPLETED SUCCESSFULLY"
echo " Backup stored in:"
echo "   $BACKUP_DIR"
echo "========================================"
