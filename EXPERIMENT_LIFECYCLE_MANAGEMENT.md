# Experiment Lifecycle Management System

## Status: ✅ COMPLETE

A complete system for managing the lifecycle of experiments - from creation through completion to archival.

## Components

### 1. **Experiment Manager** (`scripts/lib/experiment_manager.py`)

Python library providing:

**Commands:**
- `list [status]` - List experiments (optionally filtered by status)
- `stats` - Show statistics
- `stale [days]` - Show inactive experiments (default: 30 days)
- `complete <id> <result>` - Mark experiment as completed
- `archive <id>` - Archive an experiment
- `archive-old [days]` - Archive completed experiments older than N days

**Programmatic API:**
```python
from experiment_manager import ExperimentManager

manager = ExperimentManager()

# List active
active = manager.list_active()

# Complete
manager.complete_experiment(3, "success", "All features shipped")

# Archive
manager.archive_experiment(3)

# Get stats
stats = manager.get_stats()

# Get stale
stale = manager.get_stale_experiments(30)
```

### 2. **Experiment Monitor** (`scripts/experiment-monitor.sh`)

Bash script for monitoring experiments:

```bash
# Show current status
./scripts/experiment-monitor.sh status

# Mark stale experiments for review
./scripts/experiment-monitor.sh mark-old

# Archive experiments older than 90 days
./scripts/experiment-monitor.sh archive 90

# Archive experiments older than 60 days
./scripts/experiment-monitor.sh archive 60
```

**Output includes:**
- Status counts by state (active, completed, archived)
- Average cycles per status
- Oldest active experiment
- Stale experiments (inactive >30 days)

## Experiment States

```
CREATED
  ↓
ACTIVE (Running) ←→ ON HOLD
  ↓
COMPLETED (Finished, pending review)
  ↓
ARCHIVED (Old completed experiments)
```

### Status Meanings

| Status | Meaning | Auto-Transition |
|--------|---------|-----------------|
| `active` | Running experiment | No (manual completion) |
| `completed` | Finished, results recorded | Archive after 90 days |
| `archived` | Old completed, moved to history | Final state |
| `pending_review` | Awaiting decision | Manual to active/on-hold/completed |
| `on_hold` | Paused, may resume | Manual to active |

## Workflow

### Creating an Experiment
```bash
./scripts/start-experiment.sh \
  --name "Feature X Launch" \
  --hypothesis "Feature X improves engagement" \
  --success-criteria "10% engagement lift" \
  --failure-criteria "No improvement"
```

This:
1. Creates folder structure
2. Generates hypothesis.md and log.md
3. Records in database with ID
4. Status: `active`

### Running Cycles
Log observations in `log.md`:
```markdown
## Cycle 1
- Try: Implemented feature X
- Break: User testing revealed UX issue
- Analysis: Need to refine interaction model
- Learning: Early user feedback catches design issues
```

Increment cycles:
```bash
python3 scripts/lib/experiment_manager.py list active
# Get ID, then:
python3 scripts/lib/db.py update memory/index.db <ID> cycles_run=1
```

### Completing an Experiment
```bash
python3 scripts/lib/experiment_manager.py complete \
  <ID> \
  "success|failure|inconclusive" \
  "Optional notes and findings"
```

This:
- Sets status to `completed`
- Records completion timestamp
- Stores result and notes
- Experiment ready for archival after 90 days

### Archival
Automatic via monitor:
```bash
./scripts/experiment-monitor.sh archive 90
```

Or manual:
```bash
python3 scripts/lib/experiment_manager.py archive <ID>
```

## Integration with Watcher

The experiment monitor can be called by the main watcher:

```bash
# In watcher cycle
python3 scripts/lib/experiment_manager.py stats

# Check for stale
stale=$(python3 scripts/lib/experiment_manager.py stale 30)
if [ -n "$stale" ]; then
    # Alert: stale experiments detected
fi

# Archive old
python3 scripts/lib/experiment_manager.py archive-old 90
```

## Key Features

✅ **Prevents Indefinite Active State**
- Completed experiments are archived after 90 days
- Stale experiments (30+ days inactive) are flagged
- Monitor tracks age of all active experiments

✅ **Lifecycle Integrity**
- Clear state transitions
- Timestamps for all state changes
- Result recording on completion

✅ **Easy Management**
- Simple CLI for all operations
- Status reporting at a glance
- Bulk operations (archive-old)

✅ **Database-Backed**
- Persistent storage
- Full audit trail
- Query capabilities

## Example: Monitor Dashboard

```bash
$ ./scripts/experiment-monitor.sh status

📊 Statistics:
  Active: 2 experiments (avg 1.5 cycles)
  Completed: 5 experiments (avg 3.2 cycles)
  Archived: 28 experiments

📋 Active Experiments:
  ID   3 | "Feature X Launch" (2 days, 2 cycles)
  ID   5 | "Performance Optimization" (5 days, 0 cycles)

⏱️  Stale Experiments (>30 days):
  (none)
```

## Database Schema

```sql
CREATE TABLE experiments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    hypothesis TEXT,
    status TEXT DEFAULT 'active',
    folder_path TEXT,
    cycles_run INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    completed_at TIMESTAMP,
    notes TEXT,
    result TEXT,
    success_criteria TEXT,
    failure_criteria TEXT
)
```

## Files Created/Modified

1. `scripts/lib/experiment_manager.py` - Created (Python manager)
2. `scripts/experiment-monitor.sh` - Created (Bash monitor)

## Quick Commands

```bash
# Show status
./scripts/experiment-monitor.sh status

# List all active
python3 scripts/lib/experiment_manager.py list active

# List by status
python3 scripts/lib/experiment_manager.py list completed

# Complete an experiment
python3 scripts/lib/experiment_manager.py complete 3 success "Features shipped"

# Archive old completed
./scripts/experiment-monitor.sh archive 90

# Get stats
python3 scripts/lib/experiment_manager.py stats

# Find stale experiments
python3 scripts/lib/experiment_manager.py stale 30
```

## Next Steps

1. Call `experiment-monitor.sh status` regularly to track progress
2. Complete experiments when objectives are met
3. Let automatic archival move old experiments out of active
4. Query completed experiments for learnings and patterns
5. Integrate with watcher for automated monitoring
