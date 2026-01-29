#!/bin/bash
# Agent Profiles Demo
# Demonstrates using OpenCode agents with HTTP API and Python clients

set -euo pipefail

echo "🤖 OpenCode Agent Profiles Demo"
echo "================================"
echo ""

# Check server
echo "1️⃣  Checking OpenCode Server..."
if ! curl -s http://localhost:4096/global/health > /dev/null 2>&1; then
    echo "❌ OpenCode server not running"
    echo "   Start with: opencode serve --port 4096"
    exit 1
fi

HEALTH=$(curl -s http://localhost:4096/global/health)
echo "✅ Server responding: $HEALTH"
echo ""

# Demo 1: Researcher Agent
echo "2️⃣  Demo: Researcher Agent"
echo "   Task: Research machine learning applications"
python3 << 'EOF'
import sys
from pathlib import Path

sys.path.insert(0, str(Path("emergent-learning/agents")))

from base_agent import ResearcherAgent

researcher = ResearcherAgent()
print(f"   Agent: {researcher}")
print(f"   Status: Connected to {researcher.server_url}")
print("")
EOF

# Demo 2: Architect Agent
echo "3️⃣  Demo: Architect Agent"
echo "   Task: System design principles"
python3 << 'EOF'
import sys
from pathlib import Path

sys.path.insert(0, str(Path("emergent-learning/agents")))

from base_agent import ArchitectAgent

architect = ArchitectAgent()
print(f"   Agent: {architect}")
print(f"   Status: Connected to {architect.server_url}")
print("")
EOF

# Demo 3: Party Detection
echo "4️⃣  Demo: Orchestrator Party Detection"
python3 << 'EOF'
import sys
from pathlib import Path

sys.path.insert(0, str(Path("emergent-learning/src")))
sys.path.insert(0, str(Path("emergent-learning/agents")))

from orchestrator import Orchestrator

orchestrator = Orchestrator()

# Test various tasks
test_tasks = [
    ("Review this code for bugs", "code-review"),
    ("Design a new feature", "new-feature"),
    ("Investigate why this is slow", "bug-hunt"),
    ("Research the latest trends", "deep-dive"),
]

print("   Party Detection Results:")
for task, expected_party in test_tasks:
    detected = orchestrator.router.find_party(task)
    status = "✓" if detected == expected_party else "→"
    print(f"   {status} '{task}' → {detected}")

print("")
EOF

# Demo 4: Agent Profiles Directory
echo "5️⃣  Demo: Agent Profiles Available"
echo "   Agent profiles in ~/.opencode/agents/:"

cd /home/bamer/.opencode

for profile in agents/*.md; do
    name=$(basename "$profile" .md)
    [ "$name" != "INDEX" ] && [ "$name" != "README" ] && {
        lines=$(wc -l < "$profile")
        echo "   ✓ $name.md ($lines lines)"
    }
done

echo ""

# Demo 5: HTTP API Usage
echo "6️⃣  Demo: HTTP API with Agents"
echo "   Creating session and sending message with agent parameter..."

# Create session
SESSION_JSON=$(curl -s -X POST http://localhost:4096/session \
  -H "Content-Type: application/json" \
  -d '{"title": "demo"}')

SESSION_ID=$(echo "$SESSION_JSON" | python3 -c "import sys, json; print(json.load(sys.stdin).get('id', ''))")

if [ -n "$SESSION_ID" ]; then
    echo "   Session created: $SESSION_ID"
    
    # Send message (can specify agent parameter)
    # Note: agent parameter may not be available in OpenCode server yet
    # But the structure is ready for when it is
    
    # Cleanup
    curl -s -X DELETE http://localhost:4096/session/$SESSION_ID > /dev/null
    echo "   ✓ Session cleaned up"
else
    echo "   ⚠️  Could not create session"
fi

echo ""

# Summary
echo "==============================="
echo "✅ Demo Complete!"
echo ""
echo "Available Agents:"
echo "  • Researcher - Investigation & Analysis"
echo "  • Architect - Architecture & Design"
echo "  • Skeptic - Quality & Risk Assessment"
echo "  • Creative - Innovation & Ideation"
echo "  • CEO - Strategic Leadership"
echo "  • Learning-Extractor - Knowledge & Learning"
echo ""
echo "Agent Profiles Location: ~/.opencode/agents/"
echo "Documentation: agents/INDEX.md"
echo ""
echo "Next Steps:"
echo "  1. python3 emergent-learning/agents/base_agent.py"
echo "  2. python3 emergent-learning/src/orchestrator.py"
echo "  3. Review agents/INDEX.md for full reference"
echo ""
