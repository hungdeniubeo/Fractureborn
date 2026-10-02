# Phase 1 editor workflow

Open `project.godot` with Godot 4.7.2 stable. The scene tree owns visible layout and placement; scripts bind rules and live values to those nodes. Save a scene after moving an object or changing a Control. The placeholder graphics are intentional and can be replaced later.

## Move UI

- Open `scenes/ui/hud.tscn` in the 2D editor. Move or resize `Screen/StatusPanel`, `QuestPanel`, `BossPanel`, `WeaponPanel`, `HotbarPanel`, `Interaction`, `Toast`, and `InventoryHint`. Edit their child Labels and ProgressBars for fonts, colors, margins, and bar style. Keep their node names and hierarchy because `scripts/ui/hud.gd` binds to them.
- Open `scenes/ui/save_select.tscn` for the title, name entry, and three slot cards. Open `scenes/ui/inventory_panel.tscn`, `pause_menu.tscn`, or `debug_overlay.tscn` to edit those overlays. The HUD instances the overlay scenes, so edits to their source scenes appear everywhere.
- `scenes/ui/inventory_item_row.tscn` is the template for weapon and item rows. Rows are created only for inventory contents; their visual layout still comes from this scene.
- `scenes/ui/map_panel.tscn` sets the map Control size and placement. The map itself is drawn from the current TileMapLayer and placed markers at runtime, so painted paths and moved landmarks appear in the map panel.
- Keep `Screen` and full-screen overlay anchors unless intentionally changing how they respond to window resize. Use the Inspector or 2D handles for offsets, minimum sizes, font overrides, colors, ProgressBar styles, and panel styles. Scripts do not set fixed UI coordinates.

## Edit Green Plains and Central Village

Open `scenes/world/green_plains_world.tscn` or `scenes/world/village_world.tscn`. Both maps are separate scenes. `GroundTiles` is an editor-authored `TileMapLayer`; `StaticProps` holds a small number of reusable prop scene instances; `PlacedInteractables` holds NPCs, waypoints, chests, runes, and travel points. Green Plains also has `EnemySpawns`.

### Paint tiles

1. Select `GroundTiles` in the scene tree and use Godot's TileMap paint tool in the 2D editor.
2. Select atlas cells from `data/world/green_plains_tileset.tres` or `data/world/village_tileset.tres`. The current four 32×32 placeholder cells are grass A, grass B, path, and clearing/plaza, left to right.
3. Paint, erase, or extend terrain, then save the map scene. Gameplay map bounds and camera limits derive from the painted used rectangle. Keep the painted area starting at cell `(0, 0)` for now; the current bounds code assumes that origin.
4. The atlas PNGs in `assets/placeholders/` use nearest-neighbor display and no mipmaps. Replacing an atlas with final art can keep the same cell positions; adding tiles requires editing the TileSet, and tile layout changes require painting the map.

### Move actors and props

- Move `PlayerSpawn` with the 2D move tool to change the default entry point. An activated waypoint still takes priority when loading a character on that map.
- Expand `EnemySpawns` and drag a `Marker2D` to change where that enemy appears. The `enemy_id` Inspector property chooses its shared enemy definition. Enemy AI and stats are unaffected by marker movement.
- Expand `PlacedInteractables` and drag a placed NPC, waypoint, chest, rune, hint, or travel point. Its interaction shape moves with it. A waypoint's placed position is used for checkpoint spawn and death respawn; no coordinate change in GDScript is needed. The map panel reads these positions too.
- Expand `StaticProps` to move tree, rock, building, sign, and bramble gate scene instances. Trees, rocks, buildings, and the gate contain simple collision shapes. Signs have no gameplay script. Moving a prop moves its collision with it.
- Open an actor's source scene under `scenes/world/actors/` or a prop scene under `scenes/world/props/` to change the reusable visual or collision for all instances. `scenes/world/interactable.tscn` is the shared interaction base; its script draws temporary color-coded placeholder shapes in the editor.

Positions, scales, colors, sprite or polygon visuals, panel styles, fonts, tile painting, and simple collision shape sizes are safe visual edits. Preserve gameplay identifiers (`interactable_id`, `enemy_id`, rune `data.symbol`, travel `data.map_id`), scene node names used by scripts, collision layers, and the hidden gate node path unless also updating gameplay code and saves. The rune solution order is Dawn → Sun → Leaf.

Placed interactables are moved into active runtime chunks when the map starts. Edit their original nodes in the map scene, not their runtime position in the Remote scene tree. Static props stay script-free and static; enemy AI remains active only near the player.

The editor owns composition and presentation. Gameplay rules that intentionally remain code-driven include quest state, combat AI, loot rolls, chunk activation, projectile pooling, respawn selection, and save serialization. Runtime-only objects such as loot pickups and projectiles are still created by their systems because their count and contents are gameplay data rather than fixed level composition.

## Check an edit

Run the scene in Godot and walk to the moved location. For a quick automated check, run `godot --headless --path . --editor --quit`, then `godot --headless --path . --script tests/run_logic_tests.gd` and `godot --headless --path . --script tests/run_playable_flow.gd`. The playable-flow test deliberately shifts a player spawn, an enemy marker, and a waypoint before scene entry and verifies their gameplay positions, including respawn.
