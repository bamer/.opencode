/**
 * Check-in Tool for OpenCode.ai
 * 
 * Manually run ELF check-in script
 * NON-BLOCKING: Returns immediately, runs async in background
 */

import { tool } from "@opencode-ai/plugin";
import path from "path";
import os from "os";

const HOME_DIR = os.homedir();
const ELF_DIR = path.join(HOME_DIR, ".opencode", "emergent-learning");
const SCRIPTS_DIR = path.join(ELF_DIR, "scripts");


export default tool({

  description: "run ELF check-in script",

  checkin_script: path.join(SCRIPTS_DIR, "checkin.sh"),

  async execute(args, context) {
    // Access context information
    Bun.$` ${checkin_script} `
  },

  
});
