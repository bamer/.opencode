/**
 * Swarm Task Tool for OpenCode.ai
 * 
 * Execute task using OpenCode agents (Architect, Researcher, Skeptic, Creative, Learning Extractor)
 * NON-BLOCKING: Returns immediately, runs async in background
 */

import { tool } from "@opencode-ai/plugin";
import { runSwarm } from "../emergent-learning/agentsOpencode/swarm-orchestrator.js";

export default tool({
  description: `Execute a task using a swarm of AI agents with different perspectives.

AGENTS:
- Architect: System design, structure, and big picture
- Researcher: Deep investigation and evidence gathering
- Skeptic: Critical analysis and risk identification
- Creative: Innovation and novel ideas
- Learning Extractor: Meta-learning and knowledge synthesis

MODES:
- analysis: Researcher → Architect (investigate and structure)
- design: Architect → Creative → Skeptic (design, innovate, critique)
- implementation: Architect → Researcher → Skeptic (build with research and risk review)
- learning: Learning Extractor → Researcher → Architect (extract insights and structure)
- all: Run all agents in sequence`,
  
  args: {
    task: tool.schema
      .string()
      .min(10, "Task description must be at least 10 characters")
      .describe("The task or question to process. Be specific about what you need. Example: 'Design a caching strategy for our API' or 'Find risks in this authentication approach'"),
    
    mode: tool.schema
      .enum(["analysis", "design", "implementation", "learning", "all"])
      .describe(`Choose the execution mode:
- analysis: For researching and understanding problems
- design: For creating new solutions and architectures  
- implementation: For building and validating solutions
- learning: For extracting insights and building knowledge
- all: Use all agents for comprehensive feedback`),
    
    context: tool.schema
      .string()
      .optional()
      .describe("Additional context about your project, domain, or constraints. Example: 'We use Node.js, PostgreSQL, and have 1000 concurrent users'")
  },

  async execute(args) {
    const mode = args.mode || 'all';
    const context = args.context || '';

    // Return immediately - fire and forget
    let response = `🚀 SWARM EXECUTION STARTED\n\n`;
    response += `Task: ${args.task}\n`;
    response += `Mode: ${mode}\n`;
    response += `Status: Running agents in background...\n\n`;
    response += `The swarm is processing your request. Results will be saved to the ELF coordination directory.`;

    // Run swarm async in background (don't await)
    runSwarm(args.task, context, mode)
      .then(result => {
        console.log(`[SWARM] Execution complete for task: ${args.task}`);
      })
      .catch(error => {
        console.error(`[SWARM] Execution failed: ${error.message}`);
      });

    return response;
  }
});