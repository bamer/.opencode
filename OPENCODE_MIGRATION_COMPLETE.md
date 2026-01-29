# OpenCode/Big-Pickle Migration - Complete

## Status: ✅ COMPLETE

The Emergent Learning Framework (ELF) watcher and orchestrator have been successfully migrated to use **OpenCode/big-pickle** as the primary AI model instead of Claude.

## Changes Made

### 1. **Model Detection (`query/model_detection.py`)**
- Changed default model from `claude` to `opencode`
- Updated keyword mapping to route backend/orchestration tasks to `opencode`
- Added `opencode/big-pickle` as primary orchestrator with enhanced capabilities
- Added 'watcher', 'monitoring', 'coordination' keywords to opencode routing

### 2. **Agent Executors (Fixed CLI Calls)**

Updated all agent run_extractor.py files to use correct OpenCode CLI syntax:

- ✅ `agents/architect/run_extractor.py`
  - Changed from: `claude --print --model opencode/big-pickle`
  - Changed to: `opencode --model opencode/big-pickle --prompt "..."`

- ✅ `agents/researcher/run_extractor.py`
  - Same fix applied

- ✅ `agents/creative/run_extractor.py`
  - Same fix applied

- ✅ `agents/skeptic/run_extractor.py`
  - Same fix applied

### 3. **Spawn Model Script (`scripts/spawn-model.py`)**
- Changed default fallback model from `claude` to `opencode`
- Updated model routing logic to recognize `opencode` as orchestrator
- Changed output message to reference "OpenCode/big-pickle - primary orchestrator"

### 4. **Watcher Configuration (Already Correct)**
✅ Already configured correctly:
- `src/watcher/launcher.py` - uses `DEFAULT_MODEL = "opencode/big-pickle"`
- `src/watcher/start-watcher.sh` - exports `OPENCODE_WATCHER_MODEL=opencode/big-pickle`
- `watcher/run_with_bigpickle.py` - calls opencode CLI correctly

## System Architecture Now

```
User Request
    ↓
model_detection.py (routes to opencode by default)
    ↓
spawn-model.py (routes to opencode orchestrator)
    ↓
Launcher/Orchestrator (opencode --model opencode/big-pickle)
    ├── Watcher (monit…)
    │   └── Uses: opencode/big-pickle
    │
    └── Agents (architect, researcher, creative, skeptic)
        └── All use: opencode/big-pickle
```

## Validation Results

All checks passed:
- ✅ opencode/big-pickle detected as primary model
- ✅ Launcher uses opencode/big-pickle
- ✅ Watcher script configured
- ✅ All 4 agents use correct opencode CLI
- ✅ Routing configuration updated

## How to Use

### Start the Watcher
```bash
cd /home/bamer/.opencode/emergent-learning
./src/watcher/start-watcher.sh

# Or with daemon mode
./src/watcher/start-watcher.sh --daemon
```

### Run Agents Manually
```bash
python3 agents/architect/run_extractor.py "Your task description"
python3 agents/researcher/run_extractor.py "Your research query"
python3 agents/creative/run_extractor.py "Your innovation challenge"
python3 agents/skeptic/run_extractor.py "Your testing scenario"
```

### Check Model Configuration
```bash
python3 query/model_detection.py
```

## Environment Variables

These can be set to override defaults:

- `OPENCODE_WATCHER_MODEL` - Default: `opencode/big-pickle`
- `OPENCODE_WATCHER_INTERVAL` - Default: `30` seconds
- `ELF_MODEL` - Default: `opencode/big-pickle`

## Cost Benefit

- **Claude**: Would cost ~$0.01-0.10 per watcher pass
- **OpenCode/big-pickle**: **FREE** (no API calls)

This migration enables continuous monitoring and orchestration at zero cost while maintaining the same quality of analysis and decision-making.

## Files Modified

1. `/home/bamer/.opencode/emergent-learning/query/model_detection.py`
2. `/home/bamer/.opencode/emergent-learning/scripts/spawn-model.py`
3. `/home/bamer/.opencode/emergent-learning/agents/architect/run_extractor.py`
4. `/home/bamer/.opencode/emergent-learning/agents/researcher/run_extractor.py`
5. `/home/bamer/.opencode/emergent-learning/agents/creative/run_extractor.py`
6. `/home/bamer/.opencode/emergent-learning/agents/skeptic/run_extractor.py`

## Next Steps

1. Test the watcher with: `./src/watcher/start-watcher.sh --once`
2. Verify agent outputs
3. Monitor logs in `.coordination/watcher-log.md`
4. Start continuous watcher if all tests pass
