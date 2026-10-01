# Phase 1 Performance Profile Checklist

The 60 FPS target is not verified yet. Run this checklist with Godot 4.7.2 on
Windows and macOS at 1920x1080, including at least one integrated graphics
machine. Record hardware, OS, renderer, build type, and whether the profiler or
debug overlay was enabled. The F3 overlay reports FPS, active enemies and
projectiles, gameplay node count, process/physics time, and static memory.

Use the Godot profiler and monitor memory while repeating each scenario. Let
the game settle for 30 seconds before recording values.

| Scenario | Duration | What to check |
| --- | ---: | --- |
| Village idle | 2 min | Low idle CPU, stable node and memory counts, no off-screen enemy work |
| Green Plains exploration | 2 min | Zone activation, transitions, map and HUD costs |
| Several enemies | 2 min | Chase/attack work and projectile collision cost |
| Phase 1 stress | 3 min | Keep up to 12 enemies active with player and enemy projectiles and short VFX |
| Goblin Captain | 2 min | Telegraphs, charge, stagger, loot, and pool reuse |
| Ancient Treant | 3 min | Phase changes, summons, projectiles, and boss UI |
| Repeated combat | 5 min | Compare initial and final node counts, pool size, and memory for growth |

The frame budget at 60 FPS is 16.67 ms. Capture average and worst frame time,
script time, physics time, and memory at the start and end of the repeated
combat run. Investigate any sustained frame over budget, increasing counts,
or objects that keep processing outside the active area. Profile both a normal
build and a debug build; do not use the overlay's readings as a substitute for
the profiler or treat a single machine as proof for both platforms.

## Current status

The implementation provides the F3 overlay and the scenarios above, but this
profile has not been run: Godot is not installed in the current environment.
Record results here after profiling; do not mark the performance target as met
until the Windows and macOS runs are complete.
