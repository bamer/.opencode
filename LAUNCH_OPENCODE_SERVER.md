# Launch OpenCode Server on Port 4096

## Start the Server

```bash
# In a terminal
opencode serve --port 4096
```

## Then Test

```bash
# Test the API
curl http://localhost:4096/global/health

# Test with our client
python3 agents/experiment_analyzer.py report
```

## Architecture with Server

```
experiment_analyzer.py
    ↓ (uses)
OpenCodeClient
    ↓ (connects to)
OpenCode Server (port 4096)
    ├─ /session (create sessions)
    ├─ /session/:id/message (send prompts)
    └─ /global/health (check status)
    ↓ (backend analyzes via)
opencode/big-pickle LLM
```

## Quick Start

```bash
# Terminal 1: Start OpenCode server
opencode serve --port 4096

# Terminal 2: Run analyzer
python3 agents/experiment_analyzer.py all
```

## Current Setup

- OpenCode TUI: Running (interactive terminal mode)
- OpenCode Server: Needs to be started (for API access)

You can run BOTH at the same time:
- TUI for interactive work
- Server for programmatic access (analyzer)
