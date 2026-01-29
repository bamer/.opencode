# Agent Usage Examples

All examples use OpenCode HTTP API on port 4096.

## Setup

```bash
# Terminal 1: Start OpenCode server
opencode serve --port 4096

# Verify
curl http://localhost:4096/global/health
```

## 1. Single Agent (Direct Call)

### Researcher Agent
```python
from agents.base_agent import ResearcherAgent

agent = ResearcherAgent(server_url="http://localhost:4096")

result = agent.call("Research the history of machine learning")
print(result)
```

### Architect Agent
```python
from agents.base_agent import ArchitectAgent

agent = ArchitectAgent()

result = agent.call("""
Design a microservices architecture for:
- 1M daily users
- Real-time data processing
- Multi-region deployment
""")
print(result)
```

### Skeptic Agent
```python
from agents.base_agent import SkepticAgent

agent = SkepticAgent()

result = agent.call("""
Review this code for vulnerabilities:

def authenticate(user, password):
    if user in database and database[user] == password:
        return True
    return False
""")
```

### Creative Agent
```python
from agents.base_agent import CreativeAgent

agent = CreativeAgent()

result = agent.call("Generate 5 creative ideas for improving user engagement")
```

## 2. Orchestrator (Multi-Agent Parties)

### Auto-Detect Party from Task
```python
from src.orchestrator import Orchestrator

orchestrator = Orchestrator()

# Task triggers automatic party selection
result = orchestrator.execute("Review this code for bugs and security issues")

# Result contains step-by-step analysis from all agents
print(f"Party: {result['party']}")
print(f"Workflow: {result['workflow']}")
print(f"Steps: {len(result['steps'])} agents ran")
```

### Specific Party: Code Review
```python
orchestrator = Orchestrator()

result = orchestrator.execute(
    task="Check if this API design follows REST best practices",
    party_name="code-review"
)

# Returns: Skeptic finds issues → Architect evaluates design
for step in result['steps']:
    print(f"{step['agent']}: {step['output'][:200]}...")
```

### Party: New Feature Design
```python
orchestrator = Orchestrator()

result = orchestrator.execute(
    task="Design a notification system for our platform",
    party_name="new-feature"
)

# Sequential: Researcher → Architect → Creative → Skeptic
# 1. Research finds existing patterns
# 2. Architect designs solution
# 3. Creative suggests alternatives
# 4. Skeptic identifies issues
```

### Party: Bug Investigation
```python
result = orchestrator.execute(
    task="Our users report the checkout page loads slowly",
    party_name="bug-hunt"
)

# Iterative workflow: Researcher and Skeptic refine understanding
# Round 1: Initial investigation
# Round 2: Refined hypothesis based on feedback
# Round 3: Final diagnosis
```

### Party: Deep Research
```python
result = orchestrator.execute(
    task="Research the latest advances in vector databases",
    party_name="deep-dive"
)

# Parallel: Researcher explores → Creative finds connections
# Get multiple perspectives on the topic
```

### Party: Architecture Decision Record (ADR)
```python
result = orchestrator.execute(
    task="Should we use Postgres or MongoDB for our data store?",
    party_name="adr"
)

# Sequential analysis of tradeoffs
# 1. Researcher gathers options
# 2. Architect evaluates
# 3. Skeptic challenges
# 4. Creative suggests improvements
```

### Party: Brainstorm
```python
result = orchestrator.execute(
    task="How can we differentiate our product from competitors?",
    party_name="brainstorm"
)

# Iterative ideation
# Creative leads → Researcher grounds ideas → Architect evaluates feasibility
```

### Party: Security Review
```python
result = orchestrator.execute(
    task="Audit our authentication system for security issues",
    party_name="security-review"
)

# Parallel: Skeptic finds vulnerabilities + Researcher checks attack vectors
```

### Party: Pre-Launch Check
```python
result = orchestrator.execute(
    task="We're ready to launch our new feature - final checks?",
    party_name="pre-launch"
)

# Sequential checklist
# 1. Skeptic finds blockers
# 2. Architect verifies architecture
# 3. Researcher checks documentation
```

## 3. Watcher (Continuous Monitoring)

```bash
# Run watcher in background
python3 emergent-learning/src/watcher/launcher.py &

# Or with custom interval
OPENCODE_WATCHER_INTERVAL=60 python3 emergent-learning/src/watcher/launcher.py

# Check logs
tail -f emergent-learning/.coordination/watcher-log.md
```

## 4. CEO Dashboard

### User Mode (Detailed Metrics)
```bash
python3 emergent-learning/agents/dashboard_sentinel_ceo.py --user
```

Output:
```
🤖 Dashboard Sentinel AI - 14:32:15
================================================================================
Status: System operational with 12 learnings identified...

🌐 Services:
  Frontend: 🟢
  Backend: 🟢
  Overall: 🟢

📚 Data Inventory:
  Learnings: 42
  Golden Rules: 5
  ...
```

### CEO Mode (Executive Briefing)
```bash
python3 emergent-learning/agents/dashboard_sentinel_ceo.py --ceo
```

Output:
```
👔 CEO Dashboard Briefing - 14:32:15
================================================================================
Strategic Assessment: STRONG - Good knowledge quality with improvement areas

📊 CEO Metrics:
  📈 Knowledge Assets: 200 items
  👑 Golden Rules: 8 constitutional principles
  🎯 Quality Score: 85.3%

🎯 Strategic Actions:
  ✓ Expand heuristic coverage to 500 items
  ✓ Implement feedback loop for quality improvement
```

## 5. Advanced: Custom Workflows

### Chain Multiple Agents
```python
from agents.base_agent import ResearcherAgent, ArchitectAgent

# Researcher first
researcher = ResearcherAgent()
research = researcher.call("What are microservices best practices?")

# Architect builds on research
architect = ArchitectAgent()
architecture = architect.call(f"Design based on: {research[:500]}")

print(f"Research: {research[:200]}...")
print(f"Design: {architecture[:200]}...")
```

### Parallel Perspectives
```python
from agents.base_agent import get_agent

agents = ["researcher", "architect", "skeptic", "creative"]
perspectives = {}

for agent_type in agents:
    agent = get_agent(agent_type)
    perspectives[agent_type] = agent.call("Should we use microservices?")

# Consolidate
print("All perspectives:")
for agent_type, perspective in perspectives.items():
    print(f"\n{agent_type}: {perspective[:100]}...")
```

### Conversation History
```python
from agents.base_agent import ResearcherAgent

agent = ResearcherAgent()

# First exchange
response1 = agent.call("What is machine learning?")

# Follow-up (agent remembers context)
response2 = agent.call("Can you give me a practical example?")

# View history
history = agent.get_history()
print(f"Conversation ({len(history)} messages):")
for msg in history:
    print(f"  {msg['role']}: {msg['content'][:100]}...")
```

## 6. Server Configuration

### Custom Server URL
```python
from agents.base_agent import ResearcherAgent

agent = ResearcherAgent(
    server_url="http://other-server:4096"
)
```

### Custom Model
```python
from agents.base_agent import ResearcherAgent

agent = ResearcherAgent(
    model="some-other-model"  # if available
)
```

### Timeout Configuration
```python
from agents.base_agent import ResearcherAgent

agent = ResearcherAgent(
    timeout=600  # 10 minutes for complex analysis
)
```

## 7. Error Handling

```python
from agents.base_agent import ResearcherAgent

agent = ResearcherAgent()

try:
    result = agent.call("Research topic")
    if result:
        print(f"Success: {result}")
    else:
        print("Agent returned empty response")
except Exception as e:
    print(f"Error: {e}")
    # Fallback logic
```

## 8. Parties Quick Reference

```python
from src.orchestrator import Orchestrator

orchestrator = Orchestrator()

# List all parties
for name, desc in orchestrator.router.list_parties().items():
    print(f"{name}: {desc}")

# Find party for task
party = orchestrator.router.find_party("debug this issue")
print(f"Detected: {party}")
```

## Environment Variables

```bash
# Server
OPENCODE_SERVER_URL=http://localhost:4096

# Watcher
OPENCODE_WATCHER_MODEL=opencode/big-pickle
OPENCODE_WATCHER_INTERVAL=30

# Python path
PYTHONPATH=/home/bamer/.opencode/emergent-learning:$PYTHONPATH
```

## Common Tasks

### Task: Code Review
```python
from src.orchestrator import Orchestrator

orchestrator = Orchestrator()
result = orchestrator.execute("Review my new API endpoint", party_name="code-review")
```

### Task: Debug Issue
```python
result = orchestrator.execute("Why is the database query slow?", party_name="bug-hunt")
```

### Task: Architecture Decision
```python
result = orchestrator.execute(
    "Monolith vs Microservices for our use case?",
    party_name="adr"
)
```

### Task: Research Topic
```python
result = orchestrator.execute("Latest in AI safety", party_name="deep-dive")
```

### Task: Generate Ideas
```python
result = orchestrator.execute(
    "How can we improve user retention?",
    party_name="brainstorm"
)
```

## Performance Tips

1. **Reuse agents**: Create agent once, call multiple times
2. **Batch tasks**: Run multiple tasks to one agent
3. **Use orchestrator**: Multi-agent better than sequential calls
4. **Check history**: Leverage conversation context
5. **Appropriate timeouts**: Complex tasks need more time

## Troubleshooting

**Agent not responding**:
```bash
# Check server
curl http://localhost:4096/global/health

# Check logs
python3 agents/base_agent.py 2>&1 | grep -i error
```

**Slow responses**:
```python
# Increase timeout
agent = ResearcherAgent(timeout=600)
```

**Module not found**:
```bash
export PYTHONPATH=/home/bamer/.opencode/emergent-learning:$PYTHONPATH
```

---

All examples use HTTP API on port 4096. Make sure OpenCode server is running first!
