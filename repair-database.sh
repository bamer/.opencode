#!/usr/bin/env bash
# Convenience wrapper for database repair

cd "$(dirname "$0")"
OPENCODE_DIR="${OPENCODE_DIR:-$HOME/.opencode}"
ELF_BASE_PATH="${ELF_BASE_PATH:-$OPENCODE_DIR/emergent-learning}"

export OPENCODE_DIR
export ELF_BASE_PATH

bash ./scripts/fix-database.sh "$@"
