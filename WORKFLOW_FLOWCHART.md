# OpenCode-ELF Workflow Flowchart

This document provides a visual representation of the OpenCode-ELF workflow using ASCII diagrams and flowcharts.

## 📈 Simplified Main Workflow Flowchart

```mermaid
flowchart TD
    A[Start: opencode_elf_install.sh] --> B[Backup Files & Databases]
    B --> C[Fetch Latest ELF]
    C --> D[Apply Claude→OpenCode Cleanup]
    D --> E[Run ELF Installer]
    E --> F[Install OpenCode Plugin]
    F --> G[Validate Installation]
    G --> H[Complete]
```

## 🔄 Simplified Process Flow

```mermaid
sequenceDiagram
    participant User
    participant Installer
    participant Git
    participant PluginSystem

    User->>Installer: bash opencode_elf_install.sh
    Installer->>Installer: Backup custom files & databases
    Installer->>Git: Fetch latest from origin
    Git-->>Installer: Latest changes
    Installer->>Installer: Apply Claude→OpenCode cleanup
    Installer->>Installer: Run ELF installer
    Installer->>PluginSystem: Install OpenCode plugin to plugins/
    PluginSystem-->>Installer: Plugin installed
    Installer->>Installer: Validate installation
    Installer-->>User: Complete
```

## 🗺️ Simplified Decision Tree

```mermaid
graph TD
    A[Start Installation] --> B{Backup Successful?}
    B -->|Yes| C[Continue]
    B -->|No| D[Show Error & Exit]

    C --> E{Fetch Latest ELF Successful?}
    E -->|Yes| F[Continue]
    E -->|No| G[Show Error & Exit]

    F --> H{Cleanup Successful?}
    H -->|Yes| I[Continue]
    H -->|No| J[Show Warning & Continue]

    I --> K{Installation Successful?}
    K -->|Yes| L[Complete]
    K -->|No| M[Show Error & Exit]
```

## 📊 Simplified Component Interaction

```mermaid
classDiagram
    class Installer {
        +backup_files_databases()
        +fetch_latest_elf()
        +apply_cleanup()
        +run_installer()
        +install_plugin()
        +validate_installation()
    }

    class GitSystem {
        +fetch()
        +reset()
    }

    class PluginSystem {
        +install()
        +verify()
    }

    Installer --> GitSystem : Uses
    Installer --> PluginSystem : Uses
```

## 🎯 Simplified Workflow States

```mermaid
stateDiagram-v2
    [*] --> Backup
    Backup --> Fetch
    Fetch --> Cleanup
    Cleanup --> Install
    Install --> Plugin
    Plugin --> Validate
    Validate --> [*]
```

## 🔧 Simplified Error Handling

```mermaid
flowchart TD
    A[Error Detected] --> B{Critical Error?}
    B -->|Yes| C[Stop & Show Error]
    B -->|No| D[Log Warning & Continue]
```

## 📚 Simplified Usage Example

### Standard Installation Flow
```bash
# 1. Start installation
bash opencode_elf_install.sh

# 2. Backup phase
#    - Backs up custom files & databases

# 3. Fetch phase
#    - Gets latest ELF from upstream

# 4. Cleanup phase
#    - Applies Claude→OpenCode cleanup

# 5. Install phase
#    - Runs ELF installer

# 6. Plugin phase
#    - Installs OpenCode plugin to plugins/

# 7. Validation phase
#    - Verifies installation
```

## 🎓 Key Takeaways

1. **Simplified Flow**: 6 clear steps from start to finish
2. **Error Resilience**: Non-critical errors don't stop the process
3. **Backup Safety**: Files and databases backed up together
4. **Clean Structure**: Plugin installed to correct 'plugins' directory

This simplified visual guide complements the updated `WORKFLOW_GUIDE.md` with clear, focused diagrams.
