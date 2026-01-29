# Experiment Analysis System

## Architecture

### Current System

The experiment system consists of **three layers**:

#### 1. **Creation & Tracking** (`scripts/start-experiment.sh`)
- Creates experiment folder structure
- Generates hypothesis.md and log.md templates
- Records in SQLite database
- Status: `active`

#### 2. **Lifecycle Management** (`scripts/lib/experiment_manager.py` + `scripts/experiment-monitor.sh`)
- Tracks active/completed/archived states
- Detects stale experiments (30+ days inactive)
- Auto-archives completed experiments after 90 days
- Prevents indefinite active state

#### 3. **AI Analysis** (`agents/experiment_analyzer.py`)
- **Uses**: opencode/big-pickle model
- Analyzes each active experiment
- Recommends completion when objectives are met
- Detects patterns and generates insights
- Provides structured analysis

## Who Analyzes Experiments?

### **The AI**: `experiment_analyzer.py`

Uses **opencode/big-pickle** to:

1. **Assess Progress**
   - Is experiment on track?
   - Are cycles progressing?
   - Any concerning patterns?

2. **Determine Readiness for Completion**
   - Have success criteria been met?
   - Is there sufficient evidence?
   - Should result be: success/failure/inconclusive?

3. **Extract Learnings**
   - What patterns emerged?
   - What heuristics can we derive?
   - How can we optimize next time?

4. **Generate Recommendations**
   - Should we complete now?
   - Are there optimizations?
   - Any risks to address?

## How It Works

### Step 1: Create Experiment
```bash
./scripts/start-experiment.sh \
  --name "Feature X" \
  --hypothesis "Feature X improves engagement" \
  --success-criteria "10% lift"
```

Status: `active` | ID: 3

### Step 2: Run Cycles
Update `experiments/active/xxx/log.md` with observations:
```markdown
## Cycle 1
- Try: Implemented feature
- Break: User feedback showed issue
- Analysis: Need UX refinement
- Learning: Early feedback essential
```

### Step 3: Analyze
The AI (`experiment_analyzer.py`) runs periodically and:

```bash
python3 agents/experiment_analyzer.py analyze 3
```

**Output:**
```json
{
  "assessment": "on_track",
  "completion_ready": false,
  "confidence": 0.75,
  "key_findings": [
    "Hypothesis is being validated",
    "Need 1-2 more cycles"
  ],
  "recommendations": [
    "Continue with refined UX",
    "Add performance metrics"
  ]
}
```

### Step 4: Complete
When AI recommends completion:

```bash
python3 scripts/lib/experiment_manager.py complete 3 "success" "Features shipped successfully"
```

Status: `completed`

### Step 5: Archive
After 90 days:

```bash
./scripts/experiment-monitor.sh archive 90
```

Status: `archived`

## Integration Points

### With Watcher (`src/watcher/launcher.py`)
```python
# In watcher cycle
import subprocess

# Analyze active experiments
result = subprocess.run([
    "python3",
    "agents/experiment_analyzer.py",
    "all"
], capture_output=True, text=True)

analyses = json.loads(result.stdout)

# Check for experiments ready to complete
for analysis in analyses["analyses"]:
    if analysis.get("completion_ready"):
        # Alert or auto-complete
        pass
```

### With Dashboard
```bash
# Generate report for dashboard
python3 agents/experiment_analyzer.py report > /tmp/experiment_report.md
```

### With Heuristic Manager
```python
# Extract learnings to heuristic system
for learning in analysis["learnings"]:
    heuristic_manager.add_heuristic(
        domain="experiments",
        rule=learning,
        confidence=analysis["confidence"]
    )
```

## Commands

### Create
```bash
./scripts/start-experiment.sh --name "..." --hypothesis "..."
```

### Monitor
```bash
./scripts/experiment-monitor.sh status
```

### Analyze
```bash
# Analyze one
python3 agents/experiment_analyzer.py analyze 3

# Analyze all active
python3 agents/experiment_analyzer.py all

# Generate report
python3 agents/experiment_analyzer.py report
```

### Complete
```bash
python3 scripts/lib/experiment_manager.py complete 3 "success" "Notes"
```

### Archive
```bash
./scripts/experiment-monitor.sh archive 90
```

## State Diagram

```
CREATE
   ↓
ACTIVE ← ← ← ← ← ← ← ← ← ← ← ← ← 
   ↓                              ↑
   ├─ (AI analyzes periodically) │
   ├─ (runs cycles, updates log) │
   └─ (when ready) → COMPLETED   │
                      ↓           │
                   ARCHIVED (after 90 days)
```

## AI Decision Framework

The analyzer makes decisions based on:

**Completion Triggers**
- ✅ Success criteria explicitly met
- ✅ All planned cycles completed
- ✅ Clear learning extracted
- ❌ Failure criteria reached
- ⚠️  Inconclusive (needs more data)

**Risk Detection**
- 🚨 Stale (>30 days, 0 cycles)
- ⚠️  Slow progress (expected 5+ cycles, only 1)
- ❌ Contradictions with hypothesis
- 📊 Insufficient data for conclusion

**Optimization Suggestions**
- Refinement of methodology
- Additional metrics needed
- Timeline adjustments
- Resource allocation changes

## Files

- `scripts/start-experiment.sh` - Create experiments
- `scripts/lib/experiment_manager.py` - Lifecycle management
- `scripts/lib/db.py` - Database operations
- `scripts/experiment-monitor.sh` - Status monitoring
- `agents/experiment_analyzer.py` - **AI ANALYSIS** ← HERE
- `memory/index.db` - SQLite database

## Next: Full Automation

To fully automate:

1. **Scheduled Analysis**
   ```bash
   # In crontab: every 6 hours
   0 */6 * * * python3 /path/to/experiment_analyzer.py all
   ```

2. **Auto-completion**
   ```python
   # In experiment_analyzer.py
   if analysis["completion_ready"] and analysis["confidence"] > 0.8:
       experiment_manager.complete_experiment(exp_id, result)
   ```

3. **Notification Pipeline**
   ```python
   # Alert watcher/CEO when ready
   if experiment_ready:
       send_alert(f"Experiment {exp_id} ready to complete")
   ```

4. **Learning Extraction**
   ```python
   # Feed learnings back to heuristic system
   for learning in analysis["learnings"]:
       heuristic_manager.add_heuristic(learning)
   ```

## Summary

**Who analyzes?** → `experiment_analyzer.py` using `opencode/big-pickle`

**When?** → On-demand or scheduled (via watcher)

**How?** → AI reads hypothesis/criteria, evaluates against progress, recommends completion

**Result?** → Structured analysis with completion recommendations
