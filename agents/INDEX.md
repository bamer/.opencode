# OpenCode Agent Profiles - Index

All agent profiles are stored in `.opencode/agents/` and are available to the OpenCode server on port 4096.

## Available Agents

### 1. Researcher Agent
**File**: `researcher.md`
**Role**: Investigation & Analysis
**Archetype**: The Analyst

Expert investigator specializing in:
- Deep research and analysis
- Pattern recognition
- Information synthesis
- Thorough investigation

**Best for**:
- Researching topics
- Investigating issues
- Understanding complex domains
- Finding sources and evidence

---

### 2. Architect Agent
**File**: `architect.md`
**Role**: Architecture & Design
**Archetype**: The Visionary Engineer

Strategic system designer specializing in:
- Scalable system architecture
- Technical strategy
- Design patterns
- Architectural evaluation

**Best for**:
- Designing systems
- Evaluating design alternatives
- Planning scalability
- Making architectural decisions

---

### 3. Skeptic Agent
**File**: `skeptic.md`
**Role**: Quality & Risk Assessment
**Archetype**: The Quality Guardian

Critical reviewer specializing in:
- Risk identification
- Edge case discovery
- Quality assurance
- Constructive criticism

**Best for**:
- Code/design review
- Risk assessment
- Finding edge cases
- Quality improvement

---

### 4. Creative Agent
**File**: `creative.md`
**Role**: Innovation & Ideation
**Archetype**: The Visionary Innovator

Innovative thinker specializing in:
- Idea generation
- Creative problem-solving
- Lateral thinking
- Unconventional approaches

**Best for**:
- Brainstorming
- Finding alternatives
- Generating ideas
- Challenging assumptions

---

### 5. CEO Agent
**File**: `ceo.md`
**Role**: Strategic Leadership & Business Direction
**Archetype**: The Visionary Leader

Executive strategist specializing in:
- Strategic planning
- Business intelligence
- Leadership guidance
- Organizational strategy

**Best for**:
- Strategic planning
- Executive decisions
- Business analysis
- Strategic direction

---

### 6. Learning Extractor Agent
**File**: `learning-extractor.md`
**Role**: Knowledge & Continuous Improvement
**Archetype**: The Knowledge Architect

Knowledge synthesis specialist focusing on:
- Learning extraction
- Pattern identification
- Knowledge organization
- Continuous improvement

**Best for**:
- Extracting learnings
- Identifying patterns
- Building organizational knowledge
- Improving processes

---

## Agent Composition (Parties)

### Code Review Party
- **Lead**: Skeptic
- **Agents**: Skeptic → Architect
- **Workflow**: Sequential
- **Purpose**: Review code quality and design

### New Feature Party
- **Lead**: Architect
- **Agents**: Researcher → Architect → Creative → Skeptic
- **Workflow**: Sequential
- **Purpose**: Design and implement features

### Bug Hunt Party
- **Lead**: Researcher
- **Agents**: Researcher ↔ Skeptic
- **Workflow**: Iterative
- **Purpose**: Investigate and fix bugs

### Deep Dive Party
- **Lead**: Researcher
- **Agents**: Researcher, Creative (parallel)
- **Workflow**: Parallel
- **Purpose**: Thorough research on topics

### Architecture Decision Record
- **Lead**: Architect
- **Agents**: Researcher → Architect → Skeptic → Creative
- **Workflow**: Sequential
- **Purpose**: Make and document decisions

### Brainstorm Party
- **Lead**: Creative
- **Agents**: Creative → Researcher → Architect
- **Workflow**: Iterative
- **Purpose**: Generate creative solutions

### Security Review Party
- **Lead**: Skeptic
- **Agents**: Skeptic, Researcher (parallel)
- **Workflow**: Parallel
- **Purpose**: Audit for security

### Pre-Launch Party
- **Lead**: Skeptic
- **Agents**: Skeptic → Architect → Researcher
- **Workflow**: Sequential
- **Purpose**: Final checks before deployment

---

## Using Agents with OpenCode Server

### Start Server
```bash
opencode serve --port 4096
```

### Access Agent via HTTP API
```bash
# List available agents
curl http://localhost:4096/agent

# Use agent in message (agent parameter)
curl -X POST http://localhost:4096/session/ses_xxx/message \
  -H "Content-Type: application/json" \
  -d '{
    "agent": "researcher",
    "model": {
      "provider": "opencode",
      "providerID": "opencode",
      "modelID": "big-pickle"
    },
    "parts": [{
      "type": "text",
      "text": "Research machine learning"
    }]
  }'
```

### Use with Python Client
```python
from agents.base_agent import get_agent

# Create agent
agent = get_agent("researcher")

# Call with task
result = agent.call("Research microservices patterns")
```

### Use with Orchestrator
```python
from src.orchestrator import Orchestrator

orchestrator = Orchestrator()

# Auto-detect party
result = orchestrator.execute("Review this code for bugs")

# Or specify agent directly
result = orchestrator.execute(
    "Design a system",
    party_name="new-feature"
)
```

---

## Profile Structure

Each agent profile contains:

1. **Purpose** - Core mission
2. **Characteristics** - Key traits and strengths
3. **Behaviors** - How the agent operates
4. **System Prompt** - Instructions for the model
5. **Response Format** - How to structure responses
6. **Interaction Examples** - Usage scenarios
7. **Collaboration** - How agents work together
8. **Performance Indicators** - Success metrics
9. **Tools & Capabilities** - What the agent can do
10. **Limitations** - When to use other agents

---

## Extending Agents

To create a new agent profile:

1. Create file: `agents/agent-name.md`
2. Follow the profile structure above
3. Include clear system prompt
4. Document expected behaviors
5. Add collaboration examples
6. Restart OpenCode server to pick up changes

Example:
```bash
# Create new agent
touch agents/devops.md

# Edit with profile structure
nano agents/devops.md

# Restart server (it auto-discovers agents)
# opencode serve --port 4096
```

---

## Discovery & Registration

OpenCode automatically discovers agents in the `.opencode/agents/` directory.

### To list available agents:
```bash
curl http://localhost:4096/agent
```

### Response format:
```json
[
  {
    "id": "researcher",
    "name": "Researcher",
    "description": "Expert investigator...",
    "role": "investigation"
  },
  // ... more agents
]
```

---

## Best Practices

1. **Use right agent for task**: Match agent specialty to task
2. **Leverage parties**: Use orchestrator for complex tasks
3. **Combine perspectives**: Use parallel workflow for insights
4. **Sequential for refinement**: Chain agents when building on work
5. **Leverage history**: Use conversation context for depth
6. **Extract learnings**: Always capture what was learned

---

## Quick Reference

| Task | Agent | Party |
|------|-------|-------|
| Review code | Skeptic | code-review |
| Design system | Architect | new-feature / adr |
| Find bugs | Researcher | bug-hunt |
| Generate ideas | Creative | brainstorm |
| Research topic | Researcher | deep-dive |
| Security audit | Skeptic | security-review |
| Strategic decision | CEO | adr |
| Extract learnings | Learning-Extractor | (standalone) |

---

## Documentation

- **Agent Profiles**: `.opencode/agents/*.md`
- **Usage Examples**: `AGENT_USAGE_EXAMPLES.md`
- **Orchestrator Guide**: `ORCHESTRATOR_GUIDE.md`
- **API Reference**: `OPENCODE_HTTP_API_COMPLETE.md`

---

Last Updated: 2026-01-29
Version: 1.0
Status: Production Ready
