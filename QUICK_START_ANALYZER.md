# Quick Start - Experiment Analyzer with OpenCode

## 1. Start OpenCode Server
```bash
opencode --server
```
This starts the server on `http://localhost:8888`

## 2. Use the Analyzer

### See all active experiments
```bash
python3 /home/bamer/.opencode/emergent-learning/scripts/experiment-monitor.sh status
```

### Analyze an experiment
```bash
python3 /home/bamer/.opencode/emergent-learning/agents/experiment_analyzer.py analyze 1
```

### Analyze all
```bash
python3 /home/bamer/.opencode/emergent-learning/agents/experiment_analyzer.py all
```

### Get report
```bash
python3 /home/bamer/.opencode/emergent-learning/agents/experiment_analyzer.py report
```

## 3. Workflow

```
Create Experiment
    ↓
Run Cycles (update log.md)
    ↓
AI Analyzes (via OpenCode Server)
    ├─ reads hypothesis
    ├─ checks progress
    └─ recommends completion
    ↓
Complete When Ready
    ↓
Auto-Archive After 90 Days
```

## 4. How It Works

### The analyzer:
1. ✅ Creates OpenCode session
2. ✅ Sends experiment details
3. ✅ Asks: "Is this ready to complete?"
4. ✅ Receives structured analysis
5. ✅ Shows recommendation

### You:
1. Review recommendation
2. Complete the experiment
3. Or continue running cycles

## 5. System Components

| Component | Role |
|-----------|------|
| `opencode_client.py` | Talks to OpenCode server |
| `experiment_analyzer.py` | Analyzes experiments |
| `experiment_manager.py` | Manages lifecycle |
| `experiment-monitor.sh` | Shows dashboard |

## 6. Files Modified

- ✅ Created: `agents/opencode_client.py`
- ✅ Updated: `agents/experiment_analyzer.py`
- ✅ Docs: `EXPERIMENT_ANALYZER_SETUP.md`

## Key Features

✅ **Uses OpenCode Server API** (not CLI)
- Faster: API calls vs subprocess overhead
- Cleaner: HTTP API vs CLI parsing
- Better: Session management

✅ **Fallback to CLI**
- If server down, uses `opencode` command
- Automatic detection

✅ **Smart Analysis**
- Reads hypothesis & criteria
- Evaluates against progress
- Recommends completion (or not)
- Extracts learnings

## Example Output

```
$ python3 agents/experiment_analyzer.py analyze 1

{
  "assessment": "on_track",
  "completion_ready": false,
  "recommended_result": "success",
  "confidence": 0.85,
  "key_findings": [
    "Hypothesis validated in 80% of test cases",
    "Performance improved by 15%"
  ],
  "learnings": [
    "Iterative refinement essential",
    "User feedback prevents 40% of issues"
  ]
}
```

## Troubleshooting

### Server not found
```bash
# Make sure it's running
opencode --server

# Verify it's listening
curl http://localhost:8888/global/health
```

### Timeout
- Server might be slow
- Increase timeout: `analyzer.analyze_experiment(1, timeout=300)`

### No opencode CLI
```bash
npm install -g opencode
```

## Next: Integration

To fully automate:

```bash
# Periodic analysis (every 6 hours)
0 */6 * * * python3 /path/to/experiment_analyzer.py all | python3 /path/to/notify.py
```

Or integrate with watcher:
```python
# In watcher cycle
import subprocess
result = subprocess.run(["python3", "agents/experiment_analyzer.py", "all"])
```

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────┐
│                   Experiment Analyzer                   │
│  (agents/experiment_analyzer.py)                        │
│  ───────────────────────────────────────────────────── │
│  • Reads: hypothesis, criteria, cycles_run, logs       │
│  • Analyzes: progress, readiness                       │
│  • Recommends: complete/continue/pause                 │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ↓ uses
        ┌──────────────────────────────┐
        │   OpenCode Client             │
        │ (opencode_client.py)          │
        │ ──────────────────────────   │
        │ • Detects server              │
        │ • Creates session             │
        │ • Sends message               │
        │ • Parses response             │
        │ • Fallback to CLI             │
        └──────────┬───────────────────┘
                   │
         ┌─────────┴─────────┐
         ↓                   ↓
   ┌──────────────┐   ┌──────────────┐
   │  Server API  │   │  CLI (bkp)   │
   │ :8888        │   │              │
   │ /session/:id │   │ opencode CLI │
   │ /message     │   │              │
   └──────┬───────┘   └──────┬───────┘
          │                  │
          └─────────┬────────┘
                    ↓
          ┌──────────────────────┐
          │  opencode/big-pickle │
          │  LLM                 │
          └──────────────────────┘
```

## All Commands

```bash
# Create experiment
./scripts/start-experiment.sh --name "..." --hypothesis "..."

# Monitor dashboard
./scripts/experiment-monitor.sh status

# Analyze one
python3 agents/experiment_analyzer.py analyze 1

# Analyze all
python3 agents/experiment_analyzer.py all

# Get report
python3 agents/experiment_analyzer.py report

# Complete
python3 scripts/lib/experiment_manager.py complete 1 "success" "Notes"

# Archive old
./scripts/experiment-monitor.sh archive 90
```

---

**Ready?** Start the OpenCode server and run:
```bash
python3 agents/experiment_analyzer.py report
```
