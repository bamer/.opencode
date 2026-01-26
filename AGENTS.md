# AGENTS.md

## Scope
- This repo wraps upstream ELF with OpenCode integration; update flow in `scripts/opc-elf-sync.sh`.

## Commands
- Sync (update + backup + install + plugin): `./scripts/opc-elf-sync.sh`
- Preserve customizations: `./scripts/preserve-customizations.sh {backup|restore|patch}`
- Upstream install (from ELF repo): `cd Emergent-Learning-Framework_ELF && ./install.sh`
- Tests (upstream): `cd Emergent-Learning-Framework_ELF && make test`
- Lint (upstream): `cd Emergent-Learning-Framework_ELF && make lint`

## GitHub-Style Patches
- Patch directory: `scripts/patches/` contains GitHub-style patch files
- `launcher-openaai.patch`: Adds OpenAI-compatible launcher for watcher
- `opencode-plugin.patch`: Adds OpenCode plugin with ELF hooks

## Style
- Shell scripts: bash strict mode (`set -euo pipefail`), keep paths configurable via env vars.
- JS plugin: avoid hardcoded home paths; derive from `OPENCODE_DIR`/`ELF_BASE_PATH`.
