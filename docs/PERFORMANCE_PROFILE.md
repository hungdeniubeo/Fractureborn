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

## Measured macOS run, 2026-10-02

Godot 4.7.2 stable, Compatibility renderer (OpenGL 4.1 Metal), macOS 26.5,
Apple M4 with 16 GB RAM. The rendered game window measured `1920x962`; macOS
constrained its height below the requested 1080 pixels. The run used
`--profiling` and Godot `Performance` monitors, a 30-second warmup per scenario,
and a three-minute repeated-combat segment after the boss warning and loot
changes. These monitor samples are not a captured editor Profiler timeline.
The desktop was locked, so no human-paced GUI combat was possible; offscreen
Godot viewport captures were inspected separately.

| Scenario | Sample duration | FPS mean / lowest sample | Max active enemies / projectiles | Max nodes | Highest sampled process / physics ms |
| --- | ---: | ---: | ---: | ---: | ---: |
| Village idle | 15 s | 60.0 / 60 | 0 / 0 | 144 | 11.56 / 1.19 |
| Plains exploration | 15 s | 60.0 / 60 | 5 / 1 | 198 | 10.18 / 1.53 |
| Several enemies | 15 s | 60.0 / 60 | 8 / 1 | 198 | 19.40 / 1.59 |
| Phase 1 stress | 20 s | 60.0 / 59 | 18 / 1 | 218 | 12.84 / 1.72 |
| Goblin Captain | 15 s | 60.0 / 60 | 18 / 2 | 218 | 8.05 / 1.72 |
| Ancient Treant | 20 s | 60.0 / 60 | 18 / 2 | 218 | 10.93 / 1.78 |
| Boss and projectiles | 20 s | 60.0 / 60 | 22 / 5 | 228 | 17.35 / 3.84 |
| Repeated combat | 180 s | 60.0 / 60 | 21 / 8 | 224 | 12.87 / 3.69 |

Static memory was 37.4 MB in the village, 38.4 MB in normal Plains play, and
38.7 MB at the start and 38.8 MB at the end of repeated combat. No Godot errors
appeared in the full run. The highest sampled process values include isolated
frames over the 16.67 ms budget; the FPS monitor samples did not show a
sustained slowdown. A rapid smoke profile with only 0.5 seconds of warmup
sampled 19 FPS and 115.65 ms process time in the initial village seconds,
which needs an unlocked desktop feel check. Use the editor Profiler on that
desktop to locate any perceptible spikes and verify visual smoothness.

The 1920x1080 target, Windows, integrated graphics, lower-end PCs, and a full
human-paced GUI playthrough remain unverified. Re-run the checklist above on
those targets before treating the cross-platform 60 FPS goal as established.

## Editor-authored map follow-up

After moving the ground and placed objects into the map scenes, the quick
headless profile was rerun on macOS with Godot 4.7.2. It reported 60 FPS in
Plains exploration, several-enemy, stress, both boss, boss-projectile, and
repeated-combat samples. Those samples reached 18 active enemies, 7 pooled
projectiles, and 332 nodes, with at most 5.38 ms physics and 4.75 ms process
time. Village startup included the expected short headless/import spike
(44.1 FPS mean over the two-second sample and one 84.12 ms process sample);
the longer warmed-up village measurement above remains the representative
idle result. This quick check does not change the unverified Windows,
integrated-GPU, 1920x1080, or human-paced playtest status.
