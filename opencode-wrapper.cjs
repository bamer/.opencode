#!/usr/bin/env node

const { spawnSync } = require("child_process");

// Run the opencode binary via node with the correct flags
const result = spawnSync("node", [
  "/home/bamer/Downloads/opencode-1.1.34/packages/opencode/bin/opencode",
  ...process.argv.slice(2)
], {
  stdio: "inherit"
});

process.exit(result.status || 0);
