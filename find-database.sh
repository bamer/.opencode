#!/usr/bin/env bash
# Find where the ELF database is located

OPENCODE_DIR="${OPENCODE_DIR:-$HOME/.opencode}"
ELF_INSTALL_DIR="${ELF_BASE_PATH:-$OPENCODE_DIR/emergent-learning}"

echo "Searching for ELF database..."
echo ""

found=false

# Check primary location
if [ -f "$ELF_INSTALL_DIR/memory/index.db" ]; then
    echo "✅ Found: $ELF_INSTALL_DIR/memory/index.db"
    ls -lh "$ELF_INSTALL_DIR/memory/index.db"
    found=true
fi

# Check alternative location
if [ -f "$ELF_INSTALL_DIR/.env/.sqlite" ]; then
    echo "✅ Found: $ELF_INSTALL_DIR/.env/.sqlite"
    ls -lh "$ELF_INSTALL_DIR/.env/.sqlite"
    found=true
fi

if [ "$found" = false ]; then
    echo "❌ Database not found"
    echo ""
    echo "Checked:"
    echo "  - $ELF_INSTALL_DIR/memory/index.db"
    echo "  - $ELF_INSTALL_DIR/.env/.sqlite"
    echo ""
    echo "Next steps:"
    echo "  1. Run: bash opencode_elf_install.sh"
    echo "  2. Then: bash repair-database.sh"
else
    echo ""
    echo "You can now run:"
    echo "  bash repair-database.sh"
fi
