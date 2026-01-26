# Database Fix - Implementation Summary

## Problem

The sync was failing with:
```
sqlite3.IntegrityError: NOT NULL constraint failed: heuristics.times_validated
```

This happened because the database had NULL values in columns that now have NOT NULL constraints.

## Solution Implemented

Created a **complete automatic database repair system** that:

1. ✅ Finds the database (checks multiple locations)
2. ✅ Creates a backup before any changes
3. ✅ Repairs NULL values with safe defaults
4. ✅ Verifies integrity after repair
5. ✅ Runs automatically during sync

## Files Created

### 1. `scripts/fix-database.sh`
Core repair script that:
- Locates the database automatically
- Creates timestamped backup
- Fixes all NULL values in NOT NULL columns
- Runs integrity checks
- Shows repair statistics

### 2. `repair-database.sh`
Convenience wrapper for easy access:
```bash
bash repair-database.sh
```

### 3. `find-database.sh`
Diagnostic tool to locate the database:
```bash
bash find-database.sh
```

### 4. `DATABASE_REPAIR.md`
Complete technical documentation

## Database Locations Handled

The system automatically checks both locations:
- `~/.opencode/emergent-learning/memory/index.db` (Primary)
- `~/.opencode/emergent-learning/.env/.sqlite` (Alternative)

## Integration with Sync

The repair runs automatically after ELF installation:

```bash
-- Running ELF installer
...
-- Checking database integrity
   Repairing database schema if needed...
   ✅ Fixed heuristics table
```

## Fixed Columns

All NULL values are replaced with safe defaults:

| Column | Type | NULL → Default |
|--------|------|----------------|
| times_validated | INTEGER | 0 |
| times_violated | INTEGER | 0 |
| times_contradicted | INTEGER | 0 |
| update_count_today | INTEGER | 0 |
| confidence | REAL | 0.5 |
| confidence_ema | REAL | 0.5 |
| status | TEXT | 'active' |
| is_golden | INTEGER | 0 |

## Usage

### Automatic (Recommended)
```bash
bash opencode_elf_install.sh
```

Handles everything automatically, including database repair.

### Manual

**Find where database is:**
```bash
bash find-database.sh
```

**Repair database:**
```bash
bash repair-database.sh
```

**Or with explicit paths:**
```bash
OPENCODE_DIR=$HOME/.opencode \
ELF_BASE_PATH=$HOME/.opencode/emergent-learning \
bash scripts/fix-database.sh
```

## Safety Features

✅ **Backup on Repair**
- Automatic backup before any changes
- Located at: `$DB.backup.<timestamp>`
- Can be restored if needed

✅ **Integrity Verification**
- PRAGMA integrity_check runs after repair
- Confirms no NULL values remain
- Shows affected row counts

✅ **Non-Destructive**
- Only fills NULL values
- No data deletion
- Safe defaults applied

## Recovery

If needed, rollback is simple:

```bash
# Find the backup
ls ~/.opencode/emergent-learning/memory/index.db.backup.*

# Restore
cp ~/.opencode/emergent-learning/memory/index.db.backup.TIMESTAMP \
   ~/.opencode/emergent-learning/memory/index.db
```

## Testing

After repair, verify with:

```bash
sqlite3 ~/.opencode/emergent-learning/memory/index.db \
  "SELECT COUNT(*) FROM heuristics WHERE times_validated IS NULL;"
# Should return: 0
```

## Integration Points

### In opc-elf-sync.sh
```bash
# Fix database schema if needed
echo "-- Checking database integrity"
if [ -f "$ELF_INSTALL_DIR/memory/index.db" ] || [ -f "$ELF_INSTALL_DIR/.env/.sqlite" ]; then
  echo "   Repairing database schema if needed..."
  bash "$ROOT_DIR/scripts/fix-database.sh"
fi
```

### In AGENTS.md
Added command documentation:
```
- **Fix database** (if integrity issues): 
  OPENCODE_DIR=$HOME/.opencode ELF_BASE_PATH=$HOME/.opencode/emergent-learning bash ./scripts/fix-database.sh
  - Repairs NULL values in NOT NULL columns, backs up database
```

## What's Fixed

Before:
```
❌ sqlite3.IntegrityError: NOT NULL constraint failed: heuristics.times_validated
```

After:
```
✅ OPC-ELF SYNC COMPLETED SUCCESSFULLY
✅ No Claude references found in active code
✅ Plugin installed at: ~/.opencode/plugin/ELF_superpowers_plug.js
```

## Documentation Updated

- ✅ `DATABASE_REPAIR.md` - Complete guide
- ✅ `AGENTS.md` - Added fix-database command
- ✅ `scripts/fix-database.sh` - Implementation with comments
- ✅ Error messages - Clear guidance when DB not found

## Status

**✅ COMPLETE AND TESTED**

The database repair system is:
- Automatic during sync
- Manual repair available on-demand
- Safe with automatic backups
- Well documented
- Production ready
