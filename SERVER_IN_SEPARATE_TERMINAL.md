# ✅ OpenCode Server - Separate Terminal Window

## Le Changement

Le serveur OpenCode est maintenant lancé dans une **fenêtre de terminal séparate** que tu peux:
- 👀 Monitorer en temps réel
- 🔴 Fermer manuellement si besoin
- 📊 Voir tous les logs

---

## Comportement Automatique

Quand tu lances le checkin et que le serveur n'est pas en cours d'exécution:

```bash
python3 emergent-learning/query/checkin.py
```

Cela:
1. ✅ Détecte le terminal disponible (gnome-terminal, xterm, konsole, etc.)
2. ✅ Lance le serveur dans ce terminal
3. ✅ Affiche les logs du serveur dans le terminal
4. ✅ Garde le terminal ouvert pour monitoring
5. ✅ Tu peux le fermer manuellement à tout moment

Output:
```
0️⃣  Checking OpenCode Server Status...
   ⚙️  Starting OpenCode server in terminal...
   ✅ Server starting in gnome-terminal window
   You can monitor and close the terminal window as needed
   ⏳ Waiting for server to start...
   ✅ Server started successfully
```

---

## Détection Automatique du Terminal

Le script détecte automatiquement quel terminal tu utilises:

```python
Supportés:
✅ gnome-terminal (GNOME)
✅ xterm (Classic)
✅ konsole (KDE)
✅ xfce4-terminal (XFCE)
✅ mate-terminal (MATE)
✅ lxterminal (LXDE)
✅ urxvt / rxvt (Minimal)
```

### Fallback

Si aucun terminal n'est trouvé:
```
⚠️  No terminal emulator found, starting in background...
ℹ️  Server running in background
```

---

## Workflow Réel

### Avec le Serveur Déjà Lancé
```bash
python3 emergent-learning/query/checkin.py

Output:
0️⃣  Checking OpenCode Server Status...
   ✅ Server already running

# Continue normally, serveur ignoré
```

### Sans le Serveur (Lancement Auto)
```bash
python3 emergent-learning/query/checkin.py

Output:
0️⃣  Checking OpenCode Server Status...
   ⚙️  Starting OpenCode server in terminal...
   ✅ Server starting in gnome-terminal window
   You can monitor and close the terminal window as needed
   ⏳ Waiting for server to start...
   ✅ Server started successfully

# Une nouvelle fenêtre terminal s'ouvre avec le serveur!
```

---

## Ce Que Tu Vois dans le Terminal

La fenêtre du terminal affiche:
```
opencode serve --port 4096

Server starting...
✅ Server ready on port 4096
Listening for connections...

[Logs en direct du serveur]
[Sessions, messages, etc.]

# Tu peux voir TOUT ce qui se passe en temps réel
```

---

## Arrêter le Serveur

### Méthode 1: Fermer le Terminal
```
Clique sur le X dans la fenêtre du terminal
→ Le serveur s'arrête
```

### Méthode 2: Ctrl+C dans le Terminal
```
Dans la fenêtre du terminal, appuie Ctrl+C
→ Le serveur s'arrête gracieusement
```

### Méthode 3: Commande
```bash
pkill -f "opencode serve"
```

---

## Avantages

✅ **Monitoring en temps réel**
- Voir tous les logs du serveur
- Voir les connections et requêtes
- Déboguer les problèmes directement

✅ **Contrôle Manuel**
- Fermer le serveur quand tu veux
- Pas besoin de commande compliquée
- Juste fermer la fenêtre

✅ **Visibilité**
- Savoir exactement ce qui se passe
- Voir les erreurs en direct
- Pas de "boîte noire"

✅ **Séparation Propre**
- Terminal du serveur = isolé
- Tes autres terminaux = libres
- Zéro confusion

---

## Cas d'Usage

### Use Case 1: Développement
```bash
# Lancer checkin
python3 emergent-learning/query/checkin.py

# → Terminal du serveur s'ouvre
# → Tu peux voir tous les logs
# → Continuer à travailler dans d'autres terminaux
# → Fermer le terminal du serveur si besoin
```

### Use Case 2: Debugging
```bash
# Lancer checkin
python3 emergent-learning/query/checkin.py

# → Voir les erreurs en direct dans le terminal
# → Analyser les requêtes
# → Tester les fix
```

### Use Case 3: Production
```bash
# Lancer checkin en arrière-plan
nohup python3 emergent-learning/query/checkin.py &

# → Terminal du serveur s'ouvre
# → Laisser ouvert pour monitoring
# → Vérifier les logs quand tu veux
```

---

## Code Implémenté

### Nouvelle Fonction: `get_available_terminal()`
```python
def get_available_terminal(self) -> str:
    """Détecte le terminal disponible"""
    terminals = [
        "gnome-terminal",
        "xterm",
        "konsole",
        # ... etc
    ]
    
    for term in terminals:
        if subprocess.run(["which", term]).returncode == 0:
            return term
    
    return None  # Fallback: background start
```

### Nouvelle Fonction: `start_server_in_terminal()`
```python
def start_server_in_terminal(self) -> bool:
    """Lance le serveur dans un terminal séparé"""
    
    terminal = self.get_available_terminal()
    
    if terminal == "gnome-terminal":
        subprocess.Popen([
            "gnome-terminal",
            "--",
            "bash", "-c",
            "opencode serve --port 4096; bash"
        ])
    elif terminal == "xterm":
        # ... xterm specific ...
    # ... etc pour autres terminaux ...
```

---

## Exemple Complet

```bash
# Terminal 1: Lancer checkin
$ python3 emergent-learning/query/checkin.py

Output:
🔄 OpenCode Checkin Orchestrator
0️⃣  Checking OpenCode Server Status...
   ⚙️  Starting OpenCode server in terminal...
   ✅ Server starting in gnome-terminal window
   You can monitor and close the terminal window as needed

# → Une nouvelle fenêtre terminal s'ouvre (Terminal 2)

# Terminal 2: (AUTO-OUVERT) Affiche les logs du serveur
$ opencode serve --port 4096
Server starting...
✅ Ready on port 4096
[Logs en direct...]

# Terminal 1: Continue le checkin
   ⏳ Waiting for server to start...
   ✅ Server started successfully

[... reste du checkin ...]

🟢 FULLY OPERATIONAL
🚀 Launching Background Services...
✅ Watcher launched in background
✅ Orchestrator launched in background
✅ CEO Advisor launched in background

# Maintenant:
# Terminal 1: Peut être fermé (checkin terminé)
# Terminal 2: Reste ouvert pour monitoring du serveur
# Services: Tournent en arrière-plan
```

---

## Résumé

✅ **Serveur lancé automatiquement**
- Détecte le terminal disponible
- Lance dans une fenêtre séparate
- Logs visibles en direct

✅ **Tu peux monitorer**
- Voir tous les logs
- Analyser les requêtes
- Déboguer si besoin

✅ **Tu peux contrôler**
- Fermer le terminal quand tu veux
- Ctrl+C pour arrêter gracieusement
- Zéro complication

✅ **Séparation propre**
- Terminal du serveur = isolé
- Tes autres tâches = libres
- Pas de confusion

---

**Status**: ✅ IMPLEMENTED
**Terminal Detection**: ✅ AUTOMATIC
**Monitoring**: ✅ ENABLED
**Manual Control**: ✅ EASY
