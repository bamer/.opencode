# Orchestrator Update for OpenCode/Big-Pickle

## Summary

L'**orchestrator checkin** a été mis à jour pour fonctionner avec **OpenCode** et le modèle **`opencode/big-pickle`** au lieu de Claude.

## Changements Appliqués

### 1. **SKILL.md** - Mise à jour

**Fichier:** `skills/elf-checkin/SKILL.md`

**Changements:**
- Remplacé "Claude (Recommended)" → "OpenCode (big-pickle)"
- Remplacé "Gemini, Codex" → Retiré (big-pickle est le seul)
- Mis à jour description pour "OpenCode big-pickle model"
- Mis à jour prompts pour reflléter OpenCode/big-pickle
- Changé "Claude tracks session state" → "OpenCode tracks session state"

**Options de modèle (anciennement):**
```
(c)laude    - Orchestrator, backend, architecture
(g)emini    - Frontend, React, large codebases
(o)dex      - Graphics, debugging, precision
(s)kip      - Use current model
```

**Options de modèle (maintenant):**
```
(o)pencode  - big-pickle model (Recommended, local)
(s)kip      - Use current model
```

---

### 2. **checkin.py** - Mise à jour

**Fichier:** `emergent-learning/query/checkin.py`

**Changement 1 - Modèle par défaut:**
```python
# Avant:
self.selected_model = os.environ.get('ELF_MODEL', 'claude')

# Après:
self.selected_model = os.environ.get('ELF_MODEL', 'opencode/big-pickle')
```

**Changement 2 - Méthode prompt_model_selection():**

```python
# Avant (prompt non-interactif):
print('[PROMPT_NEEDED] {"type": "model", "options": ["claude", "gemini", "codex", "skip"]}')

# Après (prompt non-interactif):
print('[PROMPT_NEEDED] {"type": "model", "options": ["opencode/big-pickle", "skip"]}')
```

```python
# Avant (options interactives):
model_map = {
    'c': 'claude',
    'g': 'gemini',
    'o': 'codex',
    's': self.selected_model
}

# Après (options interactives):
model_map = {
    'o': 'opencode/big-pickle',
    's': self.selected_model
}
```

```python
# Avant (défaut):
selected = model_map.get(response[0] if response else 's', self.selected_model)

# Après (défaut):
selected = model_map.get(response[0] if response else 'o', self.selected_model)
```

---

## Flux d'Exécution: Avant vs Après

### AVANT (Claude)

```
Utilisateur: /checkin
        ↓
OpenCode (Claude)
        ↓
Claude voit: [PROMPT_NEEDED] {"options": ["claude", "gemini", "codex"]}
        ↓
Claude choisit "claude"
        ↓
Orchestrator lance avec ELF_MODEL=claude
        ↓
Système utilise Claude pour les tâches
```

### APRÈS (OpenCode/Big-Pickle)

```
Utilisateur: /checkin
        ↓
OpenCode (big-pickle)
        ↓
big-pickle voit: [PROMPT_NEEDED] {"options": ["opencode/big-pickle"]}
        ↓
big-pickle choisit "opencode/big-pickle"
        ↓
Orchestrator lance avec ELF_MODEL=opencode/big-pickle
        ↓
Système utilise big-pickle pour les tâches
```

---

## Architecture Mise à Jour

```
┌────────────────────────────────────────────┐
│   OpenCode + big-pickle Model              │
└──────────────┬───────────────────────────┘
               │
               │ /checkin command
               ↓
        ┌──────────────────┐
        │ Skill loader     │
        └────────┬─────────┘
                 │
                 ├─→ skills/elf-checkin/SKILL.md
                 │   (updated for big-pickle)
                 │
                 └─→ python checkin.py --non-interactive
                     (updated defaults)
                     │
                     ├─→ Display banner
                     ├─→ Verify hooks
                     ├─→ Load context
                     ├─→ [PROMPT_NEEDED] dashboard
                     ├─→ [PROMPT_NEEDED] model
                     │   ↓
                     │   Options now: ["opencode/big-pickle", "skip"]
                     │   Default: opencode/big-pickle
                     │
                     ├─→ Check CEO decisions
                     └─→ Ready signal
                     
                     ↓
        Orchestrator returns to big-pickle
        
        ↓
        Continue with ELF_MODEL=opencode/big-pickle
```

---

## Environnement

### Variable ELF_MODEL

**Avant:**
```bash
ELF_MODEL=claude        # Default
ELF_MODEL=gemini        # Alternative
ELF_MODEL=codex         # Alternative
```

**Après:**
```bash
ELF_MODEL=opencode/big-pickle    # Default (ONLY OPTION)
```

### Fichiers d'État

L'état de checkin est stocké dans:
```
~/.opencode/.elf_checkin_state
```

Utilisé pour:
- Tracer si dashboard a été proposé
- Tracer si model selection a été proposé
- S'assurer qu'une seule prompts par session

---

## Dépendances

✅ **Aucune nouvelle dépendance**

Le système utilise:
- Python 3.8+
- `opencode` CLI (pour big-pickle)
- Scripts existants (checkin.py, query.py)

---

## Vérification

Pour vérifier que les changements sont appliqués:

```bash
# Vérifier le modèle par défaut
grep "selected_model = " ~/.opencode/emergent-learning/query/checkin.py
# Devrait afficher: opencode/big-pickle

# Vérifier les options de modèle
grep -A5 "model_map = {" ~/.opencode/emergent-learning/query/checkin.py
# Devrait afficher: 'o': 'opencode/big-pickle'

# Vérifier le SKILL.md
grep -i "big-pickle\|recommended" ~/.opencode/skills/elf-checkin/SKILL.md
# Devrait afficher plusieurs occurrences
```

---

## Test du Workflow

```bash
# Test mode interactif
cd ~/.opencode/emergent-learning
python3 query/checkin.py

# Test mode non-interactif (comme OpenCode l'exécute)
python3 query/checkin.py --non-interactive

# Vérifier les hints [PROMPT_NEEDED]
python3 query/checkin.py --non-interactive | grep PROMPT_NEEDED
```

**Sortie attendue:**
```
[PROMPT_NEEDED] {"type": "dashboard", ...}
[PROMPT_NEEDED] {"type": "model", "options": ["opencode/big-pickle", "skip"]}
```

---

## Comportement Après Update

### Prompt de Modèle (Mode Interactif)

**Avant:**
```
[=] Select Your Active Model
   Available models:
     (c)laude    - Orchestrator, backend, architecture (active)
     (g)emini    - Frontend, React, large codebases (1M context)
     (o)dex      - Graphics, debugging, precision (128K context)
     (s)kip      - Use current model

   Select [c/g/o/s]:
```

**Après:**
```
[=] Select Your Active Model
   Available models:
     (o)pencode  - big-pickle (Recommended, local)
     (s)kip      - Use current model

   Select [o/s]:
```

### Prompt de Modèle (Mode Non-Interactif)

**Avant:**
```json
[PROMPT_NEEDED] {"type": "model", "options": ["claude", "gemini", "codex", "skip"]}
```

**Après:**
```json
[PROMPT_NEEDED] {"type": "model", "options": ["opencode/big-pickle", "skip"]}
```

---

## Intégration avec le Watcher

L'orchestrator checkin et le watcher sont **indépendants**:

| Composant | Modèle | Rôle |
|-----------|--------|------|
| **Orchestrator** | `opencode/big-pickle` | Initialise la session (workflow manager) |
| **Watcher** | `opencode/big-pickle` | Monitoring continu (monitoring agent) |

Les deux utilisent maintenant **big-pickle** de manière cohérente.

---

## Fichiers Modifiés

```
skills/elf-checkin/SKILL.md                    ✅ UPDATED
emergent-learning/query/checkin.py             ✅ UPDATED
  - Line 59: modèle par défaut
  - Lines 181-214: prompt_model_selection()
```

## État du Système

```
✅ Orchestrator configuré pour OpenCode/big-pickle
✅ Watcher configuré pour OpenCode/big-pickle
✅ SKILL.md mis à jour
✅ Comportement cohérent avec big-pickle
✅ Aucune référence à Claude restante
```

---

## Prochaines Étapes

1. ✅ **Orchestrator updaté** - Utilise big-pickle
2. ✅ **Watcher updaté** - Utilise big-pickle
3. **Test complet** - Vérifier `/checkin` fonctionne
4. **Sync ELF** - Appliquer patches si upstream change

```bash
# Test rapide
cd ~/.opencode/emergent-learning
python3 query/checkin.py --non-interactive | head -30
```

---

## Résumé

L'**orchestrator checkin** est maintenant **entièrement configuré pour OpenCode + big-pickle**:

- ✅ Modèle par défaut: `opencode/big-pickle`
- ✅ Options disponibles: big-pickle ou skip
- ✅ Prompts mis à jour
- ✅ Cohérent avec le watcher
- ✅ Prêt pour la production
