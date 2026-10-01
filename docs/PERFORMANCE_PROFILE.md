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

## Measured macOS run

Godot 4.7.2 stable, Compatibility renderer (OpenGL 4.1 Metal), macOS 26.5,
Apple M4 with 16 GB RAM. The rendered game window measured `1920x962`; macOS
constrained its height below the requested 1080 pixels. The run used
`--profiling` and Godot `Performance` monitors, a 30-second warmup per scenario,
and a three-minute repeated-combat segment. These monitor samples are not a
captured editor Profiler timeline. The desktop was locked, so no human-paced
combat or visual inspection was possible during this run.

| Scenario | Sample duration | FPS mean / lowest sample | Max active enemies / projectiles | Max nodes | Highest sampled process / physics ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| Village idle | 15 s | 60.1 / 59 | 0 / 0 | 144 | 7.75 / 1.33 |
| Plains exploration | 15 s | 60.0 / 60 | 5 / 1 | 198 | 12.03 / 12.55 |
| Several enemies | 15 s | 60.0 / 60 | 8 / 1 | 198 | 8.39 / 1.46 |
| Phase 1 stress | 20 s | 60.0 / 60 | 18 / 1 | 218 | 15.40 / 1.82 |
| Goblin Captain | 15 s | 60.0 / 59 | 18 / 2 | 218 | 6.13 / 2.10 |
| Ancient Treant | 20 s | 59.9 / 58 | 18 / 2 | 218 | 7.83 / 12.24 |
| Boss and projectiles | 20 s | 60.0 / 59 | 22 / 6 | 228 | 25.82 / 12.13 |
| Repeated combat | 180 s | 60.0 / 60 | 21 / 6 | 224 | 18.13 / 25.55 |

Static memory was 37.4 MB in the village, 38.4 MB in normal Plains play, and
38.7 MB at both the start and end of repeated combat. No Godot errors appeared
in the corrected full run. The highest sampled process and physics values show
isolated frames over the 16.67 ms budget; the FPS monitor samples did not show
a sustained slowdown. Use the editor Profiler on an unlocked desktop to locate
those spikes and verify visual smoothness.

After the camera-boundary and HUD positioning adjustment, a short rendered
follow-up still sampled 60 FPS in the 17-enemy stress and boss/projectile
scenarios, with no Godot errors.

The 1920x1080 target, Windows, integrated graphics, lower-end PCs, and a full
human-paced GUI playthrough remain unverified. Re-run the checklist above on
those targets before treating the cross-platform 60 FPS goal as established.
