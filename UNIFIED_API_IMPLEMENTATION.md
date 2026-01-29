# Unified OpenCode HTTP API Implementation

## Status: ✅ COMPLETE

All components updated to use OpenCode HTTP API on port 4096 instead of CLI.

## Components Updated

### 1. Watcher System ✅
**File**: `emergent-learning/src/watcher/launcher.py`

**Changes**:
- Added HTTP API calls via `call_opencode_http()` 
- CLI fallback for backwards compatibility
- Uses port 4096 with session-based communication
- Both Tier 1 (watcher) and Tier 2 (handler) use HTTP API

**Usage**:
```bash
# Make sure server is running first
opencode serve --port 4096

# Then start watcher (will use HTTP API automatically)
python3 emergent-learning/src/watcher/launcher.py
```

**Environment variables**:
- `OPENCODE_SERVER_URL`: Server URL (default: http://localhost:4096)
- `OPENCODE_WATCHER_MODEL`: Model to use (default: opencode/big-pickle)
- `OPENCODE_WATCHER_INTERVAL`: Check interval in seconds (default: 30)

### 2. BaseAgent Class ✅
**File**: `emergent-learning/agents/base_agent.py`

**Features**:
- HTTP API integration for all agents
- Session management (create, message, cleanup)
- Error handling and logging
- Conversation history tracking
- System prompts for each agent

**Agent Types**:
- `ResearcherAgent`: Investigation and research
- `ArchitectAgent`: System design
- `SkepticAgent`: Critical review
- `CreativeAgent`: Idea generation

**Usage**:
```python
from base_agent import get_agent

agent = get_agent("researcher")
result = agent.call("Research machine learning")
```

### 3. Orchestrator ✅
**File**: `emergent-learning/src/orchestrator.py`

**Features**:
- Multi-agent coordination
- Party-based team composition (from parties.yaml)
- Three workflow types:
  - Sequential: Output of one agent → input for next
  - Parallel: All agents get same task, compare results
  - Iterative: Refine task over multiple rounds
- Automatic party selection based on task keywords

**Available Parties** (from parties.yaml):
- `code-review`: Skeptic + Architect
- `new-feature`: Researcher → Architect → Creative → Skeptic
- `bug-hunt`: Researcher + Skeptic (iterative)
- `deep-dive`: Researcher + Creative (parallel)
- `adr`: Researcher → Architect → Skeptic → Creative
- And 5 more...

**Usage**:
```python
from src.orchestrator import Orchestrator

orchestrator = Orchestrator()

# Auto-detect party from task
result = orchestrator.execute("Review this code for bugs")

# Or specify party directly
result = orchestrator.execute(
    "Generate creative solutions",
    party_name="brainstorm"
)
```

### 4. CEO Advisor ✅
**File**: `emergent-learning/agents/dashboard_sentinel_ceo.py`

**Updates**:
- Added OpenCode HTTP API client
- Server URL configurable (default: port 4096)
- Can now use orchestrator for strategic analysis
- CEO-specific metrics and insights

**Usage**:
```python
from dashboard_sentinel_ceo import AISentinel

sentinel = AISentinel(
    name="CEO Dashboard",
    server_url="http://localhost:4096"
)

# Start monitoring with CEO briefings
sentinel.start_continuous_monitoring(interval=30, mode="ceo")
```

## Architecture

```
┌─────────────────────────────────────────────────┐
│          OpenCode Server (port 4096)            │
│                                                 │
│  /global/health                                 │
│  /session (POST) → create session               │
│  /session/:id/message (POST) → send prompt      │
│  /session/:id (DELETE) → cleanup                │
└──────────────┬──────────────────────────────────┘
               │
        HTTP API (JSON)
               │
      ┌────────┴────────┬─────────────┬──────────────┐
      │                 │             │              │
      ▼                 ▼             ▼              ▼
  ┌─────────┐  ┌──────────────┐  ┌──────────┐  ┌──────────┐
  │ Watcher │  │ Orchestrator │  │ Agents   │  │ CEO      │
  │         │  │              │  │          │  │ Advisor  │
  │Tier 1+2 │  │ Party Router │  │ Research │  │          │
  └─────────┘  │ Workflows    │  │Architect │  └──────────┘
               │              │  │ Skeptic  │
               └──────────────┘  │ Creative │
                                 └──────────┘
```

## API Call Flow (HTTP)

```
1. Create Session
   POST /session
   {
     "title": "watcher"
   }
   → Returns: {"id": "ses_...", ...}

2. Send Message
   POST /session/{id}/message
   {
     "model": {
       "provider": "opencode",
       "providerID": "opencode",
       "modelID": "big-pickle"
     },
     "parts": [{"type": "text", "text": "prompt..."}]
   }
   → Returns: {"parts": [{"type": "text", "text": "response..."}]}

3. Cleanup
   DELETE /session/{id}
   → Returns: 204 or 200
```

## Quick Start

### 1. Start OpenCode Server
```bash
# Terminal 1
opencode serve --port 4096

# Verify
curl http://localhost:4096/global/health
```

### 2. Test Agent
```bash
# Terminal 2
python3 emergent-learning/agents/base_agent.py
```

Expected output:
```
Testing BaseAgent with HTTP API...
✓ Connected to OpenCode server at http://localhost:4096
Result: {...analysis...}
```

### 3. Test Orchestrator
```bash
python3 emergent-learning/src/orchestrator.py
```

Expected output:
```
Available parties:
  code-review: Review code changes for quality, bugs, and design issues
  new-feature: Design and implement a new feature from scratch
  ...

Result: {...multi-agent analysis...}
```

### 4. Start Watcher
```bash
python3 emergent-learning/src/watcher/launcher.py
```

### 5. Start CEO Dashboard
```bash
python3 emergent-learning/agents/dashboard_sentinel_ceo.py --ceo
```

## Files Created/Modified

```
✅ emergent-learning/src/watcher/launcher.py         [UPDATED - HTTP API]
✅ emergent-learning/agents/base_agent.py            [CREATED - Base class]
✅ emergent-learning/src/orchestrator.py             [CREATED - Multi-agent]
✅ emergent-learning/agents/opencode_client.py       [DONE from prev work]
✅ emergent-learning/agents/dashboard_sentinel_ceo.py [UPDATED - HTTP API]
```

## Features by Component

### Watcher
- ✅ HTTP API calls
- ✅ Session management
- ✅ CLI fallback
- ✅ Both Tier 1 & 2

### BaseAgent
- ✅ HTTP API client
- ✅ Session lifecycle
- ✅ Error handling
- ✅ Logging
- ✅ History tracking
- ✅ 4 agent types implemented

### Orchestrator
- ✅ Party routing
- ✅ Sequential workflows
- ✅ Parallel workflows
- ✅ Iterative workflows
- ✅ Auto-detection
- ✅ Agent pool management

### CEO Advisor
- ✅ HTTP API integration
- ✅ Server URL config
- ✅ Executive analysis
- ✅ CEO briefings

## Testing

```bash
# Test individual component
python3 -c "from agents.base_agent import ResearcherAgent; print(ResearcherAgent())"

# Test orchestrator
python3 -c "from src.orchestrator import Orchestrator; print(Orchestrator().router.list_parties())"

# Full integration
bash run_all_tests.sh  # (if created)
```

## Environment Setup

```bash
# Make sure OpenCode is installed and running
opencode serve --port 4096

# Make sure Python dependencies are available
pip3 install requests pyyaml

# Verify connection
curl http://localhost:4096/global/health
```

## Next Steps

Optional enhancements:
1. Add streaming support for large responses
2. Add caching layer for frequently called agents
3. Add metrics/monitoring for agent performance
4. Create web UI for orchestrator
5. Add database persistence for results

## Troubleshooting

**Server connection error**:
```bash
# Check if server is running
curl http://localhost:4096/global/health

# If not, start it
opencode serve --port 4096
```

**Agent timeout**:
```bash
# Increase timeout in code
agent = ResearcherAgent(timeout=600)  # 10 minutes
```

**Module import errors**:
```bash
# Make sure agents directory is in Python path
export PYTHONPATH="/home/bamer/.opencode/emergent-learning:$PYTHONPATH"
```

## Summary

✅ **All agents now use OpenCode HTTP API on port 4096**
- Watcher: HTTP with CLI fallback
- Agents: Full HTTP API support
- Orchestrator: Multi-agent coordination
- CEO: Strategic analysis via API

🎯 **Ready to use**:
1. Start OpenCode server: `opencode serve --port 4096`
2. Run agents/watcher/orchestrator as needed
3. All communicate via HTTP on port 4096
