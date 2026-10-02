# Fractureborn

**Fractureborn** is an original top-down pixel-art action RPG built with Godot 4 and GDScript.

The project is currently in early development. Its first playable vertical slice focuses on responsive combat, exploration, character progression, loot, quests, save/load support, boss encounters, and a lightweight architecture designed to scale beyond the prototype.

> Current development branch: [`feat/vertical-slice`](https://github.com/hungdeniubeo/Fractureborn/tree/feat/vertical-slice)

## Project status

**Phase 1 — Playable vertical slice**

The current build contains a complete small gameplay loop:

1. Create or continue a Human character from one of three save slots.
2. Speak with Archivist Edda in Central Village.
3. Travel through the eastern gate into Green Plains.
4. Fight common enemies and activate the Plains waystone.
5. Defeat the Goblin Captain and Ancient Treant bosses.
6. Collect and equip loot, including the Captain's guaranteed Iron Sword drop.
7. Return to the village and complete the quest.
8. Save, quit, and continue the same character later.

Optional exploration includes rune stones, a hidden path, and a chest.

## Current features

### Combat

- Real-time top-down movement and aiming.
- Melee and ranged weapon support.
- Dodge movement.
- Human Sword Art, Weapon Focus, and Battle Instinct abilities with cooldowns.
- Enemy melee and projectile attacks.
- Boss encounters with multiple combat phases.
- Death fade and waypoint-based respawning.

### Progression and equipment

- Character progression up to level 50, tuned around the early-game slice.
- Three separate versioned character save slots.
- Gold, materials, weapons, health potions, and inventory management.
- Training Sword, Iron Sword, Wooden Bow, Basic Pistol, and Basic Shotgun.
- Weapon swapping and equipment support.

### World and enemies

- Central Village and connected Green Plains maps.
- TileMapLayer-based terrain and world layout.
- Camps, obstacles, hidden exploration content, and return routes.
- Slime, Goblin, Goblin Archer, and Goblin Captain enemies.
- Three-phase Ancient Treant boss encounter.
- Two healing and respawn waypoints.

### Systems

- Saved quest progression.
- Persistent character profiles and graphics settings.
- Bounded projectile pooling.
- Distance-based enemy activation and sleeping.
- Chunk-aware world processing.
- Signal-driven HUD updates.
- Debug performance overlay.
- Automated logic and playable-flow validation runners.

## Controls

| Action | Keyboard / mouse | Default controller action |
| --- | --- | --- |
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
| Performance overlay | F3 | Debug builds only |

Controller bindings are defined through Godot's InputMap and can be remapped. Human skills currently have no mana or energy cost.

## Tech stack

| Area | Technology |
| --- | --- |
| Engine | Godot 4.7.x |
| Language | GDScript |
| Rendering | GL Compatibility |
| Game type | 2D top-down action RPG |
| Art direction | Pixel-art style |
| Base viewport | 960 × 540 |
| Physics | 60 ticks per second |
| Persistence | Versioned JSON save data |

The project currently uses runtime and pixel-art-style placeholder assets while the final art direction is being developed. No copyrighted game assets are used by the current vertical slice.

## Run locally

### Requirements

- Godot 4.7.x. The current vertical slice was developed and validated with Godot 4.7.2 stable.
- Git.

### Clone

```bash
git clone https://github.com/hungdeniubeo/Fractureborn.git
cd Fractureborn
git switch feat/vertical-slice
```

Open `project.godot` in Godot and run the project with **F6/F5** or the editor Play button.

From a terminal:

```bash
godot --path .
```

## Validation

The project includes headless logic and playable-flow checks.

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script tests/run_logic_tests.gd
godot --headless --path . --script tests/run_playable_flow.gd
godot --headless --path . --script tests/run_playable_flow.gd -- reopen
```

For a rendered performance profile:

```bash
godot --path . --profiling --script tests/run_performance_profile.gd -- windowed
```

The current macOS validation covers progression, cooldowns, inventory, save migration, quests, waypoints, loot, boss behavior, projectile pooling, enemy activation, combat damage, respawn, and save/reload flow.

A rendered macOS profile maintained 60 FPS after warmup during the existing repeated-combat profile. Human-paced visual feel, Windows behavior, integrated-graphics performance, and exact 1920×1080 profiling still need broader manual validation.

## Save data

Normal character saves are stored under:

```text
user://characters/slot_1.json
user://characters/slot_2.json
user://characters/slot_3.json
```

Graphics settings are stored in:

```text
user://settings.json
```

The automated playable-flow runner uses its own test save path and does not overwrite the normal character slots.

## Performance approach

The vertical slice already includes several systems intended to keep runtime cost predictable as the project grows:

- Shared atlas-backed TileMapLayer ground rendering.
- Separate map scenes partitioned into logical chunks.
- Distance-based sleeping for enemies and interactable objects.
- Enemy decision ticks separated from movement physics.
- Bounded projectile pools with maximum lifetime and travel range.
- Signal-driven HUD updates instead of unnecessary continuous polling.
- Debounced save requests with immediate saves for important progression events.

Detailed profiling notes are available in [`docs/PERFORMANCE_PROFILE.md`](docs/PERFORMANCE_PROFILE.md).

## Project structure

```text
Fractureborn/
├── assets/        # Characters, bosses, enemies, world, UI, weapons, VFX
├── data/          # Game data and configuration resources
├── docs/          # Handoff, asset requests, profiling and design notes
├── scenes/        # Godot scenes and maps
├── scripts/       # Gameplay, systems, UI, save and core logic
├── tests/         # Logic, playable-flow and performance runners
├── project.godot
└── README.md
```

## Documentation

- [`docs/PHASE1_HANDOFF.md`](docs/PHASE1_HANDOFF.md) — Phase 1 flow, requirement status, known limits, and review handoff.
- [`docs/PERFORMANCE_PROFILE.md`](docs/PERFORMANCE_PROFILE.md) — performance scenarios, measurements, limits, and verification notes.
- [`docs/ASSET_REQUESTS.md`](docs/ASSET_REQUESTS.md) — asset requirements, animation lists, dimensions, pivots, collision expectations, and art handoff notes.

## Roadmap

The immediate direction after the vertical slice is to strengthen the existing foundation before expanding scope:

- Complete a human-paced combat and balance pass.
- Improve enemy and boss health/feedback presentation.
- Validate the build on Windows and integrated graphics hardware.
- Replace the highest-impact placeholder character, enemy, boss, world, UI, and VFX assets.
- Continue improving animation and combat feel.
- Expand maps, content, races, and larger systems only after the core loop is stable.

The roadmap intentionally prioritizes polish and validation over adding large amounts of content too early.

## Contributing

Development is still early and the project is primarily being built as a focused game project. Bug reports and focused improvements are welcome.

See [`CONTRIBUTING.md`](CONTRIBUTING.md) for setup, branch, validation, and contribution guidelines.

## License

This repository does not currently include an explicit open-source license. Source code and project assets should not be assumed to be licensed for redistribution or reuse unless a license is added later.
