# Experiment Analyzer - Final Setup

## Step 1: Start OpenCode Server on Port 4096

In a terminal:

```bash
opencode serve --port 4096
```

## Step 2: Verify Server is Running

```bash
curl http://localhost:4096/global/health
```

Should return something like:
```json
{"healthy": true, "version": "1.1.34"}
```

## Step 3: Use the Analyzer

In another terminal:

```bash
# Check analyzer works
python3 agents/experiment_analyzer.py report

# Or analyze specific experiment
python3 agents/experiment_analyzer.py analyze 1

# Or analyze all active
python3 agents/experiment_analyzer.py all
```

## Complete Workflow

```bash
# Terminal 1: Start OpenCode server
opencode --server --port 4096

# Terminal 2: Create experiment
cd /home/bamer/.opencode/emergent-learning
./scripts/start-experiment.sh \
  --name "Feature X" \
  --hypothesis "Feature improves metrics" \
  --success-criteria "20% improvement"

# Terminal 2: Monitor dashboard
./scripts/experiment-monitor.sh status

# Terminal 2: Analyze
python3 agents/experiment_analyzer.py all

# Terminal 2: When ready, complete
python3 scripts/lib/experiment_manager.py complete 1 "success" "Notes"
```

## Architecture

```
OpenCode Server (port 4096)
    ↓
/session API
    ├─ POST /session (create)
    ├─ POST /session/:id/message (analyze)
    └─ DELETE /session/:id (cleanup)
    ↓
experiment_analyzer.py
    ├─ Opens sessions
    ├─ Sends prompts
    ├─ Gets analysis
    └─ Returns JSON
    ↓
Your application
```

## What Happens

1. **You start OpenCode server** on port 4096
2. **Analyzer creates a session** (HTTP POST)
3. **Analyzer sends prompt** (HTTP POST)
4. **OpenCode processes** via opencode/big-pickle
5. **Returns analysis** (HTTP response)
6. **Analyzer parses** and returns JSON

## Files Ready

✅ `agents/experiment_analyzer.py` - Main analyzer
✅ `agents/opencode_client.py` - HTTP client for port 4096
✅ `scripts/experiment-monitor.sh` - Dashboard
✅ `scripts/start-experiment.sh` - Create experiments
✅ `scripts/lib/experiment_manager.py` - Lifecycle

All configured to work together!

## Troubleshooting

### Server not connecting
```bash
# Check server is running
curl http://localhost:4096/global/health

# If not, start it
opencode --server --port 4096
```

### OpenCode command not found
```bash
# Use full path
/home/bamer/Downloads/opencode-1.1.34/packages/opencode/bin/opencode --server --port 4096

# Or add to PATH
export PATH="/home/bamer/Downloads/opencode-1.1.34/packages/opencode/bin:$PATH"
```

### Timeout errors
- Server might be slow
- Increase timeout: `analyzer.call(prompt, timeout=300)`
- Check server logs

## Quick Reference

```bash
# Start server
opencode serve --port 4096

# Test connection
python3 agents/opencode_client.py "test"

# Run analyzer
python3 agents/experiment_analyzer.py all

# Create experiment
./scripts/start-experiment.sh --name "Test"

# Monitor
./scripts/experiment-monitor.sh status

# Complete experiment
python3 scripts/lib/experiment_manager.py complete 1 "success"

# Archive old
./scripts/experiment-monitor.sh archive 90
```

Ready to go! 🚀
