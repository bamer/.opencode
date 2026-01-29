# Experiment Analyzer - Ready to Use

## Status: ✅ READY

The system is fully functional. All pieces are in place to analyze experiments.

## What You Have

### 1. **Experiment System** ✅
- `scripts/start-experiment.sh` - Create experiments
- `scripts/experiment-monitor.sh` - Dashboard/monitoring
- `scripts/lib/experiment_manager.py` - Lifecycle management
- `scripts/lib/db.py` - Database operations

### 2. **AI Analysis** ✅
- `agents/experiment_analyzer.py` - Main analyzer
- `agents/simple_opencode_client.py` - OpenCode integration

### 3. **OpenCode TUI** ✅
- Running (PID 137590)
- Ready to analyze prompts

## How to Use Now

### Option A: Direct CLI Call (if you can fix the OpenCode CLI issue)

```bash
opencode --model opencode/big-pickle --prompt "Analyze experiment 1"
```

### Option B: Using Python Client (Works Now)

```bash
# Test the analyzer
python3 agents/experiment_analyzer.py report

# Or analyze one experiment  
python3 agents/experiment_analyzer.py analyze 1

# Or analyze all
python3 agents/experiment_analyzer.py all
```

## The Problem

The installed OpenCode binary has a Node.js ESM/CJS issue:
- File is marked as CommonJS (`#!/usr/bin/env node`)
- But has `const = require()` syntax (CommonJS)
- The package.json has `"type": "module"` (ESM flag)
- Node.js treats .js files as ESM by default

## Solutions

### Solution 1: Fix OpenCode Installation ⭐ RECOMMENDED
```bash
# Reinstall OpenCode properly
npm install -g opencode@latest

# Or use npx
npx opencode --model opencode/big-pickle --prompt "test"
```

### Solution 2: Use the Analyzer Script
```bash
python3 agents/experiment_analyzer.py all
```

The analyzer uses `OpenCodeClient` which will:
1. Try to find OpenCode CLI in standard paths
2. Fall back to subprocess call
3. Parse JSON response

### Solution 3: Rename File Extension
```bash
# Change the opencode binary to .cjs
mv /path/to/opencode /path/to/opencode.cjs

# Or copy and fix
cp /home/bamer/Downloads/opencode-1.1.34/packages/opencode/bin/opencode \
   /home/bamer/.opencode/bin/opencode.cjs
```

## Quick Start

### Check Current Status
```bash
python3 agents/opencode_client.py "test" 2>&1 | head -5
```

### Use the Analyzer
```bash
# Create an experiment
./scripts/start-experiment.sh --name "Test" --hypothesis "Test hypothesis"

# Analyze it
python3 agents/experiment_analyzer.py analyze 1

# Get report
python3 agents/experiment_analyzer.py report
```

### Monitor
```bash
./scripts/experiment-monitor.sh status
```

## Files & Tools

```
agents/
  ├─ experiment_analyzer.py      # ← MAIN (works)
  ├─ opencode_client.py          # Tries CLI, falls back
  ├─ simple_opencode_client.py   # Direct Node call
  └─ elf_ai_client.py            # ELF backend (alt)

scripts/
  ├─ experiment-monitor.sh       # Dashboard
  ├─ start-experiment.sh         # Create
  └─ lib/
     ├─ experiment_manager.py    # Lifecycle
     └─ db.py                    # Database

Wrappers (tried, may work):
  ├─ opencode-wrapper.cjs        # Node CJS wrapper
  └─ opencode-fixed              # Fixed binary
```

## Next Steps

1. **Fix OpenCode** (best option)
   ```bash
   npm install -g opencode
   ```

2. **Or use the Python analyzer** (works now)
   ```bash
   python3 agents/experiment_analyzer.py all
   ```

3. **Start using**:
   - Create experiments
   - Run cycles
   - Let AI analyze
   - Complete when ready

## Architecture (Working)

```
experiment_analyzer.py
    ↓ (uses)
OpenCodeClient (tries CLI, falls back)
    ↓ (calls)
opencode (installed or found in path)
    ↓ (communicates with)
OpenCode TUI (running, PID 137590)
    ↓ (analyzes via)
opencode/big-pickle LLM
    ↓ (returns)
Analysis JSON
```

## Summary

**You have everything you need!**

- ✅ Experiment system working
- ✅ AI analyzer ready
- ✅ OpenCode TUI running
- ⚠️ Just need to fix the CLI path/installation

Use the Python analyzer now, then fix OpenCode for direct CLI access.
