# OpenCode Watcher Update

## Summary

Le watcher a été mis à jour pour utiliser **OpenCode** avec le modèle **`opencode/big-pickle`** au lieu de Claude.

## Changes Appliqués

### 1. **elf_paths.py** (Nouveau)
Module de résolution de chemins pour ELF. Fournit des fonctions cohérentes pour trouver les répertoires ELF.

```python
get_base_path() -> Path  # Résout le chemin ELF base
get_scripts_path() -> Path  # Chemin des scripts OpenCode
get_opencode_dir() -> Path  # Répertoire OpenCode root
```

### 2. **launcher.py** (Remplacé)
Ancien: Appelait endpoint OpenAI local (`localhost:12134`)
Nouveau: Appelle `opencode` CLI directement avec `opencode/big-pickle`

**Clés environnementales:**
- `OPENCODE_WATCHER_MODEL` - Modèle à utiliser (défaut: `opencode/big-pickle`)
- `OPENCODE_WATCHER_INTERVAL` - Intervalle en secondes (défaut: 30)
- `ELF_BASE_PATH` - Chemin de base ELF

**Caractéristiques:**
- Tier 1: Watcher (détecte les problèmes)
- Tier 2: Handler (prend les décisions si escalade nécessaire)
- Logs automatiques dans `.coordination/watcher-log.md`

### 3. **start-watcher.sh** (Remplacé)
Ancien: Vérifiait `ANTHROPIC_API_KEY`
Nouveau: Vérifie que `opencode` CLI est installé

**Usage:**
```bash
./src/watcher/start-watcher.sh          # Mode interactif
./src/watcher/start-watcher.sh --daemon # Mode daemon
```

Le script exporte automatiquement:
```bash
OPENCODE_WATCHER_MODEL=opencode/big-pickle
```

### 4. **Patches Mis à Jour**
- `scripts/patches/launcher-openai.patch` - Convertit le launcher
- `scripts/patches/start-watcher-openai.patch` - Convertit le script de démarrage

## Architecture du Système

```
User Interaction
      ↓
Hook (détecte activité)
      ↓
Spawn Watcher (Tier 1)
      ↓
opencode/big-pickle (analyse l'état)
      ↓
Escalade détectée? → OUI → Handler (Tier 2)
                           ↓
                    opencode/big-pickle (décision)
                           ↓
                        Action: RESTART|ABANDON|ESCALATE
      ↓
Logs in .coordination/watcher-log.md
      ↓
Exit & Wait for Next User Interaction
```

## Configuration Requise

### 1. OpenCode CLI
```bash
npm install -g opencode
# ou
npm install -D opencode  # dans le projet
```

### 2. Python 3.8+
```bash
python3 --version
```

### 3. ELF Directory
Doit exister à: `~/.opencode/emergent-learning`

## Test de la Configuration

```bash
bash /home/bamer/.opencode/test-watcher.sh
```

## Lancer le Watcher

```bash
cd ~/.opencode/emergent-learning

# Mode interactif (Ctrl+C pour arrêter)
./src/watcher/start-watcher.sh

# Mode daemon (tourne en arrière-plan)
./src/watcher/start-watcher.sh --daemon

# Single pass (une seule itération)
./src/watcher/start-watcher.sh --once
```

## Variables d'Environnement

| Variable | Défaut | Description |
|----------|--------|-------------|
| `OPENCODE_WATCHER_MODEL` | `opencode/big-pickle` | Modèle OpenCode à utiliser |
| `OPENCODE_WATCHER_INTERVAL` | `30` | Intervalle entre passes (secondes) |
| `ELF_BASE_PATH` | `~/.opencode/emergent-learning` | Chemin de base ELF |
| `OPENCODE_DIR` | `~/.opencode` | Répertoire OpenCode |

### Exemple:
```bash
export OPENCODE_WATCHER_MODEL=opencode/big-pickle
export OPENCODE_WATCHER_INTERVAL=60
./src/watcher/start-watcher.sh --daemon
```

## Arrêter le Watcher

### Mode daemon:
```bash
# Créer le fichier stop
python3 -c "from pathlib import Path; Path('~/.opencode/emergent-learning/.coordination/watcher-stop').expanduser().touch()"

# Ou kill par PID
kill $PID
```

### Mode interactif:
```bash
Ctrl+C
```

## Logs & Monitoring

Logs du watcher:
```bash
cat ~/.opencode/emergent-learning/.coordination/watcher-log.md
```

Statut:
```bash
cd ~/.opencode/emergent-learning
python3 -c "import sys; sys.path.insert(0, '.'); from watcher.watcher_loop import check_status; check_status()"
```

## Intégration avec Hook

Le hook OpenCode (dans `ELF_superpowers.js`) détecte l'activité utilisateur et spawn automatiquement une passe de watcher.

Configuration dans `ELF_superpowers.js`:
```javascript
const WATCHER_LAUNCHER = path.join(ELF_BASE_PATH, 'watcher', 'run_with_bigpickle.py');
const WATCHER_MODEL = 'opencode/big-pickle';
```

## Dépannage

### `opencode CLI not found`
```bash
npm install -g opencode
```

### `elf_paths module not found`
Assurez-vous que `elf_paths.py` est dans `~/.opencode/emergent-learning/`

### Watcher ne démarre pas
```bash
# Vérifier les logs
bash /home/bamer/.opencode/test-watcher.sh

# Générer une prompt manuelle
cd ~/.opencode/emergent-learning
python3 -c "import sys; sys.path.insert(0, '.'); from watcher.watcher_loop import output_watcher_prompt; output_watcher_prompt()"
```

### Modèle mal configuré
```bash
# Vérifier la variable
echo $OPENCODE_WATCHER_MODEL

# Réinitialiser au défaut
export OPENCODE_WATCHER_MODEL=opencode/big-pickle
./src/watcher/start-watcher.sh
```

## Fichiers Modifiés/Créés

```
emergent-learning/
├── elf_paths.py (NOUVEAU)
├── src/watcher/
│   ├── launcher.py (REMPLACÉ)
│   └── start-watcher.sh (REMPLACÉ)
└── watcher/
    ├── watcher_loop.py (EXISTANT, inchangé)
    ├── run_with_bigpickle.py (EXISTANT, inchangé)
    └── auto_spawn.py (EXISTANT, inchangé)

scripts/
├── patches/
│   ├── launcher-openai.patch (MIS À JOUR)
│   └── start-watcher-openai.patch (MIS À JOUR)
└── opc-elf-sync.sh (EXISTANT, applique les patches)

Test:
└── test-watcher.sh (NOUVEAU)
```

## Notes

- Le système fonctionne maintenant **entièrement avec OpenCode** (pas de dépendance Claude)
- Le modèle `opencode/big-pickle` est utilisé pour toutes les passes de watcher
- Logs détaillés dans `.coordination/watcher-log.md`
- Système de coordin intermédiaire via `blackboard.json`
- Support du daemon pour exécution persistante

## Synchronisation avec ELF Upstream

Pour réappliquer ces changements après une mise à jour ELF:
```bash
bash scripts/opc-elf-sync.sh
```

Cela va:
1. Fetch les derniers changements d'upstream
2. Réinitialiser à la branche upstream
3. Appliquer les patches OpenCode
4. Installer le launcher corrigé
5. Valider la cleanup Claude
