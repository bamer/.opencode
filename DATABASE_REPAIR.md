# Database Repair Guide

## Problem

The ELF database may have integrity issues where certain columns have `NULL` values despite having `NOT NULL` constraints. This causes errors like:

```
sqlite3.IntegrityError: NOT NULL constraint failed: heuristics.times_validated
```

This typically happens when:
1. The database was modified before proper default values were added
2. Old data exists with NULL in required columns
3. Schema constraints were added after data was inserted

## Solution

### Automatic (During Sync)

The sync script now automatically repairs the database after installation:

```bash
bash opencode_elf_install.sh
```

This runs the fix automatically.

### Manual Repair

If you need to fix the database manually:

```bash
# Easy way
bash repair-database.sh

# Or explicit
OPENCODE_DIR=$HOME/.opencode \
ELF_BASE_PATH=$HOME/.opencode/emergent-learning \
bash scripts/fix-database.sh
```

## What Gets Fixed

The repair script updates NULL values to safe defaults:

| Column | NULL → Default |
|--------|----------------|
| `times_validated` | NULL → 0 |
| `times_violated` | NULL → 0 |
| `times_contradicted` | NULL → 0 |
| `update_count_today` | NULL → 0 |
| `confidence` | NULL → 0.5 |
| `confidence_ema` | NULL → 0.5 |
| `status` | NULL → 'active' |
| `is_golden` | NULL → 0 |

## Safety Features

✅ **Automatic Backup**: Database is backed up before repair
- Located at: `$DB_PATH.backup.<timestamp>`
- Can be restored if needed

✅ **Verification**: Integrity check runs after repair
- Verifies no NULL values remain in NOT NULL columns
- Shows statistics on affected rows

✅ **Non-Destructive**: Only fills NULL values, doesn't delete data
- All existing data is preserved
- Default values are safe and appropriate

## Recovery

If something goes wrong, rollback is simple:

```bash
# Find the backup
ls ~/.opencode/emergent-learning/.env/.sqlite.backup.*

# Restore
cp ~/.opencode/emergent-learning/.env/.sqlite.backup.TIMESTAMP \
   ~/.opencode/emergent-learning/.env/.sqlite
```

## Technical Details

### Database Location

The database can be at either location (depending on ELF version):
```
~/.opencode/emergent-learning/memory/index.db     # Primary location
~/.opencode/emergent-learning/.env/.sqlite        # Alternative location
```

The repair script checks both automatically.

### Affected Table
```sql
CREATE TABLE heuristics (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    domain TEXT NOT NULL,
    rule TEXT NOT NULL,
    confidence REAL DEFAULT 0.5,
    times_validated INTEGER DEFAULT 0,  -- Fixed if NULL
    times_violated INTEGER DEFAULT 0,    -- Fixed if NULL
    times_contradicted INTEGER DEFAULT 0, -- Fixed if NULL
    status TEXT DEFAULT 'active',         -- Fixed if NULL
    ...
);
```

### Repair SQL

```sql
UPDATE heuristics SET times_validated = 0 WHERE times_validated IS NULL;
UPDATE heuristics SET times_violated = 0 WHERE times_violated IS NULL;
UPDATE heuristics SET times_contradicted = 0 WHERE times_contradicted IS NULL;
UPDATE heuristics SET update_count_today = 0 WHERE update_count_today IS NULL;
UPDATE heuristics SET confidence = 0.5 WHERE confidence IS NULL;
UPDATE heuristics SET confidence_ema = 0.5 WHERE confidence_ema IS NULL;
UPDATE heuristics SET status = 'active' WHERE status IS NULL;
UPDATE heuristics SET is_golden = 0 WHERE is_golden IS NULL;
```

## When to Run

The repair runs automatically:
- ✅ During `bash opencode_elf_install.sh`
- ✅ During `bash scripts/opc-elf-sync.sh`

Manual repair needed only if:
- You modify the database directly
- You restore from an old backup
- You encounter integrity errors not fixed by sync

## Testing

After repair, verify with:

```bash
sqlite3 ~/.opencode/emergent-learning/.env/.sqlite \
  "SELECT COUNT(*) FROM heuristics WHERE times_validated IS NULL;"
# Should return: 0
```

## Questions?

- See: `AGENTS.md` → Fix database command
- See: `scripts/fix-database.sh` for full repair logic
