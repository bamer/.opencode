# Experiment Analyzer - OpenCode Server Integration

## Setup

### Prerequisites
- OpenCode server running at `http://localhost:8888`
- Python 3.7+
- requests library: `pip install requests`

### Start OpenCode Server
```bash
opencode --server
```

Default port: 8888

## Architecture

### Two-Layer Integration

```
┌─────────────────────────────────────┐
│  experiment_analyzer.py             │
│  (AI analysis agent)                │
├─────────────────────────────────────┤
│                                     │
│  Uses: OpenCodeClient               │
│  ├─ OpenCode Server API (primary)   │
│  │  └─ http://localhost:8888        │
│  └─ CLI fallback                    │
│                                     │
├─────────────────────────────────────┤
│  opencode_client.py                 │
│  (wrapper for server/CLI)           │
└─────────────────────────────────────┘
         ↓
  ┌───────────────────┐
  │ OpenCode Server   │
  │ :8888             │
  └───────────────────┘
         ↓
  ┌───────────────────┐
  │ opencode/         │
  │ big-pickle        │
  │ (LLM)             │
  └───────────────────┘
```

## How It Works

### 1. Experiment Analyzer Calls OpenCode
```python
from opencode_client import call_opencode

response = call_opencode(
    prompt="Analyze this experiment...",
    model="opencode/big-pickle",
    timeout=120
)
```

### 2. OpenCode Client:
```python
# Option A: Try Server API
POST http://localhost:8888/session
  → Creates session
POST http://localhost:8888/session/:id/message
  → Sends prompt, gets analysis
DELETE http://localhost:8888/session/:id
  → Cleans up

# Option B: Fallback to CLI
opencode --model opencode/big-pickle --prompt "..."
```

### 3. Server API Request
```json
POST /session/:id/message
{
  "model": "opencode/big-pickle",
  "parts": [
    {
      "type": "text",
      "text": "Analyze experiment #3..."
    }
  ]
}
```

### 4. Response
```json
{
  "info": {
    "id": "msg_...",
    "sessionID": "session_...",
    "timestamp": "2026-01-29T18:30:00Z"
  },
  "parts": [
    {
      "type": "text",
      "text": "{\"assessment\": \"on_track\", ...}"
    }
  ]
}
```

## Usage

### Command Line
```bash
# Single experiment
python3 agents/experiment_analyzer.py analyze 3

# All active
python3 agents/experiment_analyzer.py all

# Report
python3 agents/experiment_analyzer.py report
```

### Python API
```python
from agents.experiment_analyzer import ExperimentAnalyzer

analyzer = ExperimentAnalyzer(
    model="opencode/big-pickle",
    server_url="http://localhost:8888"
)

# Analyze one
result = analyzer.analyze_experiment(3)
print(result)

# Analyze all
results = analyzer.analyze_all_active()

# Report
report = analyzer.generate_report()
print(report)
```

### OpenCode Client Directly
```python
from agents.opencode_client import OpenCodeClient

client = OpenCodeClient(
    server_url="http://localhost:8888",
    model="opencode/big-pickle"
)

# Check server health
health = client.get_health()
print(f"Server healthy: {health.get('healthy')}")

# Get available providers
providers = client.get_providers()

# Call AI
response = client.call(
    prompt="Analyze this experiment...",
    timeout=120
)
print(response)
```

## Configuration

### Environment Variables
```bash
# Custom server URL
export OPENCODE_SERVER_URL="http://your-server:8888"

# Custom model
export OPENCODE_WATCHER_MODEL="opencode/big-pickle"
```

### Code Configuration
```python
analyzer = ExperimentAnalyzer(
    model="opencode/big-pickle",
    server_url="http://localhost:8888"
)
```

## Server API Endpoints Used

### Session Management
```
POST /session              # Create session
POST /session/:id/message  # Send message (blocking)
DELETE /session/:id        # Delete session
GET /global/health         # Check health
```

### Message Format
```python
{
    "model": "opencode/big-pickle",
    "parts": [
        {"type": "text", "text": "Your prompt"}
    ]
}
```

## Files

```
agents/
  ├─ opencode_client.py           # ← NEW: Server/CLI wrapper
  ├─ experiment_analyzer.py       # ← UPDATED: Uses OpenCode client
  └─ elf_heuristic_discovery.py

scripts/
  ├─ start-experiment.sh
  ├─ experiment-monitor.sh
  └─ lib/
     ├─ experiment_manager.py
     └─ db.py
```

## Error Handling

The client automatically:
- Checks server health
- Falls back to CLI if server unavailable
- Handles timeouts gracefully
- Cleans up sessions on completion

## Example Flow

```
1. User calls analyzer
   → python3 agents/experiment_analyzer.py all

2. Analyzer creates OpenCodeClient
   → OpenCodeClient(server_url="http://localhost:8888")

3. Client checks server health
   → GET /global/health → ✓ healthy

4. For each experiment:
   a) Create session
      → POST /session → {"id": "session_..."}
   
   b) Send message
      → POST /session/:id/message
      → body: {"model": "...", "parts": [...]}
   
   c) Receive response
      → {"info": {...}, "parts": [{"type": "text", "text": "..."}]}
   
   d) Parse analysis JSON
      → {"assessment": "on_track", "completion_ready": false, ...}
   
   e) Clean up session
      → DELETE /session/:id

5. Return analysis to user
   → print(json/report)
```

## Troubleshooting

### Server not responding
```bash
# Check if server is running
curl http://localhost:8888/global/health

# Start server
opencode --server

# Check port
lsof -i :8888
```

### CLI fallback not working
```bash
# Check if opencode CLI is installed
which opencode
opencode --version

# Install/update
npm install -g opencode
```

### Timeout errors
- Increase `timeout` parameter
- Reduce `max_updates_per_day` in config
- Run analyzer with fewer experiments

### Memory issues
- Limit concurrent sessions (delete old ones)
- Use `archive-old` to clean up completed experiments

## Performance

- **Server API**: ~2-5 seconds per analysis (local)
- **CLI fallback**: ~5-10 seconds per analysis
- **Concurrent**: Server handles multiple sessions

## Next Steps

1. ✅ Start OpenCode server: `opencode --server`
2. ✅ Test analyzer: `python3 agents/experiment_analyzer.py report`
3. ✅ Integrate with watcher for periodic analysis
4. ✅ Set up notifications for completion recommendations
5. ✅ Extract learnings to heuristic system
