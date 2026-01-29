/**
 * Query Tool for OpenCode.ai
 * 
 * Non-blocking wrapper for ELF query system
 * Returns immediately - execution happens in background
 */

import { tool } from "@opencode-ai/plugin";
import path from "path";
import os from "os";

const HOME_DIR = os.homedir();
const QUERY_SCRIPT = path.join(HOME_DIR, ".opencode", "emergent-learning", "query", "query.py");

export default tool({
  description: "Query ELF building (context, golden rules, learnings, etc.)",
  
  args: {
    type: tool.schema
      .enum(["context", "domain", "learning", "decision", "rule"])
      .describe("Query type: context, domain, learning, decision, or rule"),
    
    domain: tool.schema
      .string()
      .optional()
      .describe("Domain filter (optional)"),
    
    limit: tool.schema
      .string()
      .optional()
      .describe("Limit results (optional, default: 10)")
  },

  async execute(args) {
    const queryType = args.type || 'context';
    
    // Return immediately - run in background
    let response = `🚀 QUERY STARTED\n\n`;
    response += `Type: ${queryType}\n`;
    response += `Status: Executing in background...\n\n`;
    response += `Results will be logged to the ELF system.`;

    // Execute the query script based on type
    if (queryType === 'context') {
      Bun.$`python3 ${QUERY_SCRIPT} --context`
        .then(() => console.log(`[QUERY] context complete`))
        .catch(error => console.error(`[QUERY] context failed: ${error.message}`));
    } else if (queryType === 'domain' && args.domain) {
      const limit = args.limit ? `--limit ${args.limit}` : '';
      Bun.$`python3 ${QUERY_SCRIPT} --domain ${args.domain} ${limit}`
        .then(() => console.log(`[QUERY] domain complete`))
        .catch(error => console.error(`[QUERY] domain failed: ${error.message}`));
    } else if (queryType === 'learning') {
      const limit = args.limit ? `--limit ${args.limit}` : '';
      Bun.$`python3 ${QUERY_SCRIPT} --learning ${limit}`
        .then(() => console.log(`[QUERY] learning complete`))
        .catch(error => console.error(`[QUERY] learning failed: ${error.message}`));
    } else if (queryType === 'decision') {
      const limit = args.limit ? `--limit ${args.limit}` : '';
      Bun.$`python3 ${QUERY_SCRIPT} --decision ${limit}`
        .then(() => console.log(`[QUERY] decision complete`))
        .catch(error => console.error(`[QUERY] decision failed: ${error.message}`));
    } else if (queryType === 'rule') {
      const limit = args.limit ? `--limit ${args.limit}` : '';
      Bun.$`python3 ${QUERY_SCRIPT} --rule ${limit}`
        .then(() => console.log(`[QUERY] rule complete`))
        .catch(error => console.error(`[QUERY] rule failed: ${error.message}`));
    }

    return response;
  }
});