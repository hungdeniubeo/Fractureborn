<div align="center">

# FRACTUREBORN

### A top-down pixel-art action RPG built with Godot 4

Explore a fractured world, fight through hostile creatures, grow stronger through combat and loot, and face multi-phase boss encounters.

[![Godot](https://img.shields.io/badge/Godot-4.7.2-478CBF?style=flat-square&logo=godot-engine&logoColor=white)](https://godotengine.org/)
[![GDScript](https://img.shields.io/badge/Language-GDScript-478CBF?style=flat-square&logo=godot-engine&logoColor=white)](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/)
[![Status](https://img.shields.io/badge/Status-Early%20Development-8A2BE2?style=flat-square)](#project-status)
[![Branch](https://img.shields.io/badge/Active%20Branch-feat%2Fvertical--slice-24292F?style=flat-square&logo=github)](https://github.com/hungdeniubeo/Fractureborn/tree/feat/vertical-slice)

**Solo game project · Action RPG · Pixel art · Real-time combat**

[Overview](#overview) · [Features](#features) · [Controls](#controls) · [Run](#run-locally) · [Roadmap](#roadmap) · [Documentation](#documentation)

</div>

---

## Overview

**Fractureborn** is an original 2D top-down action RPG focused on responsive combat, exploration, progression, loot and boss encounters.

The project is currently being developed as a focused playable vertical slice before expanding into a larger game. The goal of this phase is to build and validate the core gameplay foundation first: movement, combat, enemies, bosses, quests, inventory, progression, saving and performance.

> **Development note**  
> The playable game currently lives on [`feat/vertical-slice`](https://github.com/hungdeniubeo/Fractureborn/tree/feat/vertical-slice). The `main` branch is being kept lightweight while the vertical slice is actively developed.

## The current experience

The vertical slice already contains a complete small gameplay loop:

```text
Create character
      ↓
Central Village
      ↓
Accept quest from Archivist Edda
      ↓
Explore Green Plains
      ↓
Fight enemies → gain loot → activate waypoint
      ↓
Goblin Captain
      ↓
Ancient Treant
      ↓
Return to village
      ↓
Complete quest → save → continue later
```

Along the way, the player can discover rune stones, a hidden path and an optional chest.

## Features

| Area | Current implementation |
| --- | --- |
| **Combat** | Real-time movement and aiming, melee/ranged attacks, dodge and three Human combat abilities |
| **Enemies** | Slime, Goblin, Goblin Archer and Goblin Captain |
| **Bosses** | Multi-phase Ancient Treant encounter |
| **Weapons** | Training Sword, Iron Sword, Wooden Bow, Basic Pistol and Basic Shotgun |
| **Progression** | Character leveling, loot, gold, materials, equipment and health potions |
| **World** | Central Village, Green Plains, camps, obstacles, secrets and waypoints |
| **Quests** | Persistent quest progression with saved state |
| **Persistence** | Three versioned character save slots plus graphics settings |
| **Performance** | Enemy sleeping, bounded projectile pooling, chunk-aware processing and signal-driven HUD updates |
| **Testing** | Headless logic tests, playable-flow validation and performance profiling |

### Combat abilities

The current Human character has three cooldown-based abilities:

- **Sword Art** — `Q`
- **Weapon Focus** — `E`
- **Battle Instinct** — `R`

Skills currently do not consume mana or energy. The vertical slice is focused on timing, positioning and weapon usage rather than resource management.

## Controls

| Action | Keyboard / mouse | Controller |
| --- | --- | --- |
| Move | `WASD` | Left stick |
| Aim | Mouse | Right stick |
| Attack | Left mouse | Right trigger |
| Dodge | `Space` | West face button |
| Sword Art | `Q` | Left shoulder |
| Weapon Focus | `E` | Right shoulder |
| Battle Instinct | `R` | D-pad up |
| Weapon slots | `1` / `2` | InputMap |
| Interact | `F` | North face button |
| Pack / map | `Tab` | Back / View |
| Health potion | `H` | South face button |
| Pause | `Esc` | Start |
| Performance overlay | `F3` | Debug builds only |

Controller mappings are defined through Godot's InputMap and can be remapped.

## Tech stack

<div align="center">

| | |
| --- | --- |
| **Engine** | Godot 4.7.x |
| **Language** | GDScript |
| **Genre** | 2D top-down action RPG |
| **Rendering** | GL Compatibility |
| **Art direction** | Pixel-art style |
| **Base viewport** | 960 × 540 |
| **Physics** | 60 ticks / second |
| **Persistence** | Versioned JSON |

</div>

The project currently uses original runtime and pixel-art-style placeholder assets while the final art direction is being developed. No copyrighted game assets are used by the current vertical slice.

## Project status

**Current phase: Playable Vertical Slice**

The core gameplay loop is functional and automated validation is already in place. Current work is focused more on **feel, presentation and validation** than rapidly adding new content.

### Working now

- Character creation and three save slots
- Village → plains → boss → return gameplay loop
- Melee and ranged combat
- Loot, equipment and inventory
- Level progression
- Quest persistence
- Waypoint healing and respawn
- Multi-phase boss logic
- Save / quit / continue flow
- Performance instrumentation
- Automated gameplay validation

### Still being refined

- Enemy HP and combat feedback presentation
- Human-paced combat balance and feel
- Animation and visual polish
- Final character, enemy, boss, world, UI and VFX art
- Windows and integrated-graphics validation
- Wider 1920×1080 performance testing

## Run locally

### Requirements

- **Godot 4.7.x** — the current slice is validated with Godot **4.7.2 stable**
- **Git**

### Clone the active development build

```bash
git clone https://github.com/hungdeniubeo/Fractureborn.git
cd Fractureborn
git switch feat/vertical-slice
```

Open `project.godot` in Godot and press **F6/F5** or use the editor Play button.

Or launch from a terminal:

```bash
godot --path .
```

<details>
<summary><strong>Validation commands</strong></summary>

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script tests/run_logic_tests.gd
godot --headless --path . --script tests/run_playable_flow.gd
godot --headless --path . --script tests/run_playable_flow.gd -- reopen
```

Rendered performance profile:

```bash
godot --path . --profiling --script tests/run_performance_profile.gd -- windowed
```

</details>

## Save data

Character profiles:

```text
user://characters/slot_1.json
user://characters/slot_2.json
user://characters/slot_3.json
```

Graphics settings:

```text
user://settings.json
```

Automated playable-flow tests use a separate test save path and do not overwrite normal character slots.

## Architecture and performance

The vertical slice is intentionally structured so the project can grow without making every object process every frame.

Key runtime decisions include:

- Atlas-backed `TileMapLayer` terrain
- Separate map scenes with logical chunk partitioning
- Distance-based sleeping for enemies and interactables
- Enemy AI decision ticks separated from movement physics
- Bounded projectile pools with lifetime and travel limits
- Signal-driven HUD updates
- Debounced save requests with immediate saves for major progression events
- Debug-only performance overlay

A rendered macOS profile maintained **60 FPS after warmup** during the current repeated-combat profile. Broader hardware testing is still planned.

## Project structure

```text
Fractureborn/
├── assets/        # Characters, bosses, enemies, world, UI, weapons, VFX
├── data/          # Game data and configuration resources
├── docs/          # Handoff, profiling, design and asset notes
├── scenes/        # Godot scenes and maps
├── scripts/       # Gameplay, systems, UI, save and core logic
├── tests/         # Logic, flow and performance runners
├── project.godot
└── README.md
```

## Documentation

More detailed development notes live on the active branch:

- [`PHASE1_HANDOFF.md`](https://github.com/hungdeniubeo/Fractureborn/blob/feat/vertical-slice/docs/PHASE1_HANDOFF.md) — verified Phase 1 flow, requirement status and known limits
- [`PERFORMANCE_PROFILE.md`](https://github.com/hungdeniubeo/Fractureborn/blob/feat/vertical-slice/docs/PERFORMANCE_PROFILE.md) — profiling scenarios, measurements and verification notes
- [`ASSET_REQUESTS.md`](https://github.com/hungdeniubeo/Fractureborn/blob/feat/vertical-slice/docs/ASSET_REQUESTS.md) — asset sizes, animation lists, pivots, collision expectations and art handoff notes

## Roadmap

The next steps intentionally prioritize **polish before scope expansion**:

- Improve enemy HP, hit feedback and combat readability
- Complete a human-paced balance and feel pass
- Improve animation, VFX and moment-to-moment responsiveness
- Validate Windows and integrated-graphics performance
- Replace high-impact placeholder art
- Polish UI and world presentation
- Expand maps, enemies, races and larger systems only after the core loop is stable

## Development philosophy

Fractureborn is being built **core-first**.

Instead of expanding the world immediately, the project aims to make a small section of the game genuinely playable, testable and performant first. New content can then build on a foundation that has already survived real gameplay, saving, combat and performance testing.

---

<div align="center">

**Fractureborn is in active early development.**

Built with Godot and GDScript.

[View active development branch](https://github.com/hungdeniubeo/Fractureborn/tree/feat/vertical-slice)

</div>

## License

No explicit open-source license has been added yet. Source code and project assets should not be assumed to be licensed for redistribution or reuse unless a license is added later.
