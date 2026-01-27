#!/bin/bash
# Fix script for install.sh
# Disables install_settings() calls since they're superseded by the ELF plugin system

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_SCRIPT="$(cd "$SCRIPT_DIR/.." && pwd)/Emergent-Learning-Framework_ELF/tools/setup/install.sh"

if [ ! -f "$INSTALL_SCRIPT" ]; then
    echo "Error: install.sh not found at $INSTALL_SCRIPT"
    exit 1
fi

echo "Applying install.sh deprecation fixes..."

# Comment out all install_settings calls
# Use a temporary file to handle multi-line replacements properly
TEMP_FILE="$INSTALL_SCRIPT.tmp"
awk '
    /^        install_settings$/ {
        print "        # install_settings is superseded by ELF plugin system (tool.execute.before/after)"
        print "        # install_settings"
        next
    }
    {print}
' "$INSTALL_SCRIPT" > "$TEMP_FILE"

mv "$TEMP_FILE" "$INSTALL_SCRIPT"

if grep -q "# install_settings is superseded" "$INSTALL_SCRIPT"; then
    echo "✓ install_settings() calls have been commented out"
else
    echo "⚠️  Could not verify changes (script may already be patched)"
fi

echo "✓ install.sh deprecation fixes applied"
