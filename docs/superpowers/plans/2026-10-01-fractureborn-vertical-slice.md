# Fractureborn Phase 1 Vertical Slice Implementation Plan

> **For agentic workers:** Execute inline with `superpowers:executing-plans`; keep the work on `feat/vertical-slice` and commit each completed task.

**Goal:** Build the first replayable solo gameplay loop from character creation through boss defeat and saved return to the village.

**Architecture:** Versioned character profiles and small services own persistent state. Separate world scenes share focused gameplay components and Resource definitions. TileMapLayer handles repeated ground; nearby-zone activation sleeps distant enemies; pooled projectiles and event-driven HUD/save updates keep idle work low.

**Tech Stack:** Godot 4.7.2 stable, GDScript, built-in Resources, scenes and TileMapLayer; headless GDScript tests.

**Spec:** `docs/superpowers/specs/2026-10-01-fractureborn-vertical-slice-design.md` and the user's Fractureborn brief.

## Global Constraints

- PC first, macOS + Windows, 1920×1080, 60 FPS target, 32×32 tiles, 48×48 character frames.
- No mana, multiplayer, PvP, other playable races, copied game assets, or final-art dependency.
- Exactly one Human character per slot; three slots; max level 50; cooldown-based skills.
- Keep performance settings centralized; profiling/debug overlay is opt-in.
- Run Godot validation only if a Godot executable is available; never claim unrun checks.

## Review Focus

- Save input: missing, old-version, and invalid-race profiles retain a valid Human profile without losing supported fields (Task 1 tests).
- Progression boundary: large EXP awards stop at level 50 and preserve remainder rules (Task 1 tests).
- Inventory boundary: stack removal cannot make a count negative; weapon pickup/equip stays valid (Task 1 tests).
- Cooldown boundary: an unavailable skill/dodge cannot trigger again until ready (Task 1 tests).
- World scale: enemies beyond active radius stop AI/physics; projectiles reclaim after lifetime/range and cannot hit the wrong team (Task 2 tests/review).

## Task 1: Project foundation and pure gameplay models

**Files:** `project.godot`, `.gitignore`, `scripts/core/{race_data,progression,difficulty_scaler,cooldown}.gd`, `scripts/save/{character_profile,save_service}.gd`, `scripts/inventory/inventory_model.gd`, `scripts/quests/quest_tracker.gd`, `scripts/world/waypoint_registry.gd`, `scripts/loot/loot_table.gd`, `tests/run_logic_tests.gd`.

- [ ] Scaffold Godot settings, actions, collision layers, nearest texture filtering, and save/test paths.
- [ ] Write the headless logic tests first for leveling, caps, cooldowns, difficulty values, stack add/remove, profile round-trip/migration, quest progression, waypoint activation, and deterministic weighted loot.
- [ ] Implement small typed models/services that satisfy the tests; preserve all profile fields through JSON serialization and version migration.
- [ ] Verify with `godot --headless --path . --script tests/run_logic_tests.gd` and `godot --headless --path . --editor --quit` when available.
- [ ] Commit as `feat: scaffold project and persistent gameplay models`.

## Task 2: Player combat, shared data, enemies, and object reuse

**Files:** `scripts/player/player_controller.gd`, `scripts/combat/{health_component,dodge_component,weapon_definition,weapon_controller,projectile,projectile_pool}.gd`, `scripts/skills/{skill_definition,skill_controller}.gd`, `scripts/enemies/{enemy_definition,enemy_controller,enemy_activation_manager,boss_controller}.gd`, `scripts/loot/loot_service.gd`, `data/{skills,weapons,enemies,loot}/*`, `scenes/{player,enemies,weapons}/*.tscn`.

- [ ] Add data-driven five-weapon catalog, generic skill effects, health/dodge components, and Player actions.
- [ ] Add melee/projectile combat, capped pool, team collision layers, expiry by lifetime/range, and impact feedback.
- [ ] Add low-frequency enemy decisions, active-radius sleep/wake management, Slime/Goblin/Archer behaviors, stagger, Goblin Captain telegraph/combo/charge, and Treant phases/summons.
- [ ] Add or extend logic tests for projectile reclaim/pool cap and activation-radius state changes; run all available logic tests and project validation.
- [ ] Commit as `feat: add player combat and scalable enemy encounters`.

## Task 3: Village, Green Plains, quest route, and reactive HUD

**Files:** `scripts/world/{world_base,village_world,green_plains_world,world_chunk,interactable,waypoint_manager}.gd`, `scripts/ui/{hud,inventory_panel,pause_menu,debug_overlay}.gd`, `scenes/world/*.tscn`, `scenes/ui/*.tscn`, `assets/placeholders/*`, `data/races/*`.

- [ ] Build tile-atlas floor layers, obstacle collision, clustered placeholder decoration, village services, camps, hidden path, chest, puzzle, Captain area, Plains waypoint, and Treant arena.
- [ ] Wire quest NPC accept/turn-in, kill count, map entry, waypoint, both boss rewards, village return, death fade/respawn, and boss reset on death.
- [ ] Display HP/EXP/level/weapon/potions/quest and Q/E/R/dodge cooldowns; use signals for changed data and a short active-only cooldown timer.
- [ ] Add inventory equip/switch/tooltip/consumable use, pause/save/quit flow, debounced meaningful saves, and development-only F3 performance overlay.
- [ ] Verify map transitions, sleeping enemies, quest/waypoint/boss flags and signal-driven UI with tests or headless checks when available.
- [ ] Commit as `feat: connect village and Green Plains gameplay loop`.

## Task 4: Slot selection, handoff documentation, and final review

**Files:** `scripts/ui/save_select.gd`, `scenes/ui/save_select.tscn`, `scripts/core/game_session.gd`, `scripts/core/performance_settings.gd`, `docs/ASSET_REQUESTS.md`, `README.md`, tests as needed.

- [ ] Add three-slot create/load flow and persist all required character fields; launch at slot selection and continue into the saved map.
- [ ] Add centralized graphics/performance settings structure and document setup, controls, run/test commands, performance architecture, and current slice boundaries.
- [ ] Record each placeholder asset with exact dimensions, frames, destinations, style, and copy-ready generation prompt.
- [ ] Re-run all available checks, inspect the final diff for coupling/performance traps, and walk the manual completion path if Godot is installed.
- [ ] Commit as `docs: document playable vertical slice and art requests`.
