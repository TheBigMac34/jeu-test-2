# CLAUDE.md — Projet Jeux-Test-2

> Ce fichier est lu automatiquement par Claude à chaque session.

## Infos générales
- **Moteur** : Godot 4
- **Langage** : GDScript
- **Dossier du projet** : `C:\Users\marou\OneDrive\Documents\jeux-test-2`
- **Langue de communication** : Français

## Structure du projet

| Dossier | Contenu |
|---|---|
| `Player/` | Personnage joueur (`player.gd`, `player.tscn`) |
| `enemie/` | Ennemis : Balls, Chomp, chauve-souris, chenille, spike |
| `Menu/` | Menu principal, pause, boutons de niveaux |
| `lvl 1/` | Niveaux : lvl_1_1, lvl_1_2, lvl_1_3 |
| `CP+Fin/` | Checkpoints et drapeau de fin de niveau |
| `UI/` | Interface HUD (`ui.gd`, `ui.tscn`) |
| `Block/` | Blocs de plateforme |
| `Son/` | Effets sonores |
| `power up+piece/` | Power-ups et pièces |
| `decord/` | Éléments de décor |
| `Game Over/` | Scène Game Over |
| `PNJ/` | PNJ vieux (`pnj.gd`, `pnj.tscn`) |

## Fichier global (`Global.gd`)
- Autoload/Singleton gérant les données globales
- **Vies** : `vies_actuelles` (défaut 2), `vies_max` (3)
- **Pièces objectif** : système de collecte par niveau (`piece_objectif_1` à `piece_objectif_5`)
- **Sauvegarde** : JSON dans `user://savegame.json`
- **Checkpoints** : sauvegardés dans `user://checkpoint.json`
- **Médailles** : `medaille_bronze`, `medaille_argent`, `medaille_or` (bool), `current_level_scene` (String)
- **Power-ups** : `has_dash` (bool), `has_double_jump` (bool) — sauvegardés en JSON
- Fonctions clés : `perdre_vie()`, `gagner_vie()`, `game_over()`, `save_checkpoint()`, `load_checkpoint()`, `clear_checkpoint()`

## Système de médailles
- **Bronze** : niveau terminé (`level_X_done`)
- **Argent** : 20 pièces ramassées (`level_X_silver`)
- **Or** : toutes les pièces objectif (`level_X_gold`)
- Les médailles sont **persistantes** : on vérifie aussi la save des sessions précédentes
- `drapeau_fin.gd` a 2 exports : `save_key` (ex: `level_1_1`) et `piece_objectif_key` (ex: `Lvl_1_1`)
- `fin_niveau.tscn` → écran de fin avec 3 TextureRect (médailles) + bouton Menu
- `fin_niveau.gd` → lit `Global.medaille_*` et change les textures
- `menu_principal.gd` → affiche les sprites médailles selon la save
- `level_1_1_bouton.gd` → change la couleur du texte : bronze/argent/or/blanc

## État d'avancement
- ✅ Menu principal
- ✅ Système de vies
- ✅ Système de checkpoints
- ✅ Sauvegarde des pièces objectif
- ✅ Game Over
- ✅ Niveaux 1-1, 1-2, 1-3 (structure créée)
- ✅ Ennemis (plusieurs types)
- ✅ Écran de fin de niveau (`fin_niveau.tscn`) avec médailles bronze/argent/or
- ✅ Médailles affichées dans le menu principal (sprites + couleur bouton)
- ✅ Son gold brick corrigé (`piece_block.gd` : play → await tween → visible=false → await son → queue_free)
- ✅ Joueur figé au contact du drapeau (`var fige`, `func figer()` dans `player.gd`, `body.figer()` dans `drapeau_fin.gd`)
  - Gravité maintenue, inputs bloqués, freinage progressif au sol, inertie gardée en l'air
- ✅ Dash (`player.gd` : `has_dash`, `is_dashing`, timers, input action `"dash"` → RB Xbox)
  - DASH_SPEED=400, DASH_DURATION=0.2
  - **Recharge au sol** : `can_dash` repasse à `true` dès que `is_on_floor()` (plus de cooldown timer)
  - Direction mémorisée dans `derniere_direction`
- ✅ Double saut (`player.gd` : `sauts_restants`, reset au sol, décrémenté au saut)
  - Actif uniquement si `Global.has_double_jump == true`
- ✅ `defiger()` ajouté dans `player.gd`
- ✅ PNJ vieux (`PNJ/pnj.gd` + `PNJ/pnj.tscn`)
  - Dialogue machine à écrire + attente A + remise orbe
  - `@export var type_orbe` : `"dash"` (lvl 1_2) ou `"double_saut"` (lvl 1_3)
  - Interaction non rejouable, persistée via `Global.has_dash` / `Global.has_double_jump`
  - Signal `body_entered` de `Zone` → `_on_zone_body_entered`
  - Bulle de dialogue en espace monde (`DialogueBulle` Node2D positionné au-dessus du PNJ)
  - Structure : `DialogueBulle` → `DialoguePanel` → `NinePatchRect` + `RichTextLabel` + `HintLabel`
  - Chemins `@onready` : `$DialogueBulle/DialoguePanel`, `.../RichTextLabel`, `.../HintLabel`
  - **Effet machine à écrire sans émargement** : `visible_characters = 0` AVANT `text = texte`, puis `await process_frame`, puis boucle `visible_characters = i + 1`
  - Textes avec `\n` manuels pour contrôler les coupures de ligne (pas de word-wrap automatique)
  - `scroll_active = false` sur le RichTextLabel
- ✅ Reset (`menu_principal.gd`) remet aussi `Global.has_dash = false` et `Global.has_double_jump = false` en mémoire
- ✅ Animation dash (`player.gd`) : animation `"dash"` (personnage redessiné en rouge) quand `has_dash and can_dash`, sinon `"player 1"` — jouée chaque frame comme l'originale, initialisée dans `_ready()`
- ✅ Orbe PNJ : explosion en 5 mini-sprites qui s'absorbent vers le joueur (style Hollow Knight) via `_explosion_absorption()` dans `pnj.gd` avec Tweens dynamiques
- 🔧 À faire : niveau 1-2, 1-3 (level design), chauve-souris verticale, son heal, boutons animés
- 🔧 À faire : placer le PNJ dans lvl_1_2.tscn et lvl_1_3.tscn
- 🔧 Prochain objectif : dynamiser l'attente du drapeau de fin (feux d'artifice avec `CPUParticles2D` pendant les ~5s avant la scène de fin)

## Notes importantes
- Les commentaires de debug sont mis en commentaire (`#print(...)`) intentionnellement
- Les pièces objectif sont identifiées par `"piece_objectif_1"` à `"piece_objectif_5"` par niveau
- Le niveau suivant est débloqué selon la progression sauvegardée
- ⚠️ Pour changer de scène, toujours utiliser `get_tree().call_deferred("change_scene_to_file", "res://...")` — `change_scene_to_packed` peut échouer silencieusement depuis un signal
