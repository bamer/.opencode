# Watcher Status Report

## Configuration: OpenCode with big-pickle Model

**Date**: 2026-01-29  
**Status**: ✅ **CONFIGURED AND TESTED**

---

## System Overview

The watcher has been reconfigured to use **OpenCode** with the **`opencode/big-pickle`** model instead of local endpoints.

### Architecture

```
User Interaction → Hook Detection → Spawn Watcher (Tier 1)
                                         ↓
                                  opencode/big-pickle
                                         ↓
                             Detect Issues/Escalations
                                         ↓
                    If Issues → Handler (Tier 2)
                                         ↓
                                  opencode/big-pickle
                                         ↓
                            Make Decision & Act
                                         ↓
                         Log & Exit (Wait for next user)
```

### Tier System

| Tier | Role | Model | Function |
|------|------|-------|----------|
| **1 (Watcher)** | Detection | `opencode/big-pickle` | Analyzes coordination state, detects problems |
| **2 (Handler)** | Decision | `opencode/big-pickle` | Makes decisions if escalation needed (RESTART, ABANDON, ESCALATE) |

---

## Configuration Summary

### File Locations

```
~/.opencode/
├── emergent-learning/
│   ├── elf_paths.py                    ✅ NEW (path resolution)
│   ├── src/watcher/
│   │   ├── launcher.py                 ✅ UPDATED (calls opencode CLI)
│   │   └── start-watcher.sh            ✅ UPDATED (checks opencode CLI)
│   └── watcher/
│       ├── watcher_loop.py             ✅ (unchanged, generates prompts)
│       ├── run_with_bigpickle.py       ✅ (unchanged, alternative launcher)
│       └── auto_spawn.py               ✅ (unchanged, daemon spawner)
├── scripts/patches/
│   ├── launcher-openai.patch           ✅ UPDATED
│   └── start-watcher-openai.patch      ✅ UPDATED
├── test-watcher.sh                     ✅ NEW (validation script)
├── start-watcher                       ✅ NEW (convenience wrapper)
└── WATCHER_UPDATE.md                   ✅ NEW (full documentation)
```

### Environment Variables

| Variable | Value | Required |
|----------|-------|----------|
| `OPENCODE_WATCHER_MODEL` | `opencode/big-pickle` | No (default provided) |
| `OPENCODE_WATCHER_INTERVAL` | `30` | No (default provided) |
| `ELF_BASE_PATH` | `~/.opencode/emergent-learning` | No (auto-resolved) |

---

## Quick Commands

### Test Configuration
```bash
bash ~/.opencode/test-watcher.sh
```

Expected output:
```
✓ opencode CLI found
✓ Python3 found
✓ ELF directory found
✓ Watcher prompt generated
✓ launcher.py found
✓ start-watcher.sh found
✓ elf_paths module works

All tests passed!
```

### Start Watcher

**Interactive mode:**
```bash
~/.opencode/start-watcher
# or
cd ~/.opencode/emergent-learning
./src/watcher/start-watcher.sh
```

**Daemon mode:**
```bash
~/.opencode/start-watcher --daemon
# or
./src/watcher/start-watcher.sh --daemon
```

### Monitor Status

```bash
cd ~/.opencode/emergent-learning
cat .coordination/watcher-log.md
```

### Stop Watcher

```bash
# Get daemon PID and kill
ps aux | grep launcher.py
kill $PID

# Or create stop signal
touch ~/.opencode/emergent-learning/.coordination/watcher-stop
```

---

## Dependencies Check

✅ **All Required**

```bash
# opencode CLI
which opencode
opencode --version

# Python 3
python3 --version

# ELF directory
ls -d ~/.opencode/emergent-learning

# Required Python modules (all built-in)
python3 -c "import json, subprocess, sys, time, pathlib"
```

---

## Testing Results

### Test 1: Prompt Generation
```bash
✅ PASS - Watcher prompt generates correctly (128 lines)
```

### Test 2: Path Resolution
```bash
✅ PASS - elf_paths module resolves paths correctly
```

### Test 3: CLI Availability
```bash
✅ PASS - opencode CLI is available and functional
```

### Test 4: File Locations
```bash
✅ PASS - All files in correct locations and executable
```

---

## Logs & Monitoring

### Watcher Log
Location: `~/.opencode/emergent-learning/.coordination/watcher-log.md`

Example entry:
```
2026-01-29T17:24:44 | [TIER 1 WATCHER] Analysis complete - Status: nominal
2026-01-29T17:25:14 | [TIER 1 WATCHER] Analysis complete - Status: complete
2026-01-29T17:25:14 | [TIER 2 HANDLER] Action taken: RESTART
```

### Blackboard
Location: `~/.opencode/emergent-learning/.coordination/blackboard.json`

Contains current coordination state and agent status.

---

## Integration Points

### 1. Hook System (ELF_superpowers.js)
The hook automatically detects user interaction and spawns watcher passes.

Configuration:
```javascript
const WATCHER_LAUNCHER = path.join(ELF_BASE_PATH, 'watcher', 'run_with_bigpickle.py');
const WATCHER_MODEL = 'opencode/big-pickle';
```

### 2. Manual Invocation
```bash
cd ~/.opencode/emergent-learning
python3 watcher/run_with_bigpickle.py          # Single pass
python3 watcher/run_with_bigpickle.py --loop 60  # Continuous
```

### 3. Daemon Mode
```bash
./src/watcher/start-watcher.sh --daemon
```

---

## Troubleshooting

### Issue: opencode CLI not found
**Solution:**
```bash
npm install -g opencode
# or for project-local installation
npm install -D opencode
```

### Issue: Python module not found
**Solution:**
```bash
cd ~/.opencode/emergent-learning
python3 --version  # Must be 3.8+
```

### Issue: Watcher won't start
**Solution:**
```bash
bash ~/.opencode/test-watcher.sh  # Run full diagnostic
```

### Issue: Wrong model being used
**Solution:**
```bash
export OPENCODE_WATCHER_MODEL=opencode/big-pickle
echo $OPENCODE_WATCHER_MODEL  # Verify
./src/watcher/start-watcher.sh
```

### Issue: Stop file not working
**Solution:**
```bash
# Clear stop signal
rm ~/.opencode/emergent-learning/.coordination/watcher-stop
```

---

## Model Information

### opencode/big-pickle

Model: Ollama local or OpenCode-compatible  
Purpose: Fast, reliable inference for watcher tasks  
Temperature: 0.2 (deterministic)  
Timeout: 300s  

Used for:
- **Tier 1**: State analysis, problem detection
- **Tier 2**: Decision making, intervention planning

---

## Files Modified/Created

### Modified
- `emergent-learning/src/watcher/launcher.py` - Now calls opencode CLI
- `emergent-learning/src/watcher/start-watcher.sh` - Checks opencode CLI
- `scripts/patches/launcher-openai.patch` - Updated patch
- `scripts/patches/start-watcher-openai.patch` - Updated patch

### Created
- `emergent-learning/elf_paths.py` - Path resolution module
- `test-watcher.sh` - Testing/validation script
- `start-watcher` - Convenience wrapper
- `WATCHER_UPDATE.md` - Full documentation
- `WATCHER_STATUS.md` - This file

### Unchanged (still working)
- `emergent-learning/watcher/watcher_loop.py`
- `emergent-learning/watcher/run_with_bigpickle.py`
- `emergent-learning/watcher/auto_spawn.py`

---

## Next Steps

1. **Verify**: `bash ~/.opencode/test-watcher.sh`
2. **Test**: `~/.opencode/start-watcher --once` (single pass)
3. **Monitor**: View logs at `~/.opencode/emergent-learning/.coordination/watcher-log.md`
4. **Deploy**: `./src/watcher/start-watcher.sh --daemon` (persistent)

---

## Summary

✅ **Watcher fully configured for OpenCode**

- Uses `opencode/big-pickle` model
- Two-tier system (Detection → Decision)
- All dependencies available
- Full logging and monitoring
- Ready for production use

For detailed info: See `WATCHER_UPDATE.md`
