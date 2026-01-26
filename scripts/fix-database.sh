#!/usr/bin/env bash
set -euo pipefail

# Fix database schema issues
# Repair heuristics table that has NULL values in NOT NULL columns

OPENCODE_DIR="${OPENCODE_DIR:-$HOME/.opencode}"
ELF_INSTALL_DIR="${ELF_BASE_PATH:-$OPENCODE_DIR/emergent-learning}"

# Try both possible database locations
DB_PATH=""
if [ -f "$ELF_INSTALL_DIR/memory/index.db" ]; then
    DB_PATH="$ELF_INSTALL_DIR/memory/index.db"
elif [ -f "$ELF_INSTALL_DIR/.env/.sqlite" ]; then
    DB_PATH="$ELF_INSTALL_DIR/.env/.sqlite"
fi

if [ -z "$DB_PATH" ] || [ ! -f "$DB_PATH" ]; then
    echo "ERROR: Database not found"
    echo "Checked:"
    echo "  - $ELF_INSTALL_DIR/memory/index.db"
    echo "  - $ELF_INSTALL_DIR/.env/.sqlite"
    echo ""
    echo "ELF may not be installed yet. Run:"
    echo "  bash opencode_elf_install.sh"
    exit 1
fi

echo "=========================================="
echo " ELF Database Repair"
echo "=========================================="
echo ""
echo "Database: $DB_PATH"
echo ""

# Backup database
BACKUP_PATH="$DB_PATH.backup.$(date +%s)"
echo "Creating backup: $BACKUP_PATH"
cp "$DB_PATH" "$BACKUP_PATH"
echo "✅ Backup created"
echo ""

# Fix NULL values in heuristics table using Python
echo "Fixing heuristics table..."

python3 << 'PYEOF' || python << 'PYEOF'
import sqlite3
import sys

db_path = """$DB_PATH"""

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Check if heuristics table exists
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='heuristics'")
    table_exists = cursor.fetchone() is not None
    
    if not table_exists:
        print("⚠️  No heuristics table found (database is new)")
        print("   Table will be created when ELF initializes")
        conn.close()
    else:
        # Fix times_validated
        cursor.execute("UPDATE heuristics SET times_validated = 0 WHERE times_validated IS NULL")
        
        # Fix times_violated
        cursor.execute("UPDATE heuristics SET times_violated = 0 WHERE times_violated IS NULL")
        
        # Fix times_contradicted
        cursor.execute("UPDATE heuristics SET times_contradicted = 0 WHERE times_contradicted IS NULL")
        
        # Fix update_count_today
        cursor.execute("UPDATE heuristics SET update_count_today = 0 WHERE update_count_today IS NULL")
        
        # Fix confidence
        cursor.execute("UPDATE heuristics SET confidence = 0.5 WHERE confidence IS NULL")
        
        # Fix confidence_ema
        cursor.execute("UPDATE heuristics SET confidence_ema = 0.5 WHERE confidence_ema IS NULL")
        
        # Fix status
        cursor.execute("UPDATE heuristics SET status = 'active' WHERE status IS NULL")
        
        # Fix is_golden
        cursor.execute("UPDATE heuristics SET is_golden = 0 WHERE is_golden IS NULL")
        
        conn.commit()
        
        # Verify no NULL values remain
        cursor.execute("SELECT COUNT(*) FROM heuristics WHERE times_validated IS NULL OR times_violated IS NULL OR times_contradicted IS NULL OR domain IS NULL OR rule IS NULL")
        invalid_rows = cursor.fetchone()[0]
        
        # Get statistics
        cursor.execute("SELECT COUNT(*) FROM heuristics")
        row_count = cursor.fetchone()[0]
        
        conn.close()
        
        print("✅ Fixed heuristics table")
        print("   - Total rows: %d" % row_count)
        print("   - Invalid rows remaining: %d" % invalid_rows)
    
except Exception as e:
    print("ERROR: Failed to repair database: %s" % str(e))
    sys.exit(1)
PYEOF

echo ""

# Verify database integrity using Python
echo "Verifying database integrity..."

python3 << 'PYEOF' || python << 'PYEOF'
import sqlite3

db_path = """$DB_PATH"""

try:
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    cursor.execute("PRAGMA integrity_check")
    result = cursor.fetchone()
    conn.close()
    
    if result[0] == "ok":
        print("✅ Database integrity check passed")
    else:
        print("⚠️  Integrity check result: %s" % result[0])
        
except Exception as e:
    print("⚠️  Could not verify integrity: %s" % str(e))
PYEOF

echo ""

echo ""
echo "=========================================="
echo "✅ Database repair complete"
echo "=========================================="
echo ""
echo "Backup saved at: $BACKUP_PATH"
echo "If you need to rollback:"
echo "  cp $BACKUP_PATH $DB_PATH"
