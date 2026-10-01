# Fractureborn

Fractureborn is an original top-down pixel-art action RPG. This repository contains its first small solo vertical slice, built with Godot 4.7.2 stable and GDScript.

## Run

1. Install Godot 4.7.2 stable.
2. Open `project.godot` in the Godot Project Manager and let the project import.
3. Run the project (F6/F5 or the play button). It opens at the three character slots.

From a terminal:

```sh
godot --path .
godot --headless --path . --script tests/run_logic_tests.gd
godot --headless --path . --editor --quit
```

Saves are stored under `user://characters/slot_1.json` through `slot_3.json`; graphics settings are stored in `user://settings.json`.

## Current slice

- Three separate Human character slots with versioned JSON profiles.
- Central Village and connected Green Plains scenes with TileMapLayer terrain, simple obstacles, camps, a hidden rune path/chest, and a return route.
- One saved quest chain, two healing/respawn waypoints, gold/material/weapon loot, inventory and health potions.
- Level progression through 50, tuned for early levels; Human Sword Art, Weapon Focus, and Battle Instinct use cooldowns.
- Training Sword, Iron Sword, Wooden Bow, Basic Pistol, and Basic Shotgun.
- Slime, Goblin, Goblin Archer, Goblin Captain, and three-phase Ancient Treant.
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

Profile scenarios, durations, metrics, and current verification status are in [`docs/PERFORMANCE_PROFILE.md`](docs/PERFORMANCE_PROFILE.md). Godot is unavailable in this environment, so the 60 FPS target has not been measured.

## Art handoff

`docs/ASSET_REQUESTS.md` contains exact output paths, frame/canvas sizes, animation lists, pivots, collision expectations, pixel-art notes and ready-to-copy prompts. Replace placeholder art through shared `Texture2D` resources; gameplay collision and movement do not depend on sprite dimensions.

## Validation status

Godot 4.7.2 was not installed in the implementation environment. The logic runner, editor import, manual gameplay flow, and profiler scenarios have not been executed here. Do not treat the performance target as verified until Godot profiler checks run on Windows and macOS at 1920×1080.

The GDScript logic runner covers progression/level caps, cooldowns, party scaling, inventory bounds, save round-trip/migration, quest steps, waypoint activation and weighted loot. Godot 4.7.2 must be installed to execute that runner, import the project, or profile the required idle/exploration/enemy/boss scenarios. Do not treat the 60 FPS target as verified until those Godot profiler checks are run on Windows and macOS at 1920×1080.

## Next phase

Install the requested Godot version and execute the end-to-end manual flow and profiler checklist in the brief. Fix any runtime/import or performance findings, then replace the highest-impact Human, enemy, boss, and world placeholders using the asset requests. Expand zone streaming and co-op only after the slice is measured.
