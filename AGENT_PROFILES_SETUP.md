# Agent Profiles Setup - Complete

All agent profiles are now available to OpenCode server and configured for use.

## What's New

### Agent Profiles Created
✅ `.opencode/agents/researcher.md` - Investigation & Analysis expert
✅ `.opencode/agents/architect.md` - Architecture & Design specialist
✅ `.opencode/agents/skeptic.md` - Quality & Risk Assessment expert
✅ `.opencode/agents/creative.md` - Innovation & Ideation specialist
✅ `.opencode/agents/ceo.md` - Strategic Leadership & Business Direction
✅ `.opencode/agents/learning-extractor.md` - Knowledge & Continuous Improvement
✅ `.opencode/agents/INDEX.md` - Agent directory and reference

### Updated Components
✅ `emergent-learning/agents/opencode_client.py` - Now supports named agents
✅ `emergent-learning/agents/base_agent.py` - Uses HTTP API with agents
✅ `emergent-learning/src/orchestrator.py` - Routes to agent profiles

## Agent Profiles Structure

Each profile defines:
1. **Purpose** - Core mission and value
2. **Characteristics** - Key traits and expertise
3. **Behaviors** - How the agent operates
4. **System Prompt** - Instructions for the model
5. **Response Format** - Structured response templates
6. **Collaboration** - How agents work together
7. **Performance Indicators** - Success metrics
8. **Tools & Capabilities** - What the agent can do

## Directory Structure

```
.opencode/
├── agents/                    ← Agent profiles directory
│   ├── researcher.md          (Investigation & Analysis)
│   ├── architect.md           (Architecture & Design)
│   ├── skeptic.md             (Quality & Risk)
│   ├── creative.md            (Innovation & Ideas)
│   ├── ceo.md                 (Strategic Leadership)
│   ├── learning-extractor.md  (Knowledge & Learning)
│   └── INDEX.md               (Agent index & reference)
├── emergent-learning/
│   ├── agents/
│   │   ├── base_agent.py      (Uses agents via HTTP)
│   │   └── opencode_client.py (Agent parameter support)
│   └── src/
│       └── orchestrator.py    (Routes to agents)
```

## Quick Start

### 1. Start OpenCode Server
```bash
opencode serve --port 4096
```

### 2. List Available Agents
```bash
curl http://localhost:4096/agent
```

Response:
```json
[
  {
    "id": "researcher",
    "name": "Researcher",
    "description": "Investigation & Analysis expert"
  },
  {
    "id": "architect",
    "name": "Architect",
    "description": "Architecture & Design specialist"
  },
  ...
]
```

### 3. Use Agent via HTTP API
```bash
# Create session
SESSION=$(curl -s -X POST http://localhost:4096/session \
  -H "Content-Type: application/json" \
  -d '{"title":"research"}' | jq -r '.id')

# Use specific agent
curl -X POST http://localhost:4096/session/$SESSION/message \
  -H "Content-Type: application/json" \
  -d '{
    "agent": "researcher",
    "model": {
      "providerID": "opencode",
      "modelID": "big-pickle"
    },
    "parts": [{
      "type": "text",
      "text": "Research machine learning"
    }]
  }'
```

## Using Agents in Code

### Python - Direct Agent
```python
from agents.base_agent import ResearcherAgent

agent = ResearcherAgent()
result = agent.call("Research microservices")
```

### Python - OpenCode Client with Agent
```python
from agents.opencode_client import OpenCodeClient

client = OpenCodeClient()

# Use specific agent
result = client.call(
    "Research this topic",
    agent="researcher"
)
```

### Python - Orchestrator (Multi-Agent)
```python
from src.orchestrator import Orchestrator

orchestrator = Orchestrator()

# Auto-detect party with right agents
result = orchestrator.execute("Review my code")

# Or specify explicit agent
result = orchestrator.execute(
    "Design a system",
    party_name="new-feature"  # Uses Researcher→Architect→Creative→Skeptic
)
```

## Agent Selection Guide

| Task | Agent | Why |
|------|-------|-----|
| Research topic | **researcher** | Deep investigation and analysis |
| Design system | **architect** | Scalable system design |
| Review code | **skeptic** | Find bugs and risks |
| Generate ideas | **creative** | Brainstorm and innovate |
| Strategic decision | **ceo** | Business context and ROI |
| Extract learnings | **learning-extractor** | Synthesize knowledge |

## Agent Profiles Overview

### Researcher
- **Role**: Investigation & Analysis
- **Strength**: Deep research, pattern recognition
- **Best for**: Understanding complex topics, finding sources
- **Approach**: Methodical, evidence-based

### Architect
- **Role**: Architecture & Design
- **Strength**: System design, scalability planning
- **Best for**: Technical strategy, design decisions
- **Approach**: Strategic, holistic, trade-off focused

### Skeptic
- **Role**: Quality & Risk Assessment
- **Strength**: Finding issues, edge cases, risks
- **Best for**: Code/design review, quality assurance
- **Approach**: Thorough, questioning, constructive

### Creative
- **Role**: Innovation & Ideation
- **Strength**: Generating ideas, alternatives
- **Best for**: Brainstorming, exploring possibilities
- **Approach**: Exploratory, unconventional

### CEO
- **Role**: Strategic Leadership & Business Direction
- **Strength**: Business strategy, executive decisions
- **Best for**: Strategic planning, business analysis
- **Approach**: Strategic, outcome-focused

### Learning Extractor
- **Role**: Knowledge & Continuous Improvement
- **Strength**: Extracting insights, identifying patterns
- **Best for**: Knowledge synthesis, process improvement
- **Approach**: Analytical, systematic

## Agent Composition (Party Examples)

### Code Review
- **Agents**: Skeptic → Architect
- **Flow**: Sequential (skeptic finds issues, architect evaluates design)

### New Feature
- **Agents**: Researcher → Architect → Creative → Skeptic
- **Flow**: Sequential (research → design → ideas → review)

### Bug Hunt
- **Agents**: Researcher ↔ Skeptic
- **Flow**: Iterative (investigate and refine understanding)

### Deep Dive Research
- **Agents**: Researcher, Creative (parallel)
- **Flow**: Parallel (multiple perspectives)

### Architecture Decision
- **Agents**: Researcher → Architect → Skeptic → Creative
- **Flow**: Sequential (research options → design → challenge → alternatives)

### Brainstorm
- **Agents**: Creative → Researcher → Architect
- **Flow**: Iterative (ideas → ground in reality → evaluate feasibility)

## HTTP API Usage

### Message with Agent Parameter
```bash
curl -X POST http://localhost:4096/session/{id}/message \
  -H "Content-Type: application/json" \
  -d '{
    "agent": "architect",          # Specify agent
    "model": {
      "providerID": "opencode",
      "modelID": "big-pickle"
    },
    "parts": [{"type": "text", "text": "Design..."}]
  }'
```

### Available Agents
- `researcher` - Investigation & Analysis
- `architect` - Architecture & Design
- `skeptic` - Quality & Risk Assessment
- `creative` - Innovation & Ideation
- `ceo` - Strategic Leadership
- `learning-extractor` - Knowledge & Learning

## Configuration

### Environment Variables
```bash
# Server
OPENCODE_SERVER_URL=http://localhost:4096

# Agent defaults
OPENCODE_DEFAULT_AGENT=researcher  # (optional)

# Watcher
OPENCODE_WATCHER_MODEL=opencode/big-pickle
```

### Python Client
```python
# Set default agent
client = OpenCodeClient()
result = client.call("prompt", agent="architect")

# Or in orchestrator
orchestrator = Orchestrator(server_url="http://localhost:4096")
```

## Testing

### Verify Agents Available
```bash
# Check server
curl http://localhost:4096/global/health

# List agents
curl http://localhost:4096/agent

# Run tests
bash run_unified_tests.sh
```

### Test Specific Agent
```python
from agents.base_agent import ArchitectAgent

agent = ArchitectAgent()
print(f"Agent: {agent}")
print(f"System Prompt: {agent.system_prompt[:100]}...")

# Quick test
result = agent.call("Design a system for 1M users")
```

## Extending Agents

### Create New Agent Profile
```bash
# 1. Create profile
nano agents/devops.md

# 2. Structure (use researcher.md as template):
# - Purpose
# - Characteristics
# - Behaviors
# - System Prompt
# - Response Format
# - etc.

# 3. Restart OpenCode server
opencode serve --port 4096  # Auto-discovers new agents
```

### Register Custom Agent
The OpenCode server auto-discovers all `.md` files in `.opencode/agents/` directory.

Simply create a new profile and it's available immediately after server restart.

## Performance Tips

1. **Right agent for task**: Match agent specialty to task type
2. **Use parties for complex work**: Orchestrator handles agent sequencing
3. **Leverage conversation history**: Context improves responses
4. **Parallel for perspectives**: Get multiple viewpoints simultaneously
5. **Sequential for refinement**: Chain agents when building on previous work

## Limitations & Fallbacks

- **No agent specified**: Uses default model without specific profile
- **Agent not found**: Server returns error (check available agents)
- **HTTP API unavailable**: Falls back to CLI (if available)
- **Agent timeout**: Increase timeout parameter (default: 300s)

## Troubleshooting

### Server not responding
```bash
opencode serve --port 4096
```

### Agent not found
```bash
# Check available agents
curl http://localhost:4096/agent

# Ensure profile exists
ls -la ~/.opencode/agents/
```

### Connection error
```bash
# Check server is running
curl http://localhost:4096/global/health

# Set correct server URL
export OPENCODE_SERVER_URL=http://localhost:4096
```

## Next Steps

1. **Start OpenCode server**: `opencode serve --port 4096`
2. **Explore agents**: `curl http://localhost:4096/agent`
3. **Run orchestrator**: `python3 emergent-learning/src/orchestrator.py`
4. **Use agents**: `python3 emergent-learning/agents/base_agent.py`
5. **Customize profiles**: Create new agents in `.opencode/agents/`

## Documentation

- **Agent Profiles**: `.opencode/agents/researcher.md` etc.
- **Agent Index**: `.opencode/agents/INDEX.md`
- **Usage Examples**: `AGENT_USAGE_EXAMPLES.md`
- **API Docs**: `OPENCODE_HTTP_API_COMPLETE.md`
- **Orchestrator**: `ORCHESTRATOR_GUIDE.md`

## Summary

✅ **6 Agent Profiles Created** - Researcher, Architect, Skeptic, Creative, CEO, Learning-Extractor
✅ **HTTP API Integration** - All agents accessible via port 4096
✅ **Party System** - Pre-configured agent teams for common tasks
✅ **Auto-Discovery** - OpenCode auto-discovers agents in `.opencode/agents/`
✅ **Production Ready** - Fully integrated with orchestrator and clients

All agents are now available to OpenCode and ready for use!

---

**Last Updated**: 2026-01-29
**Version**: 1.0 Complete
**Status**: ✅ Production Ready
