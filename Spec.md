# OPC-ELF — Simple Technical Specification

## 1. Purpose

OPC-ELF is a lightweight automation process that adapts the
**Emergent-Learning-Framework_ELF** plugin from **Claude Code** to **OpenCode**.

The objective is to automate a small set of repetitive and error‑prone manual steps,
while keeping the workflow simple, transparent, and close to the original upstream
project.

This project intentionally avoids over‑engineering: most of the framework is already
compatible between Claude and OpenCode.

---

## 2. Scope

OPC-ELF automates the following tasks:

1. Update the upstream ELF repository
2. Rename Claude-specific paths and files to OpenCode equivalents
3. Convert Claude Code hooks to OpenCode hooks
4. Secure SQLite database migrations with backups
5. Automate git check-in / check-out
6. Run lightweight validation checks

---

## 3. Directory Structure

```
opc-elf/
├── Emergent-Learning-Framework_ELF/
├── scripts/
│   └── update.sh
├── backups/
│   └── YYYY-MM-DD/
└── Spec.md
```

---

## 4. Update Workflow

The entire update process is executed via a single command:

```bash
./scripts/update.sh
```

Internally, the script performs the following steps in order.

---

## 5. Functional Specification

### 5.1 Repository Update

- Run `git pull` inside `Emergent-Learning-Framework_ELF`
- Abort if the working tree is dirty before update
- Continue only if changes are detected

---

### 5.2 Claude → OpenCode Path Conversion

Automatically rename and update:

- `.claude` → `.openclaude`
- All path references pointing to `.claude`
- Claude-specific directory names when applicable

Replacements are deterministic and diff-friendly.

---

### 5.3 Hook Conversion

Convert Claude Code hooks to OpenCode equivalents using a static mapping.

Examples:
- `claude_pre_run` → `opencode_pre_run`
- `claude_post_run` → `opencode_post_run`

No abstraction layer is introduced.

---

### 5.4 SQLite Database Migration

Database safety rules:

1. Always create a full backup before any change
2. Backups are stored under `backups/YYYY-MM-DD/`
3. Migrations are incremental and optional
4. On failure, the original database is restored

Manual intervention is always possible.

---

### 5.5 Git Automation

- Ensure clean working tree before conversion
- Automatically commit converted changes
- Use a standardized commit message:
  ```
  opc-elf: sync Claude → OpenCode
  ```

---

### 5.6 Validation

Lightweight validation only:

- Required directories exist
- `.openclaude` is present
- No remaining `.claude` references
- Optional dry-run execution

---

## 6. Non-Goals

OPC-ELF does NOT aim to:
- Redesign Emergent-Learning-Framework_ELF
- Introduce a plugin framework
- Add heavy testing or CI logic
- Abstract Claude/OpenCode differences beyond what is required

---

## 7. Design Philosophy

- Simple scripts over complex tooling
- Explicit steps over implicit magic
- Easy to debug
- Easy to extend later if needed
