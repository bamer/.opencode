#!/bin/bash
#
# Test script for OpenCode Watcher integration
#

set -euo pipefail

OPENCODE_DIR="${OPENCODE_DIR:=$HOME/.opencode}"
ELF_DIR="$OPENCODE_DIR/emergent-learning"

echo "======================================"
echo "Testing OpenCode Watcher Integration"
echo "======================================"
echo ""

# Check opencode CLI
echo "1. Checking opencode CLI..."
if command -v opencode &> /dev/null; then
    echo "✓ opencode CLI found"
    opencode --version 2>/dev/null || echo "  (version check skipped)"
else
    echo "✗ opencode CLI NOT found"
    echo "  Install with: npm install -g opencode"
    exit 1
fi
echo ""

# Check Python
echo "2. Checking Python..."
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
    echo "✓ python3 found"
else
    echo "✗ python3 NOT found"
    exit 1
fi
echo ""

# Check ELF directory
echo "3. Checking ELF directory..."
if [ -d "$ELF_DIR" ]; then
    echo "✓ ELF directory found: $ELF_DIR"
else
    echo "✗ ELF directory NOT found at $ELF_DIR"
    exit 1
fi
echo ""

# Test watcher prompt generation
echo "4. Testing watcher prompt generation..."
cd "$ELF_DIR"
if $PYTHON_CMD -c "import sys; sys.path.insert(0, '.'); from watcher.watcher_loop import output_watcher_prompt; output_watcher_prompt()" > /tmp/watcher-prompt.txt 2>&1; then
    LINES=$(wc -l < /tmp/watcher-prompt.txt)
    echo "✓ Watcher prompt generated ($LINES lines)"
else
    echo "✗ Failed to generate watcher prompt"
    cat /tmp/watcher-prompt.txt
    exit 1
fi
echo ""

# Test launcher
echo "5. Testing launcher script..."
if [ -f "$ELF_DIR/src/watcher/launcher.py" ]; then
    echo "✓ launcher.py found"
else
    echo "✗ launcher.py NOT found at $ELF_DIR/src/watcher/launcher.py"
    exit 1
fi
echo ""

# Test start-watcher.sh
echo "6. Testing start-watcher.sh..."
if [ -f "$ELF_DIR/src/watcher/start-watcher.sh" ]; then
    echo "✓ start-watcher.sh found"
    if [ -x "$ELF_DIR/src/watcher/start-watcher.sh" ]; then
        echo "✓ start-watcher.sh is executable"
    else
        chmod +x "$ELF_DIR/src/watcher/start-watcher.sh"
        echo "✓ Made start-watcher.sh executable"
    fi
else
    echo "✗ start-watcher.sh NOT found at $ELF_DIR/src/watcher/start-watcher.sh"
    exit 1
fi
echo ""

# Test elf_paths module
echo "7. Testing elf_paths module..."
if $PYTHON_CMD -c "import sys; sys.path.insert(0, '.'); from elf_paths import get_base_path; print('Base path:', get_base_path())" 2>&1; then
    echo "✓ elf_paths module works"
else
    echo "✗ elf_paths module failed"
    exit 1
fi
echo ""

echo "======================================"
echo "All tests passed!"
echo "======================================"
echo ""
echo "To start the watcher:"
echo "  cd $ELF_DIR"
echo "  ./src/watcher/start-watcher.sh"
echo ""
echo "Or in daemon mode:"
echo "  ./src/watcher/start-watcher.sh --daemon"
echo ""
