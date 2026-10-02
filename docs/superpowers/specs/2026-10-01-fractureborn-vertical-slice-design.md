# Fractureborn Phase 1 Vertical Slice

## Goal

Deliver one small, replayable solo loop: create a Human in one of three save slots, take the Green Plains quest, explore and fight, activate a waypoint, defeat the Goblin Captain and Ancient Treant, return to the village, and continue with saved progress after relaunch.

## Architecture

- Godot 4.7.2, GDScript, 2D scenes, keyboard/mouse actions routed through InputMap.
- A small save/profile layer owns per-character state and versioned JSON serialization. Shared services own progression, difficulty, quest state, and waypoint state; UI observes their signals.
- Village and Green Plains are separate scenes. Both use a shared `TileMapLayer` and common world services. Green Plains is authored as one modest map for this slice, with boundaries that allow future zone streaming.
- Player, health, dodge, skills, weapons, projectiles, enemies, and bosses have focused scripts. Static weapons, skills, enemies, and loot use shared Resource definitions.
- Enemies receive AI decisions on a low-frequency manager tick and sleep outside the active radius. Projectiles use a bounded reusable pool, short lifetimes, simple shapes, and team-specific collision masks.
- Placeholder pixel art is drawn or generated in a shared atlas; environmental tiles are reused. UI refreshes on signals, with a short active-only timer for cooldown text. Save requests are debounced and tied to meaningful events.
- Profiling support is opt-in in development builds and reports frame rate, gameplay node counts, and memory/process counters where available.

## Scope and boundaries

Playable content is Human only, levels 1–50 with balance tuned for 1–5, three cooldown skills, five starter weapon definitions, three common enemy types, one mini-boss, one three-phase biome boss, one quest chain, and two waypoints. Networking, other races, future skill evolutions, crafting, and generated worlds are out of scope.

## Performance decisions

Use one TileMapLayer for repeated ground tiles, small numbers of static collision bodies, and grouped draw calls for placeholder decoration. Only nearby enemies run movement/physics; their decisions run less often than rendering. A single world-owned projectile pool is capped and reclaims objects by lifetime/range. No per-decoration scripts, per-frame save writes, or per-frame HUD rebuilds.

## Verification

Add a headless GDScript logic runner for progression, cooldowns, difficulty, inventory, profile migration, quest steps, waypoint activation, and weighted loot. Validate project import/headless startup and walk the full Definition of Done manually when a Godot 4.7.2 executable is available. Profile idle village, exploration, enemy groups, boss combat, and sustained effects using Godot's profiler; correct visible leaks or runaway processing before calling the slice complete.
