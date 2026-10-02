# Phase 1 handoff

## Current state

- Branch: `feat/vertical-slice`, tracking `origin/feat/vertical-slice`. `main` remains at the initial commit.
- Latest implementation commit when this report was drafted: `5dbf64dfab4f9c27136e32dc12e197864823a220`. This documentation commit advances the branch tip; use `git rev-parse HEAD` for its final SHA.
- Engine: Godot 4.7.2 stable, GDScript, 2D Compatibility renderer.
- Tested platform: macOS 26.5 on Apple M4 with 16 GB RAM. Windows has not been run.

## Implemented slice

- Three independent, versioned Human save slots. All five race identifiers are defined; only Human has a playable resource and can be selected.
- Central Village and a connected, semi-open Green Plains map with camps, obstacles, a hidden rune path, a chest, waystones, and separate map scenes.
- One saved quest chain, `Trouble in Green Plains`, from Archivist Edda through five monster kills, the Plains waystone, Goblin Captain, Ancient Treant, and village turn-in.
- Eight-direction movement, aiming, melee arcs, pooled ranged projectiles, five weapon definitions, dodge with invulnerability, Q/E/R Human skills with cooldowns and no mana, and a health potion.
- Slime, Goblin, Goblin Archer, Goblin Captain, and a three-phase Ancient Treant with telegraphs, summons, stagger, and boss HP UI.
- EXP and levels 1–50, gold/material/weapon drops, six rarity identifiers, inventory categories, equipment slots, and save-preserving death/respawn. Captain loot guarantees an Iron Sword.
- Tile-based terrain, map chunks, distant-enemy sleep, low-frequency AI, bounded projectile pooling, narrow collision masks, signal-driven HUD updates, debounced saves, performance settings, and an F3 debug overlay.

## Current playable flow

Launch `project.godot` in Godot 4.7.2, create or continue a Human in one of three slots, and spawn in Central Village. Talk to Edda, take the eastern gate to Green Plains, defeat five common enemies, activate the Plains waystone, use weapons/dodge/Q/E/R and potions, and collect drops. The rune puzzle and chest are optional. Defeat the Captain, collect and optionally equip his Iron Sword, defeat the Treant, then return through the western gate and turn in the quest. The pause menu provides save/quit; continuing the same slot restores progression. The automated runner covers this route and a second-process reload, while the native pause-menu quit and human-paced combat still need a manual GUI pass.

## Controls

| Action | Keyboard/mouse |
| --- | --- |
| Move / aim / attack | WASD / mouse / left mouse button |
| Dodge | Space |
| Sword Art / Weapon Focus / Battle Instinct | Q / E / R |
| Weapon slots | 1 / 2 |
| Interact / pack and map / pause | F / Tab / Esc |
| Health potion | H |
| Development performance overlay | F3 in debug builds |

Controller actions are defined in `scripts/core/input_actions.gd`; controller feel has not been validated.

## Architecture map

| Area | Primary files and responsibility |
| --- | --- |
| Boot, profile, disk saves | `scenes/ui/save_select.tscn`, `scripts/ui/save_select.gd`, `scripts/core/game_session.gd`, `scripts/save/character_profile.gd`, `scripts/save/save_service.gd`: slot selection, session state, versioned serialization, debounced writes. |
| Maps and checkpoints | `scenes/world/*.tscn`, `data/world/*_tileset.tres`, `scripts/world/world_base.gd`, `world_chunk.gd`, `waypoint_manager.gd`: editor-authored TileMapLayer terrain, placed actors/spawn markers, scene transitions, nearby chunks, waystones, respawn. |
| Player and combat | `scripts/player/player_controller.gd`, `scripts/combat/{health_component,dodge_component,weapon_controller,projectile_pool}.gd`: input, health, invulnerability, weapon attacks, projectile reuse. |
| Skills and progression | `scripts/skills/{skill_controller,skill_definition}.gd`, `scripts/core/{progression,race_data,difficulty_scaler}.gd`: cooldown skills, levels, race IDs, centralized party scaling. |
| Enemies and bosses | `scripts/enemies/{enemy_controller,enemy_activation_manager,boss_controller}.gd`, `data/enemies/`: shared enemy behavior, AI activation, telegraphed boss patterns and stagger. |
| Quest, loot, inventory | `scripts/quests/quest_tracker.gd`, `scripts/loot/{loot_table,loot_service}.gd`, `scripts/inventory/inventory_model.gd`, `data/{quests,loot,weapons}/`: saved objectives, weighted/guaranteed drops, item storage. |
| UI and settings | `scripts/ui/{hud,inventory_panel,map_panel,pause_menu,debug_overlay}.gd`, `scripts/core/performance_settings.gd`: player-facing information and optional diagnostics. |

## Tests and validation

- On this handoff run, Godot 4.7.2 headless editor import finished without parse/runtime errors.
- `tests/run_logic_tests.gd` passed EXP/level cap, cooldown, difficulty scaling, inventory, save round-trip/migration, quest, waypoint, loot, boss stagger/root geometry, projectile pool, and enemy activation checks.
- `tests/run_playable_flow.gd` passed mapped-input movement/combat/dodge/skills, enemy damage, potion, EXP/level, pickups, puzzle/chest, waypoint, death/boss reset, both boss defeats, quest turn-in, and save. Boss attacks are accelerated by the runner.
- A separate Godot process running `tests/run_playable_flow.gd -- reopen` passed loading the same isolated test save with equipment, quest, boss, waypoint, puzzle, and chest progression preserved. The runner writes under `user://tests/flow_characters/`, outside the normal slots.
- All four commands above exited successfully. Their logs contained no `ERROR`, `WARNING`, or parse-failure lines. A human-paced GUI playthrough was unavailable because the macOS desktop session was locked.

## Performance

The rendered macOS profile used a 30-second warmup for each scenario at an actual `1920x962` window. Its 180-second repeated-combat sample averaged 60.0 FPS (lowest monitor sample 60), reached 21 active enemies and 8 projectiles, and measured static memory from 38.7 to 38.8 MB. A boss-plus-projectiles sample reached 22 enemies and 228 nodes. Some isolated process-time samples exceeded the 16.67 ms frame budget; an unlocked editor Profiler and visual smoothness check remain necessary. Measurements and the full checklist are in [PERFORMANCE_PROFILE.md](PERFORMANCE_PROFILE.md).

## Known limits and asset status

- Native manual game-feel, boss balance, pause-menu Save & Quit, and controller play have not been tested end to end. The automated flow is evidence for system behavior, not a substitute for that pass.
- Windows, integrated GPUs, low/mid-range PCs, and exactly 1920x1080 have not been tested. This run used an Apple M4 and a macOS-constrained 1920x962 window.
- Characters, enemies, bosses, props, icons, and VFX use procedural or placeholder visuals; map composition and UI layout are editor-authored. [ASSET_REQUESTS.md](ASSET_REQUESTS.md) specifies replacement visual assets and generation prompts. Authored music/SFX and an audio asset handoff are not present yet.
- Online co-op, companions, PvP, other playable races, full Level 50 skill evolution, additional biomes, crafting, procedural generation, and optional waypoint fast travel are intentionally deferred.

## Phase 1 definition of done

`DONE` means the stated behavior was verified by the automated Godot run or a specific logic check. `PARTIAL` means implementation exists but the named manual path or a required subcase remains unverified. `NOT DONE` is reserved for work absent from this slice. The **complete human-paced manual loop is PARTIAL**.

| Original playable-loop step | Status | Evidence or remaining gap |
| --- | --- | --- |
| 1. Launch game | DONE | Godot project imported/launched; save-select scene loads. |
| 2. Create/select Human slot | DONE | Flow creates a Human slot and reloads it. |
| 3. Enter game world | DONE | Flow enters Central Village. |
| 4. Walk around village | DONE | Mapped movement changes player position. |
| 5. Accept quest | DONE | Edda interaction changes quest state. |
| 6. Enter Green Plains | DONE | Gate transition loads the Plains scene. |
| 7. Fight enemies | DONE | Sword hit and pooled projectile kill are asserted. |
| 8. Dodge attacks | PARTIAL | Cooldown/invulnerability are asserted; a human dodge against a live attack is untested. |
| 9. Use Q/E/R | PARTIAL | All inputs, cooldowns, and buffs activate; human-paced Sword Art hit/feel is untested. |
| 10. Gain EXP | DONE | Enemy deaths award EXP. |
| 11. Level up | DONE | Flow reaches level 2; logic checks level 50 cap. |
| 12. Collect gold/materials/weapons | PARTIAL | Gold and Iron Sword pickups are asserted; material pickup quantity is not independently asserted. |
| 13. Activate waypoint | DONE | Plains activation persists. |
| 14. Die | DONE | Lethal damage starts the death sequence. |
| 15. Respawn at activated waypoint | DONE | Flow checks Plains position and retained progression. |
| 16. Fight mini-boss | DONE | Weapon attacks defeat Captain; loot and boss reset are asserted. |
| 17. Fight biome boss | PARTIAL | Weapon attacks defeat Treant and phase/root logic is tested; a paced three-phase fight is untested. |
| 18. Receive boss loot | DONE | Boss pickups spawn; Captain's Iron Sword is collected and persisted. |
| 19. Return to village | DONE | West gate transition is asserted. |
| 20. Save progress | DONE | Explicit save writes the completed character. |
| 21. Quit | PARTIAL | Test process exits; pause-menu Save & Quit has not been manually exercised. |
| 22. Reopen game | DONE | Reopen test runs in a separate Godot process. |
| 23. Continue saved character | DONE | Reopen assertions cover major progression and equipment. |

| Supporting Phase 1 requirement | Status | Evidence or remaining gap |
| --- | --- | --- |
| Godot 4.7.2, GDScript, 2D, 32x32 tiles | DONE | Imported project, resource definitions, TileMapLayer maps. |
| macOS and Windows PC target | PARTIAL | macOS run only. |
| Three isolated/versioned slots; Human only; five race IDs | DONE | Save tests, selection flow, race catalog. |
| Reusable party difficulty scaling, currently one player | DONE | Centralized 1–4-player multipliers pass logic checks; networking is deferred. |
| Eight-direction movement and mouse aim | PARTIAL | Movement and mapped aim used; native mouse-aim feel untested. |
| Dodge and reusable cooldowns; no mana | DONE | Dodge/cooldown checks and skill data; no mana resource. |
| Five distinct weapon definitions | PARTIAL | All five definitions exist; every weapon's real-time handling is not playtested. |
| Slime, Goblin, Goblin Archer AI | PARTIAL | Spawn/combat paths run; full behavior and pacing are not manually assessed. |
| Captain combo/charge and Treant three-phase patterns | PARTIAL | Bosses are defeated, phase/stagger/root logic checked; paced telegraph avoidance is untested. |
| Green Plains camps, hidden path, chest, puzzle; village NPC/forge/shop placeholders | DONE | Scene content exists; rune/chest/route are asserted. |
| Quest state, waypoint activation/heal/respawn | PARTIAL | Quest, activation and respawn asserted; healing at a waypoint is implemented but not separately asserted. |
| Levels 1–50, data-driven loot, six rarity identifiers | DONE | Logic checks cap/loot; rarity enum in weapon data. |
| Inventory categories, equip, tooltip; potion; HUD | PARTIAL | Equip, potion and panel opening asserted; tooltip and all HUD states need a manual UI pass. |
| Health Potion quick-use and limited quantity | DONE | Flow asserts healing and one consumed potion. |
| Chunk/AI sleep, projectile pool, narrow collision, debounced saves | DONE | Implementation and pool/activation logic checks; rendered stress profile completed. |
| Stable 60 FPS on both target platforms at 1920x1080 | PARTIAL | Measured on one Mac at 1920x962 only. |
| F3 overlay and graphics-settings structure | PARTIAL | Implemented; overlay display/settings UX not manually exercised. |
| Real visual/audio assets | NOT DONE | Allowed placeholders in Phase 1; visual requests documented, authored audio absent. |
| Optional waypoint fast travel | NOT DONE | Deferred optional feature. |
| Online multiplayer, other races, extra biomes, full evolution | NOT DONE | Explicitly excluded from Phase 1 scope. |

## Recommended next steps

1. Perform a human-paced complete GUI playthrough on an unlocked desktop, including mouse aim, boss avoidance, Save & Quit, and controller spot checks.
2. Profile an integrated-GPU Windows PC at exactly 1920x1080 and capture the editor Profiler timeline for frame spikes and transitions.
3. Tune boss/weapon feel from that playtest and add focused assertions for waypoint healing, material counts, and pause-menu exit if gaps appear.
4. Produce the highest-impact replacement art from [ASSET_REQUESTS.md](ASSET_REQUESTS.md) and define a small original music/SFX handoff.
