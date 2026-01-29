# OpenCode Agent Profiles

This directory contains custom agent profiles that extend OpenCode's capabilities.

## Available Profiles

### researcher.md
Expert investigator for deep research, analysis, and pattern recognition.
- **Use for**: Researching topics, investigating issues, understanding domains
- **Strengths**: Thorough analysis, finding sources, synthesizing information

### architect.md
Strategic system designer for scalable, maintainable solutions.
- **Use for**: System design, architecture decisions, technical strategy
- **Strengths**: Scalability planning, design patterns, technical leadership

### skeptic.md
Critical reviewer for quality assurance and risk identification.
- **Use for**: Code/design review, finding edge cases, security audits
- **Strengths**: Problem identification, risk assessment, constructive criticism

### creative.md
Innovative thinker for idea generation and unconventional approaches.
- **Use for**: Brainstorming, generating alternatives, creative solutions
- **Strengths**: Multiple ideas, lateral thinking, inspiration

### ceo.md
Executive strategist for business direction and strategic decisions.
- **Use for**: Strategic planning, business analysis, executive decisions
- **Strengths**: Business perspective, ROI analysis, strategic clarity

### learning-extractor.md
Knowledge synthesis specialist for extracting learnings and patterns.
- **Use for**: Extracting insights, identifying patterns, process improvement
- **Strengths**: Knowledge organization, learning synthesis, continuous improvement

## Using Profiles

### Method 1: With Python Clients

#### Using BaseAgent
```python
from agents.base_agent import ResearcherAgent, ArchitectAgent

researcher = ResearcherAgent()
result = researcher.call("Research microservices patterns")
```

#### Using OpenCode Client with Named Agent
```python
from agents.opencode_client import OpenCodeClient

client = OpenCodeClient()
result = client.call("Design a system", agent="architect")
```

#### Using Orchestrator (Multi-Agent)
```python
from src.orchestrator import Orchestrator

orchestrator = Orchestrator()

# Auto-detects appropriate agents
result = orchestrator.execute("Review this code for bugs")

# Or specify party
result = orchestrator.execute("Design new feature", party_name="new-feature")
```

### Method 2: With HTTP API

The profiles serve as documentation and reference for constructing system prompts.

When using the HTTP API, you can manually incorporate the profile content into your prompts:

```bash
# Get profile content
cat agents/architect.md

# Use in prompt
curl -X POST http://localhost:4096/session/{id}/message \
  -H "Content-Type: application/json" \
  -d '{
    "model": {
      "providerID": "opencode",
      "modelID": "big-pickle"
    },
    "parts": [{
      "type": "text",
      "text": "You are the Architect Agent... [content from architect.md]\n\nNow design: ..."
    }]
  }'
```

## Profile Structure

Each profile file contains:

1. **Purpose** - What the agent does
2. **Core Characteristics** - Key traits and expertise
3. **Key Behaviors** - How the agent operates
4. **System Prompt** - Instructions for the LLM
5. **Response Format** - How to structure responses
6. **Interaction Examples** - Real usage examples
7. **Collaboration** - How agents work together
8. **Performance Indicators** - Success metrics
9. **Tools & Capabilities** - What the agent can do
10. **Limitations** - When to use other agents

## Integration with OpenCode Server

These profiles are automatically available to:

1. **BaseAgent Classes** - `agents/base_agent.py`
   - ResearcherAgent, ArchitectAgent, SkepticAgent, CreativeAgent

2. **OpenCode Client** - `agents/opencode_client.py`
   - Supports `agent` parameter in HTTP calls

3. **Orchestrator** - `src/orchestrator.py`
   - Routes to appropriate agents based on party configuration
   - Uses profiles to guide agent behavior

## Creating New Profiles

To create a new agent profile:

1. Copy an existing profile as template
2. Update: purpose, characteristics, behaviors
3. Write clear system prompt
4. Define response format
5. Add examples and limitations
6. Place in this directory

Example:
```bash
cp agents/researcher.md agents/devops.md
nano agents/devops.md
```

## Party Composition

Profiles are used in pre-configured agent teams:

- **code-review**: skeptic → architect
- **new-feature**: researcher → architect → creative → skeptic
- **bug-hunt**: researcher ↔ skeptic (iterative)
- **deep-dive**: researcher + creative (parallel)
- **adr**: researcher → architect → skeptic → creative
- **brainstorm**: creative → researcher → architect (iterative)
- **security-review**: skeptic + researcher (parallel)
- **pre-launch**: skeptic → architect → researcher

## Testing Profiles

### Test Individual Agent
```bash
cd /home/bamer/.opencode

python3 << 'EOF'
from agents.base_agent import ArchitectAgent

agent = ArchitectAgent()
print(f"Testing: {agent}")

result = agent.call("Design a REST API for a todo app")
print(result[:200])
EOF
```

### Test with Orchestrator
```bash
python3 emergent-learning/src/orchestrator.py
```

### Test with HTTP API
```bash
# Create session
curl -X POST http://localhost:4096/session \
  -H "Content-Type: application/json" \
  -d '{"title": "test"}'

# Use agent profile in prompt
curl -X POST http://localhost:4096/session/ses_xxx/message \
  -H "Content-Type: application/json" \
  -d '{
    "model": {"providerID": "opencode", "modelID": "big-pickle"},
    "parts": [{
      "type": "text",
      "text": "You are a creative ideation specialist. Generate 5 ideas for..."
    }]
  }'
```

## Best Practices

1. **Use right agent for task** - Match agent specialty to task type
2. **Leverage profiles** - Reference profile system prompts in custom implementations
3. **Combine agents** - Use orchestrator for complex multi-agent tasks
4. **Iterate** - Refine agent profiles based on results
5. **Document** - Keep profiles updated with learnings

## Documentation

- **INDEX.md** - Complete agent index and reference
- **AGENT_USAGE_EXAMPLES.md** - 30+ usage examples
- **AGENT_PROFILES_SETUP.md** - Setup and integration guide
- **OPENCODE_HTTP_API_COMPLETE.md** - HTTP API documentation

## Quick Reference

| Agent | Best For | System Prompt |
|-------|----------|---------------|
| **Researcher** | Research, investigation | See researcher.md |
| **Architect** | Design, architecture | See architect.md |
| **Skeptic** | Review, quality | See skeptic.md |
| **Creative** | Ideas, brainstorm | See creative.md |
| **CEO** | Strategy, decisions | See ceo.md |
| **Learning-Extractor** | Knowledge, learning | See learning-extractor.md |

## Status

✅ **Production Ready**
- 6 agent profiles created
- Integrated with HTTP API
- Compatible with orchestrator
- Full documentation

---

Last Updated: 2026-01-29
Version: 1.0
