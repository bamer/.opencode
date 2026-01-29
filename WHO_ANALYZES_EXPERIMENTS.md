# Who Analyzes Experiments?

## Answer: **experiment_analyzer.py** using **opencode/big-pickle**

## The AI Agent

```
┌─────────────────────────────────────────────────────────────┐
│  agents/experiment_analyzer.py                              │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ │
│                                                              │
│  Model: opencode/big-pickle (free, local)                  │
│  Role: Intelligent experiment lifecycle management         │
│  Responsibility: Prevent indefinite active state           │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## What It Does

### **Analyzes Each Experiment For:**

1. **Progress Assessment**
   - Is the hypothesis being validated?
   - Are cycles progressing as expected?
   - Any concerning patterns?

2. **Completion Readiness** ← KEY FUNCTION
   - Have success criteria been met?
   - Is there sufficient evidence?
   - Should this experiment conclude?

3. **Learning Extraction**
   - What insights can we derive?
   - What heuristics should we remember?
   - How can we improve next time?

4. **Risk Detection**
   - Stale experiments (>30 days inactive)
   - Contradictions with hypothesis
   - Insufficient data for decision

## How to Use It

### Analyze One Experiment
```bash
python3 agents/experiment_analyzer.py analyze 3
```

**Output:**
```json
{
  "assessment": "on_track",
  "completion_ready": false,
  "recommended_result": "success",
  "confidence": 0.85,
  "key_findings": [
    "Hypothesis validated in 80% of cases",
    "Need 1 more cycle for statistical significance"
  ],
  "learnings": [
    "Early user feedback prevents 40% of issues",
    "Iterative refinement crucial for feature adoption"
  ]
}
```

### Analyze All Active
```bash
python3 agents/experiment_analyzer.py all
```

### Generate Report
```bash
python3 agents/experiment_analyzer.py report
```

**Output:**
```
═════════════════════════════════════════════
        EXPERIMENT ANALYSIS REPORT
═════════════════════════════════════════════

📊 OVERVIEW
  Total Active: 5
  • On Track: 3
  • At Risk: 1
  • Ready to Complete: 1

🎯 KEY RECOMMENDATIONS
  • Continue current approach (3 experiments)
  • Address UX issue in experiment #2
  • Complete experiment #1 with "success"

📋 DETAILED ANALYSES
...
```

## Integration with Watcher

The analyzer can be called by the watcher periodically:

```bash
# Every 6 hours
0 */6 * * * python3 /path/to/experiment_analyzer.py all | \
  python3 /path/to/process_recommendations.py
```

## Full System Workflow

```
User Creates Experiment
         ↓
    (active)
         ↓
  Runs Cycles, Logs Observations
         ↓
┌────────────────────────────────────────┐
│  AI Analyzer (opencode/big-pickle)     │
│  ────────────────────────────────────  │
│  Reads:                                │
│    • Hypothesis & criteria             │
│    • Progress (cycles, logs)           │
│    • Time running                      │
│  ────────────────────────────────────  │
│  Analyzes & Decides:                   │
│    • Assessment: on_track/at_risk/... │
│    • Ready to complete? (yes/no)       │
│    • Recommended result                │
│    • Confidence level                  │
│  ────────────────────────────────────  │
│  Recommends:                           │
│    ✓ Continue with refinements         │
│    ✓ Complete with success             │
│    ✗ Abandon due to contradiction      │
└────────────────────────────────────────┘
         ↓
  Human Reviews Recommendation
         ↓
  Completes Experiment
         ↓
    (completed)
         ↓
  Auto-Archive After 90 Days
         ↓
    (archived)
```

## Why This Matters

**Without AI Analysis:**
- Experiments stay "active" indefinitely
- No objective measure of completion
- Learnings not extracted
- Resources wasted on stale experiments

**With AI Analysis:**
- ✅ Objective completion recommendations
- ✅ Learnings extracted and recorded
- ✅ Stale experiments detected
- ✅ Automatic archival prevents clutter
- ✅ Prevents indefinite active state

## Components Working Together

| Component | Role |
|-----------|------|
| `start-experiment.sh` | Creates experiments |
| `experiment_manager.py` | Tracks lifecycle states |
| `experiment-monitor.sh` | Shows status dashboard |
| **`experiment_analyzer.py`** | **Analyzes and recommends** ← THE AI |
| `index.db` | Stores all data |

## Files Created

```
agents/
  └─ experiment_analyzer.py          ← MAIN AI AGENT
scripts/lib/
  ├─ experiment_manager.py           ← Lifecycle management
  ├─ db.py                          ← Database operations
  └─ db.py                          ← CLI for DB
scripts/
  ├─ start-experiment.sh            ← Creation
  └─ experiment-monitor.sh           ← Monitoring
```

## Quick Commands

```bash
# Check an experiment
python3 agents/experiment_analyzer.py analyze 3

# Check all active
python3 agents/experiment_analyzer.py all

# Get report
python3 agents/experiment_analyzer.py report

# View monitor dashboard
./scripts/experiment-monitor.sh status
```

## Summary

**Who:** `experiment_analyzer.py` agent  
**Model:** opencode/big-pickle (free, local)  
**When:** On-demand or scheduled via watcher  
**What:** Analyzes experiments and recommends completion  
**Result:** Structured recommendations prevent indefinite active state
