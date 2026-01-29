# Orchestrator Guide

## Qu'est-ce qu'un Orchestrator?

Un **orchestrator** est un **gestionnaire de workflow** qui coordonne une série d'étapes pour accomplir une tâche. C'est un concept clé dans ELF.

### 4 Types d'Orchestrators dans ELF

---

## 1️⃣ **Checkin Orchestrator** (celui du `/checkin`)

### Qu'est-ce que c'est?
C'est le workflow **d'initialisation de session**. Il charge l'institutional knowledge et prépare le framework.

### Que fait-il?

```
Afficher Banner (ASCII art)
        ↓
Vérifier les hooks
        ↓
Charger le contexte du bâtiment (golden rules, heuristics)
        ↓
Afficher les règles d'or
        ↓
Demander: "Lancer le dashboard?" (1ère fois seulement)
        ↓
Demander: "Quel modèle utiliser?" (1ère fois seulement)
        ↓
Vérifier les décisions en attente du CEO
        ↓
Prêt à travailler
```

### 8 Étapes du Workflow

| Étape | Nom | Fonction |
|-------|-----|----------|
| 1 | **Banner** | Affiche le logo ELF |
| 1b | **Verify Hooks** | Vérifie que les hooks sont installés |
| 2 | **Load Context** | Charge golden rules & heuristics du bâtiment |
| 3 | **Display Rules** | Affiche les principes cardinaux |
| 4 | **Session Summary** | (Optionnel) Résumé des sessions précédentes |
| 5 | **Dashboard Prompt** | "Lancer le dashboard?" (1ère fois) |
| 6 | **Model Selection** | "Quel modèle?" (1ère fois) |
| 7 | **CEO Decisions** | Affiche les décisions en attente |
| 8 | **Ready Signal** | ✅ Checkin complete |

### Quand est-il lancé?

**Automatiquement:**
- Au démarrage d'une session OpenCode
- Quand l'utilisateur tape `/checkin`

**Fichier Python:**
```
~/.opencode/emergent-learning/query/checkin.py
```

**Classe:**
```python
class CheckinOrchestrator:
    def run(self):
        # Exécute les 8 étapes
```

### Où est la logique?

```python
emergent-learning/query/checkin.py

CheckinOrchestrator class:
  - display_banner()           # Étape 1
  - verify_hooks()             # Étape 1b
  - load_building_context()    # Étape 2
  - display_golden_rules()     # Étape 3
  - prompt_dashboard()         # Étape 5
  - prompt_model_selection()   # Étape 6
  - check_ceo_decisions()      # Étape 7
  - run()                      # Orchestre tout
```

### États et Configuration

**State Tracking:**
```
~/.opencode/.elf_checkin_state
```

Utilisé pour:
- Tracer si dashboard a été proposé
- Tracer si model selection a été proposé
- Ne demander qu'une seule fois par session

**Variables d'Environnement:**
```bash
ELF_MODEL              # Modèle sélectionné (claude, gemini, codex)
ELF_BASE_PATH          # Chemin du répertoire ELF
```

---

## 2️⃣ **Ralph Loop Orchestrator** (Amélioration Itérative)

### Qu'est-ce que c'est?
Orchestre les cycles d'amélioration de code entre **Code Reviewer** et **Code Simplifier**.

### Que fait-il?

```
Étape 1: Analyser le code
        ↓
Étape 2: Demander au Reviewer ses notes
        ↓
Étape 3: Appliquer les suggestions
        ↓
Étape 4: Simplifier
        ↓
Étape 5: Vérifier la convergence
        ↓
Étape 6-8: Itérer ou terminer
```

### 8 Étapes

1. **Load** - Charger le code
2. **Analyze** - Analyser la qualité
3. **Review** - Obtenir feedback
4. **Apply** - Appliquer les changements
5. **Simplify** - Simplifier le code
6. **Check** - Vérifier la convergence
7. **Iterate** - Retourner à l'étape 3 ou terminer
8. **Complete** - Code amélioré

### Quand est-il lancé?

**Commande:**
```bash
/ralph-loop
```

**Fichier:**
```
skills/ralph-loop/SKILL.md
```

**Python:**
```
emergent-learning/agents/ralph_orchestrator.py
```

---

## 3️⃣ **Swarm Orchestrator** (Multi-Agent Coordination)

### Qu'est-ce que c'est?
Orchestre un **swarm d'agents spécialisés** pour résoudre des tâches complexes:
- **Architect** - Design/Architecture
- **Researcher** - Recherche & Analyse
- **Skeptic** - Critique & Validation
- **Creative** - Idées innovantes

### Que fait-il?

```
Défaut la tâche
        ↓
Assigner à chaque agent
        ↓
Agents travaillent en parallèle
        ↓
Collecter les résultats
        ↓
Synthétiser les conclusions
        ↓
Fournir la réponse finale
```

### Modes d'Exécution

| Mode | Agents | Cas d'usage |
|------|--------|-----------|
| **Analyze** | Researcher + Skeptic | Évaluer une idée |
| **Design** | Architect + Researcher | Concevoir l'architecture |
| **Implement** | Architect + Creative | Implémentation innovante |
| **Review** | Skeptic + Researcher | Audit/Révision |

### Quand est-il lancé?

**Outil:**
```javascript
/swarm_task
```

**Fichier:**
```
tools/swarm_task.js
agents/swarm-orchestrator.js
```

---

## 4️⃣ **OPC-ELF Sync Orchestrator** (Synchronisation Système)

### Qu'est-ce que c'est?
Gère la **synchronisation, sauvegarde et patch** du framework ELF.

### Que fait-il?

```
Fetch upstream
        ↓
Sauvegarder données locales
        ↓
Réinitialiser à upstream
        ↓
Nettoyer références Claude
        ↓
Appliquer patches OpenCode
        ↓
Installer le plugin
        ↓
Valider setup
        ↓
Rapport final
```

### Quand est-il lancé?

**Installation initiale:**
```bash
bash opencode_elf_install.sh
```

**Synchronisation manuelle:**
```bash
bash scripts/opc-elf-sync.sh
```

**Fichier:**
```
scripts/opc-elf-sync.sh
```

---

## Comparaison des 4 Orchestrators

| Orchestrator | Type | Quand | Fichier | Rôle |
|---|---|---|---|---|
| **Checkin** | Workflow | `/checkin` | `query/checkin.py` | Initialiser session |
| **Ralph Loop** | Amélioration | `/ralph-loop` | `agents/ralph_orchestrator.py` | Itérer sur code |
| **Swarm** | Multi-agent | `swarm_task` outil | `agents/swarm-orchestrator.js` | Tâches complexes |
| **OPC-ELF Sync** | Système | `opencode_elf_install.sh` | `scripts/opc-elf-sync.sh` | Sync framework |

---

## Exemple d'Exécution: Checkin

### Quand l'utilisateur tape `/checkin`

```
1. OpenCode détecte la commande
   ↓
2. Appelle le skill: skills/elf-checkin/SKILL.md
   ↓
3. Lance: python ~/.opencode/emergent-learning/query/checkin.py
   ↓
4. Crée une instance CheckinOrchestrator
   ↓
5. Appelle orchestrator.run()
   ↓
6. Exécute les 8 étapes en séquence:
   
   ├─ display_banner()              [Banner ELF]
   ├─ verify_hooks()                [Vérifier hooks]
   ├─ load_building_context()       [Charger contexte]
   ├─ display_golden_rules()        [Afficher règles]
   ├─ prompt_dashboard()            [Demander dashboard]
   ├─ prompt_model_selection()      [Demander modèle]
   ├─ check_ceo_decisions()         [Vérifier CEO]
   └─ print("Ready to work!")       [Complet]
   ↓
7. Retourne le contrôle à OpenCode
   ↓
8. Utilisateur peut travailler
```

---

## Architecture Générale

```
┌─────────────────────────────────────────────────────┐
│             OpenCode (Interface Utilisateur)        │
└────────────────┬──────────────────────────────────┘
                 │
         ┌───────┴────────┐
         │                │
    Commands/Tools      Skills
    (JavaScript)      (SKILL.md)
         │                │
         └────────┬───────┘
                  │
         ┌────────▼────────┐
         │  Orchestrators  │
         │    (Python)     │
         └────────┬────────┘
                  │
      ┌───────────┼───────────┬──────────────┐
      │           │           │              │
   Checkin    Ralph Loop    Swarm      OPC-ELF Sync
   (Workflow) (Amélioration)(Multi-Agent)(Système)
```

---

## Patterns Clés d'un Orchestrator

### 1. **Exécution Séquentielle**
Les étapes s'exécutent dans un ordre défini:
```python
def run(self):
    self.step_1()
    self.step_2()
    self.step_3()
    # ...
```

### 2. **Gestion d'État**
Tracer la progression et les décisions:
```python
self.elf_home          # Chemin ELF
self.selected_model    # Modèle choisi
self.interactive       # Mode interactif ou non
```

### 3. **Gestion d'Erreur**
Continuer malgré les erreurs mineures:
```python
try:
    load_context()
except Exception:
    print("[WARN] Context loading failed (continuing)")
```

### 4. **Mode Interactif/Non-Interactif**
- **Interactif**: Demander à l'utilisateur
- **Non-interactif**: Produire des hints JSON pour Claude
```python
if not self.interactive:
    print('[PROMPT_NEEDED] {"type": "dashboard", ...}')
```

---

## Checkin Orchestrator: Flux Détaillé

### Input
```
Commande utilisateur: /checkin
```

### Processing
```python
orchestrator = CheckinOrchestrator(interactive=False)  # Non-interactive
orchestrator.run()  # Exécute 8 étapes
```

### Output

**Mode Interactif:**
```
┌────────────────────────────────────┐
│    Emergent Learning Framework     │
├────────────────────────────────────┤
│      [ASCII Banner]                │
└────────────────────────────────────┘

[OK] Hooks verified
[*] Loading Building Context...
[OK] Context loaded
[+] Start ELF Dashboard?
   Start Dashboard? [Y/n]: 
[=] Select Your Active Model
   (c)laude / (g)emini / (o)dex / (s)kip
   Select [c/g/o/s]: 

[!] Pending CEO Decisions: 2
   - decision-1
   - decision-2

[OK] Checkin complete. Ready to work!
```

**Mode Non-Interactif (via Claude):**
```
[OK] Hooks verified
[*] Loading Building Context...
[OK] Context loaded
[PROMPT_NEEDED] {"type": "dashboard", "question": "Start ELF Dashboard?", ...}
[PROMPT_NEEDED] {"type": "model", "question": "Select AI model", ...}
[!] Pending CEO Decisions: 2
[OK] Checkin complete. Ready to work!
```

---

## Commandes Associées

### Checkin
```bash
/checkin                    # Lance le workflow
python checkin.py          # Direct (interactif)
python checkin.py -n       # Non-interactif
```

### Ralph Loop
```bash
/ralph-loop                # Lance les itérations
```

### Swarm
```bash
/swarm_task                # Lance multi-agents
```

### Sync
```bash
bash opencode_elf_install.sh  # Installation interactive
bash scripts/opc-elf-sync.sh  # Sync manuel
```

---

## Takeaway

> **Un orchestrator est un gestionnaire de workflow** qui coordonne une série d'étapes pour accomplir une tâche spécifique.
> 
> Dans ELF:
> - 🎯 **Checkin** initialise la session
> - 📈 **Ralph Loop** améliore le code itérativement
> - 👥 **Swarm** résout des tâches avec plusieurs agents
> - 🔄 **OPC-ELF Sync** synchronise le framework
> 
> Tous suivent le même pattern: **Planifier → Exécuter → Valider → Rapporter**
