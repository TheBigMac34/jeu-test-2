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
- ✅ Boutons de niveaux animés au hover/focus (grossissement 110%, 0.1s) — `level_1_1_bouton.gd`, `level_1_2.gd`, `level_1_3.gd`
- ✅ Déblocage progressif des niveaux dans le menu : 1-2 caché jusqu'à `level_1_1_done`, 1-3 caché jusqu'à `level_1_2_done` — `_update_level_visibility()` dans `menu_principal.gd`
- ✅ Navigation focus pause : le focus va sur le bouton **Menu** à l'ouverture du menu pause (avant : Back) — `ui.gd`
- ✅ DrapeauFin ajouté dans `lvl_1_2.tscn` avec `save_key="level_1_2"` — écrira `level_1_2_done` à la complétion
- ✅ Tuto dash dans `lvl_1_2.tscn` (`decoration/HBoxContainer`) : affiché seulement si `Global.has_dash == true`, vérifié dans `_process` de `lvl_1_2.gd`
- ✅ `savegame.json` indenté avec tabulations (`JSON.stringify(data, "\t")`) dans `Global.gd`, `drapeau_fin.gd`, `menu_principal.gd`
- ✅ Son gold brick corrigé (`piece_block.gd` : play → await tween → visible=false → await son → queue_free)
- ✅ Joueur figé au contact du drapeau (`var fige`, `func figer()` dans `player.gd`, `body.figer()` dans `drapeau_fin.gd`)
  - Gravité maintenue, inputs bloqués, freinage progressif au sol, inertie gardée en l'air
- ✅ Dash (`player.gd` : `has_dash`, `is_dashing`, timers, input action `"dash"` → RB Xbox)
  - DASH_SPEED=400, DASH_DURATION=0.2
  - **Recharge au sol** : `can_dash` repasse à `true` dès que `is_on_floor()` (plus de cooldown timer)
  - Direction mémorisée dans `derniere_direction`
- ✅ `defiger()` ajouté dans `player.gd`
- ✅ PNJ vieux (`PNJ/pnj.gd` + `PNJ/pnj.tscn`) — uniquement pour le dash (lvl 1_2)
  - Dialogue machine à écrire + attente A + remise orbe
  - Interaction non rejouable, persistée via `Global.has_dash`
  - Bulle de dialogue en espace monde (`DialogueBulle` Node2D positionné au-dessus du PNJ)
  - **Effet machine à écrire sans émargement** : `visible_characters = 0` AVANT `text = texte`
- ✅ Reset (`menu_principal.gd`) remet aussi `Global.has_dash = false` en mémoire
- ✅ Orbe PNJ : explosion en 5 mini-sprites qui s'absorbent vers le joueur (style Hollow Knight) via `_explosion_absorption()` dans `pnj.gd` avec Tweens dynamiques
- ✅ **DASH TERMINÉ** — Effet trail pendant le dash (`player.gd` : `_spawn_trail_ghost()`)
  - Des fantômes bleutés translucides apparaissent derrière le joueur **pendant** le dash uniquement
  - Spawné toutes les `TRAIL_INTERVAL` (0.05s) via `trail_timer` dans le bloc `is_dashing`
  - Chaque fantôme : Sprite2D créé dynamiquement, même texture/orientation que le joueur, fade out en 0.3s via Tween puis `queue_free`
  - Couleur : `Color(0.5, 0.85, 1.0, 0.55)` (bleu translucide)
  - Dash recharge au sol (`can_dash = true` dès `is_on_floor()`), direction mémorisée dans `derniere_direction`
- ✅ **Chenille 4** (`enemie/chenille/chenille_4.gd` + `chenille 4.tscn`) — Surface Walker
  - Approche mathématique pure : suivi du périmètre en pixels, pas de physique/gravité/raycasts
  - `perimeter_progress` avance de `speed` px/s, bouclé avec `fposmod()`
  - `_get_surface_data(t)` retourne `[surface_point, surface_normal]` pour les 4 faces (UP/RIGHT/DOWN/LEFT)
  - `global_position = parent.to_global(surface_point + normal * offset)` avec offset par face
  - Offsets par face (tiles Kenney asymétriques) : `OFFSET_TOP=14`, `OFFSET_BOTTOM=13`, `OFFSET_SIDE=14`
  - Rotation sprite : `surface_normal.angle() + PI/2` ; flip : `speed > 0`
  - Activée par `VisibleOnScreenNotifier2D` (`on_screen = true`)
- ✅ **Système clé style Mario** (`power up+piece/key.gd` + `key_bloc.gd`)
  - `key.tscn` : Area2D dans le niveau → joueur touche → `Global.has_key = true` → clé suit le joueur
  - Suivi lerp (`LERP_SPEED=10`) + `.round()` pour éviter la vibration subpixel
  - La clé se place **derrière** le joueur : offset `-dir * OFFSET.x` (retourne selon direction)
  - Groupe `"key"` pour que `key_bloc` puisse retrouver la clé via `get_first_node_in_group`
  - `key_bloc.tscn` : Area2D destination → vérifie `Global.has_key` → `queue_free()` la clé → instancie `piece_objectif.tscn` à sa position
  - `key_bloc` exports : `piece_scene` (PackedScene), `level_id`, `piece_objectif_id` (défaut: `piece_objectif_5`)
  - `Global.has_key: bool` ajouté dans `Global.gd` (non persisté, remis à false à la livraison)
- ✅ Clé tombe si le joueur prend un dégât (`drop()` dans `key.gd`, appelé depuis `take_damage()` dans `player.gd`)
- ✅ Level design lvl_1_2 terminé
- 🔧 À faire : level design lvl_1_3
- 🔧 À faire : chauve-souris verticale (ennemi)
- 🔧 À faire : son heal (quand le joueur regagne une vie)
- 🔧 À faire : médailles pour lvl_1_2 (argent/or) — pièces objectif à placer, `piece_objectif_key` à configurer sur le DrapeauFin

## Notes importantes
- **Tous les fichiers `.gd` doivent avoir un commentaire sur chaque ligne importante** expliquant à quoi elle sert — pour que le code soit lisible par tout le monde
- Les commentaires de debug sont mis en commentaire (`#print(...)`) intentionnellement
- Les pièces objectif sont identifiées par `"piece_objectif_1"` à `"piece_objectif_5"` par niveau
- Le niveau suivant est débloqué selon la progression sauvegardée
- ⚠️ Pour changer de scène, toujours utiliser `get_tree().call_deferred("change_scene_to_file", "res://...")` — `change_scene_to_packed` peut échouer silencieusement depuis un signal
