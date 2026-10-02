# Fractureborn

Fractureborn is an original top-down pixel-art action RPG. This repository contains its first small solo vertical slice, built with Godot 4.7.2 stable and GDScript.

## Run

1. Install Godot 4.7.2 stable.
2. Open `project.godot` in the Godot Project Manager and let the project import.
3. Run the project (F6/F5 or the play button). It opens at the three character slots.

From a terminal:

```sh
godot --path .
godot --headless --path . --editor --quit
godot --headless --path . --script tests/run_logic_tests.gd
godot --headless --path . --script tests/run_playable_flow.gd
godot --headless --path . --script tests/run_playable_flow.gd -- reopen
godot --path . --profiling --script tests/run_performance_profile.gd -- windowed
```

Saves are stored under `user://characters/slot_1.json` through `slot_3.json`; graphics settings are stored in `user://settings.json`.
The playable-flow runner uses `user://tests/flow_characters/slot_3.json`, so it does not write to normal character slots. Run its play phase before its reopen phase.

## Play the slice

Create or continue a Human character in one of the three slots. Speak to Archivist Edda in Central Village, then take the eastern gate into Green Plains. Defeat five common monsters, activate the Plains waystone, and fight the Goblin Captain followed by the Ancient Treant. The Captain always drops an Iron Sword; pick it up and equip it from the pack if desired. Return through the western gate and speak to Edda for the quest reward. Open the pause menu with Esc to save and quit; use Continue in the same slot after restarting. The rune stones, hidden path, and chest are optional exploration on this route.

## Current slice

- Three separate Human character slots with versioned JSON profiles.
- Central Village and connected Green Plains scenes with TileMapLayer terrain, simple obstacles, camps, a hidden rune path/chest, and a return route.
- One saved quest chain, two healing/respawn waypoints, gold/material/weapon loot, inventory and health potions.
- Level progression through 50, tuned for early levels; Human Sword Art, Weapon Focus, and Battle Instinct use cooldowns.
- Training Sword, Iron Sword, Wooden Bow, Basic Pistol, and Basic Shotgun.
- Slime, Goblin, Goblin Archer, Goblin Captain, and three-phase Ancient Treant with a phase-two three-root pattern.
- Death fade, nearest activated waypoint respawn, and boss reset on a fresh encounter.
- Pixel-art-style runtime placeholders. No copyrighted game assets are used.

## Controls

| Action | Keyboard / mouse | Default controller action |
|---|---|---|
| Move | WASD | Left stick |
| Aim | Mouse | Right stick |
| Attack | Left mouse | Right trigger |
| Dodge | Space | X / west face button |
| Sword Art | Q | Left shoulder |
| Weapon Focus | E | Right shoulder |
| Battle Instinct | R | D-pad up |
| Weapon slots | 1 / 2 | Configure in InputMap |
| Interact | F | Y / north face button |
| Pack and map | Tab | Back / View |
| Health potion | H | A / south face button |
| Pause | Esc | Start |
| Performance overlay | F3 (debug builds only) | — |

The controller bindings are default InputMap actions and can be remapped in Godot. Human skills have no mana or energy cost.

## Performance structure

Repeated ground uses one shared atlas-backed TileMapLayer per map. Static decoration is drawn by a shared layer; only obstacles and interactive objects need separate nodes. Map scenes are separate and partitioned into 512-pixel chunks. Nearby chunks stay active; distant interactables sleep and distant enemies disable visibility, physics and AI. Enemy decisions tick at 5 Hz while their movement physics runs only inside the active radius.

Each map owns a bounded projectile pool (12 warmed objects, at most 96). Projectiles have narrow player/enemy collision masks, a maximum lifetime and travel range. The HUD listens to gameplay signals; its cooldown text timer runs only while a cooldown is active. Save requests debounce for 0.35 seconds and immediate saves happen at checkpoints, transitions, boss/quest progression, and quit.

The F3 overlay is hidden unless explicitly enabled in a debug build. It reports FPS, nearby active enemies, active/total projectiles, gameplay-node count, process/physics time and static memory. Shared graphics settings include VSync, frame limit, fullscreen/window size, particles, shake, lighting, damage numbers and post-processing intensity; costly post-processing is off by default.

Profile scenarios, durations, metrics, and current verification status are in [`docs/PERFORMANCE_PROFILE.md`](docs/PERFORMANCE_PROFILE.md).

## Art handoff

`docs/ASSET_REQUESTS.md` contains exact output paths, frame/canvas sizes, animation lists, pivots, collision expectations, pixel-art notes and ready-to-copy prompts. Replace placeholder art through shared `Texture2D` resources; gameplay collision and movement do not depend on sprite dimensions.

## Validation status

Godot 4.7.2 imported and launched the project on macOS. The logic runner passed progression, cooldown, party scaling, inventory, save migration, quest, waypoint, guaranteed loot, boss stagger/root geometry, projectile pooling, and enemy activation checks. The playable-flow runner completed the quest/combat/respawn/save sequence and loaded the same character in a second Godot process. It uses mapped input actions for movement, attack, dodge, Q/E/R, 1/2, F, Tab, Esc, and potion use, and checks that an enemy melee hit damages the player; repeated boss attacks are accelerated by the runner. A rendered macOS profile sampled 60 FPS after warmup through 180 seconds of repeated combat; see the measured limits in the performance report. The macOS desktop session was locked during final checks, so a human-paced GUI playthrough and visual combat feel remain unverified. Windows, integrated graphics, and exact 1920×1080 performance also remain unverified.

## Next phase

See [docs/PHASE1_HANDOFF.md](docs/PHASE1_HANDOFF.md) for the verified Phase 1 flow, requirement-by-requirement status, known limits, and review handoff.

Run a human-paced balance and feel pass on an unlocked macOS or Windows desktop, then profile an integrated-graphics PC at 1920×1080. Replace the highest-impact Human, enemy, boss, and world placeholders using the asset requests before expanding maps, races, or co-op.
