# OpenCode TUI Integration - Experiment Analyzer

## Key Insight

**Yes!** When you run OpenCode TUI (`opencode` command), the server is already running in the background!

```
┌─────────────────────────────────────────┐
│    OpenCode TUI (opencode command)      │
│    ───────────────────────────────────  │
│    • Terminal UI for you                │
│    • Backend server (internal socket)   │
│    • CLI interface for scripts          │
└────────┬────────────────────────────────┘
         │
         ├─→ TUI frontend (you use this)
         │
         ├─→ Backend server (Python/Node)
         │
         └─→ CLI (scripts use this)
```

## How It Works

When you're in OpenCode TUI terminal:

1. **Your interaction** → TUI frontend ↔ Backend server
2. **Script interaction** → opencode CLI ↔ Backend server

The analyzer uses the **CLI** which automatically connects to your running backend!

## Architecture

```
experiment_analyzer.py
    ↓
OpenCodeClient
    ↓
opencode --model opencode/big-pickle --prompt "..."
    ↓
CLI communicates with running TUI backend
    ↓
opencode/big-pickle LLM
    ↓
Analysis JSON
```

## Usage (It Just Works!)

No need to start a separate server!

```bash
# 1. Open OpenCode TUI (if not already)
opencode

# 2. In another terminal, run analyzer
python3 agents/experiment_analyzer.py all

# 3. Results come back via OpenCode backend
```

## Files Updated

1. **`opencode_client.py`** - Simplified to use CLI only
   - ✅ Detects OpenCode CLI availability
   - ✅ Calls via subprocess
   - ✅ Works with running TUI backend
   - ❌ No HTTP requests needed

2. **`experiment_analyzer.py`** - Updated initialization
   - ✅ Cleaner: `OpenCodeClient(model="opencode/big-pickle")`
   - ✅ No server URL parameter
   - ✅ Just works™

## Quick Test

```bash
# Test OpenCode CLI
opencode --version

# Test with a simple prompt
opencode --model opencode/big-pickle --prompt "What is 2+2?"

# Test analyzer
python3 agents/experiment_analyzer.py report
```

## Why This Works

OpenCode TUI is designed for this:
- ✅ CLI in background mode
- ✅ Communicates with running TUI backend
- ✅ Perfect for programmatic access
- ✅ No external server needed

You already have everything you need!

## Complete Workflow

```
1. opencode (start TUI with backend)
   ↓
2. python3 agents/experiment_analyzer.py all
   ├─ Creates OpenCodeClient
   ├─ Calls opencode CLI
   ├─ Backend processes (via TUI socket)
   ├─ Returns analysis JSON
   └─ Done!
   ↓
3. Review recommendations
   ↓
4. Complete experiments
```

## Configuration

No configuration needed! Just:

```python
from opencode_client import OpenCodeClient

client = OpenCodeClient(model="opencode/big-pickle")
response = client.call("Your prompt")
```

## Troubleshooting

### CLI not found
```bash
npm install -g opencode
```

### TUI not running (optional)
```bash
# You don't NEED to run TUI for analyzer to work
# But if you want to: opencode

# Analyzer will still work via CLI background mode
```

### Timeout
- TUI backend might be slow
- Increase timeout: `client.call(prompt, timeout=300)`

## Real Example

```bash
$ python3 agents/experiment_analyzer.py analyze 1

(OpenCode CLI is called)
(Connects to TUI backend)
(Analyzes experiment)
(Returns JSON)

{
  "assessment": "on_track",
  "completion_ready": false,
  "confidence": 0.85,
  ...
}
```

## Summary

**Before (wrong approach):**
- ❌ Tried to connect to HTTP server
- ❌ Port 8888 was busy (dashboard)
- ❌ Didn't understand TUI architecture

**After (correct approach):**
- ✅ Use OpenCode CLI (already installed)
- ✅ CLI connects to TUI backend
- ✅ Works seamlessly with running TUI
- ✅ No external servers needed

**You're all set!** The infrastructure is already in place.
