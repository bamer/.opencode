---
name: checkin
description: Load and review Emergent Learning Framework context, institutional knowledge, golden rules, and recent session history. Runs the checkin workflow with OpenCode big-pickle model.
license: MIT
---

# ELF Checkin Command

Interactive workflow to load the building context before starting work with OpenCode and big-pickle.

## What It Does

The `/checkin` command:
- Shows the ELF banner with ASCII art **first** (before any prompts)
- Queries the building for golden rules and heuristics
- Displays relevant context and frameworks
- Asks if you want to launch the dashboard **(first checkin only)**
- Asks which AI model you want to use **(first checkin only)**
- Checks for pending CEO decisions
- Loads and displays recent session context

## Usage

```bash
/checkin
```

The checkin command is simple - just type `/checkin` to load framework context and prepare your session.

## Execution

This skill runs the Python-based orchestrator in non-interactive mode:

```bash
python ~/.opencode/emergent-learning/query/checkin.py --non-interactive
```

### Handling Non-Interactive Mode

The `--non-interactive` flag tells the script to output `[PROMPT_NEEDED]` JSON hints
instead of blocking on `input()`. When you see these in the output:

1. **Dashboard prompt**: `[PROMPT_NEEDED] {"type": "dashboard", ...}`
   - Use `AskUserQuestion` tool to ask: "Start ELF Dashboard?"
   - Options: "Yes (Recommended)" / "No"
   - If yes, run: `bash ~/.opencode/emergent-learning/dashboard-app/run-dashboard.sh`

2. **Model selection**: `[PROMPT_NEEDED] {"type": "model", ...}`
   - Use `AskUserQuestion` tool to ask: "Which AI model for this session?"
   - Options: "OpenCode (big-pickle)" / "Other models"
   - Store selection in `ELF_MODEL` environment variable

The orchestrator is a complete 8-step workflow:
- Step 1: Display banner
- Step 2: Verify hooks installation
- Step 3: Load building context (golden rules & heuristics)
- Step 4: Display golden rules & heuristics
- Step 5: Dashboard prompt (first checkin only, with state tracking)
- Step 6: Model selection prompt (first checkin only, with persistence)
- Step 7: CEO decision checking
- Step 8: Ready signal

## Workflow Steps (8-Step Structured Process)

### Step 1: Display Banner ✓
Show ELF ASCII art immediately
- **Always shown** on every checkin
- **Signals** that framework is loading

### Step 1b: Verify Hooks ✓
Check that ELF hooks are properly installed
- Verifies hook installation status
- Non-blocking (continues on error)

### Step 2: Load Building Context ✓
Query the learning framework
- Loads golden rules (Tier 1)
- Loads heuristics (Tier 2)
- Loads recent patterns and learnings

### Step 3: Display Golden Rules & Heuristics ✓
Parse and format context for readability
- Shows rule count and key principles
- Displays relevant patterns

### Step 4: Previous Session Summary
(Optional/async) Spawn async agent to summarize recent work
- Shows continuity with previous sessions

### Step 5: Dashboard Prompt ⚡
Ask user if they want to start the dashboard
- **Only on first checkin** (tracked via state file)
- "Start ELF Dashboard? [Y/n]"
- Launch in background if yes
- Never asked again in same conversation

### Step 6: Model Selection ⚡
Interactive prompt to select your active AI model
- **Only on first checkin** (state-tracked)
- Current default: **OpenCode (big-pickle)**
- Selection stored in `ELF_MODEL` environment variable
- Persists for subagent invocations

### Step 7: CEO Decisions
Check for pending CEO decisions in `ceo-inbox/`
- Lists count and first 3 items
- Informational only

### Step 8: Ready Signal ✓
Print completion message
- "✅ Checkin complete. Ready to work!"
- Marks first checkin complete (state file)

## Key Features

✅ **Banner First** - Displayed before any prompts, not after
✅ **Hook Verification** - Ensures ELF hooks are installed
✅ **One-Time Prompts** - Dashboard and model selection appear only on first checkin
✅ **State Tracking** - Uses `~/.opencode/.elf_checkin_state` to track conversation state
✅ **Model Persistence** - Selection stored in `ELF_MODEL` environment variable
✅ **Structured Workflow** - All 8 steps executed in proper sequence
✅ **Context Parsing** - Query output properly formatted for display
✅ **OpenCode Integration** - Works with big-pickle and OpenCode CLI

## Interactive Prompts

### Dashboard Prompt (First Checkin Only)
```
Start ELF Dashboard?
   The dashboard provides metrics, model routing, and system health.

Start Dashboard? [Y/n]:
```
- Default: Yes (just press Enter)
- Launches in background if accepted
- Never asks again in same conversation

### Model Selection Prompt (First Checkin Only)
```
Select Your Active Model
   Available models:
     (o)pencode  - big-pickle model (Recommended)
     (o)ther     - Other OpenCode models
     (s)kip      - Use current model

Select [o/s]:
```
- Default: OpenCode (big-pickle)
- Stores choice in `ELF_MODEL` environment variable
- Used by subagent routing

## Integration with Building

The checkin workflow is your gateway to the building's knowledge:
- **Golden Rules** - Constitutional principles (always loaded)
- **Heuristics** - Reusable patterns and knowledge
- **Failures** - What went wrong and lessons learned
- **Successes** - What worked and can be replicated
- **Sessions** - Previous work summaries for continuity

Running checkin at the start of each session ensures you're working with current institutional knowledge.

## OpenCode/Big-Pickle Integration

The checkin orchestrator:
- Outputs structured JSON hints for OpenCode to parse
- Uses `AskUserQuestion` tool for interactive prompts
- Compatible with big-pickle model inference
- Stores state in OpenCode cache directories

When big-pickle sees `[PROMPT_NEEDED]` hints, it:
1. Parses the JSON
2. Uses `AskUserQuestion` to prompt user
3. Captures user response
4. Continues orchestrator workflow

## Environment Variables

```bash
ELF_MODEL              # Selected model (default: opencode/big-pickle)
ELF_BASE_PATH          # ELF installation path
OPENCODE_DIR           # OpenCode root directory
```

## Troubleshooting

**Q: Dashboard won't start**
- Check: `~/.opencode/emergent-learning/dashboard-app/run-dashboard.sh` exists
- Try running manually: `bash ~/.opencode/emergent-learning/dashboard-app/run-dashboard.sh`

**Q: Model selection not working**
- Check: `ELF_MODEL` environment variable
- Reset: `unset ELF_MODEL && /checkin`

**Q: Checkin hangs**
- Check: Hook verification isn't timing out
- Try: `python ~/.opencode/emergent-learning/query/checkin.py --non-interactive`

**Q: Golden rules not loading**
- Check: `~/.opencode/emergent-learning/query/query.py` is working
- Try: `python ~/.opencode/emergent-learning/query/query.py --context`
