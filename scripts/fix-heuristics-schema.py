#!/usr/bin/env python3
"""
Fix heuristics table schema to add DEFAULT values for NOT NULL columns.
This prevents "NOT NULL constraint failed" errors in seed_golden_rules.py
"""

import sqlite3
import sys
from pathlib import Path

def fix_schema(db_path: str):
    """Recreate heuristics table with proper defaults."""
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    try:
        # Check if table exists
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='heuristics'")
        if not cursor.fetchone():
            print("heuristics table does not exist yet")
            return 0
        
        # Backup existing data
        cursor.execute("ALTER TABLE heuristics RENAME TO heuristics_old")
        print("✓ Backed up existing heuristics table")
        
        # Create new table with proper schema and defaults
        cursor.execute("""
            CREATE TABLE heuristics (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                domain TEXT NOT NULL,
                rule TEXT NOT NULL,
                explanation TEXT,
                source_type TEXT,
                source_id INTEGER,
                confidence REAL DEFAULT 0.5,
                times_validated INTEGER DEFAULT 0,
                times_violated INTEGER DEFAULT 0,
                is_golden INTEGER DEFAULT 0,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                status TEXT DEFAULT 'active',
                dormant_since TIMESTAMP,
                revival_conditions TEXT,
                times_revived INTEGER DEFAULT 0,
                times_contradicted INTEGER DEFAULT 0,
                min_applications INTEGER DEFAULT 1,
                last_confidence_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                update_count_today INTEGER DEFAULT 0,
                update_count_reset_date DATE DEFAULT CURRENT_DATE,
                last_used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                confidence_ema REAL DEFAULT 0.5,
                ema_alpha REAL DEFAULT 0.2,
                ema_warmup_remaining INTEGER DEFAULT 0,
                last_ema_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                fraud_flags INTEGER DEFAULT 0,
                is_quarantined INTEGER DEFAULT 0,
                last_fraud_check TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                project_path TEXT
            )
        """)
        print("✓ Created new heuristics table with proper defaults")
        
        # Restore data from backup
        cursor.execute("""
            INSERT INTO heuristics 
            SELECT * FROM heuristics_old
        """)
        rows_restored = cursor.rowcount
        print(f"✓ Restored {rows_restored} rows")
        
        # Drop old table
        cursor.execute("DROP TABLE heuristics_old")
        print("✓ Cleaned up backup table")
        
        # Recreate index
        cursor.execute("""
            CREATE INDEX IF NOT EXISTS idx_heuristics_is_golden
            ON heuristics(is_golden)
        """)
        print("✓ Recreated indices")
        
        conn.commit()
        print("\n✅ Schema fixed successfully!")
        return 0
        
    except Exception as e:
        conn.rollback()
        print(f"❌ Error: {e}")
        return 1
    finally:
        conn.close()

if __name__ == '__main__':
    db_path = Path.home() / ".opencode" / "emergent-learning" / "memory" / "index.db"
    
    if not db_path.exists():
        print(f"Database not found at {db_path}")
        sys.exit(1)
    
    sys.exit(fix_schema(str(db_path)))
