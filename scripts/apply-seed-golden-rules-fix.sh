#!/bin/bash
# Fix script for seed_golden_rules.py
# Applies the necessary changes to fix NOT NULL constraint errors

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEED_SCRIPT="$SCRIPT_DIR/seed_golden_rules.py"

if [ ! -f "$SEED_SCRIPT" ]; then
    echo "Error: seed_golden_rules.py not found at $SEED_SCRIPT"
    exit 1
fi

echo "Applying seed_golden_rules.py fixes..."

# Fix 1: Add timezone import
if ! grep -q "from datetime import datetime, timezone" "$SEED_SCRIPT"; then
    sed -i 's/from datetime import datetime$/from datetime import datetime, timezone/g' "$SEED_SCRIPT"
    echo "✓ Added timezone import"
fi

# Fix 2: Replace datetime.utcnow() with datetime.now(timezone.utc)
sed -i 's/datetime\.utcnow()/datetime.now(timezone.utc)/g' "$SEED_SCRIPT"
echo "✓ Replaced datetime.utcnow() with datetime.now(timezone.utc)"

# Fix 3: Add times_validated and times_violated columns
if ! grep -q "times_validated, times_violated" "$SEED_SCRIPT"; then
    # This is more complex, so we do it carefully
    sed -i '/confidence, is_golden, created_at, updated_at/s/is_golden, /times_validated, times_violated, is_golden, /' "$SEED_SCRIPT"
    sed -i '/VALUES.*\?, \?, \?, \?/s/) VALUES/times_validated, times_violated, is_golden, created_at, updated_at\n        ) VALUES/' "$SEED_SCRIPT"
    # Add the values in the tuple - this requires inserting 0,0 after the 1.0
    sed -i '/1\.0,$/a\        0,\n        0,' "$SEED_SCRIPT"
    echo "✓ Added times_validated and times_violated columns"
fi

echo "✓ seed_golden_rules.py fixes applied"
