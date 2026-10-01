# Fractureborn Phase 1 Asset Requests

All assets must be original and made for Fractureborn. Keep nearest-neighbor pixel edges, use a limited readable palette, and do not reference or imitate existing game art.

## Human Base Character

Destination: `res://assets/characters/human/human_base.png`

Frame size: `48x48`

Directions:
- down
- left
- right
- up

Animations:
- idle: 4 frames per direction
- walk: 6 frames per direction
- attack: 6 frames per direction
- dodge: 4 frames per direction
- hit: 2 frames per direction
- downed: 4 frames, down-facing

Perspective: top-down 3/4, feet/pivot centered at `(24, 39)`. Transparent background. Collision stays a separate radius-12 circle centered near the feet; art dimensions must not define gameplay collision.

Style: original frontier-fantasy traveler, clear face/weapon silhouette, muted teal cloth with warm leather and a small amber accent, crisp clusters, no anti-aliasing, no gradients, no text.

Prompt: `Create an original 2D pixel-art sprite sheet for Fractureborn, a frontier fantasy action RPG. One agile human adventurer with teal travel coat, warm leather straps, dark boots, short dark hair, and a simple training sword. Top-down three-quarter view. Arrange a transparent sprite sheet in labeled-by-position rows (no written labels): down, left, right, up. Each direction row contains idle 4 frames, walk 6, sword attack 6, dodge 4, hit 2; final down-facing row contains downed 4 frames. Every cell exactly 48x48 pixels, consistent centered feet pivot at x=24 y=39. Distinct poses, readable silhouette, original design, tight palette, chunky clean pixel clusters, crisp nearest-neighbor pixels, no antialiasing, no blur, no background, no shadows outside the cells.`

## Green Plains Ground Atlas

Destination: `res://assets/world/green_plains/green_plains_atlas.png`

Frame size: `32x32` tiles in a `256x256` atlas (8x8 cells)

Tiles: grass A/B/C, two grass transitions, dirt path straight/corner/junction, short grass, flower accents, rock ground, arena moss, water edge. Seamless edges for repeatable ground tiles. No scripts or per-tile animation. Use Godot TileSet atlas regions.

Style: warm green field, dusty ochre trail, cool slate stones; readable at 1x zoom; subtle clusters that remain calm during combat. Transparent pixels only for transition/decal cells.

Prompt: `Draw an original seamless 8 by 8 atlas of 32x32 pixel tiles for Fractureborn's Green Plains, a connected open grassland with one winding ochre dirt trail. Include multiple subtly varied grass tiles, clean grass-to-dirt edges, path straight/corners/junctions, short grass, a few tiny flower tufts, slate rock ground and mossy arena ground. Consistent top-down 3/4 pixel-art perspective, limited natural palette, pixel clusters readable when enlarged with nearest-neighbor, no antialiasing, no baked grid lines, no text, no copyrighted or recognizable existing-game motifs. Transparent pixels only on transition/decal cells.`

## Central Village Ground Atlas

Destination: `res://assets/world/village/village_atlas.png`

Frame size: `32x32` tiles in a `256x256` atlas (8x8 cells)

Tiles: village grass, stone/dirt footpath, plaza paving, path transitions, well paving, garden edge, worn threshold. Ground tiles only; props remain separate atlas entries in a later request.

Style: welcoming, handmade frontier hamlet; warm tan paving against the same family of greens as the Plains. Lossless import, no mipmaps, transparent transition edges where useful.

Prompt: `Create an original 8x8 atlas of 32x32 pixel-art floor tiles for Fractureborn's small frontier village. Include calm green grass variants, warm worn footpath, a compact pale-stone plaza, path-to-grass transitions, well paving, garden edges, and cottage thresholds. Top-down 3/4 perspective, clean repeatable edges, restrained warm palette, crisp pixel clusters, no antialiasing, no text, no character or building sprites, no recognizable existing-game content.`

## Common Enemies: Slime, Goblin, and Archer

Destination: `res://assets/enemies/green_plains/common_enemies.png`

Frame size: `48x48`; three separate horizontal strips, one character per row.

Directions and animations per row:
- down/left/right/up: idle 2 frames and move 4 frames
- attack: 4 frames in the direction used by the pose
- hurt: 2 frames
- death: 4 frames

Style: slime is a compact springy green blob, goblin is a quick ochre-green scavenger, archer has a distinct bow silhouette and rust sash. Transparent background, feet pivot `(24, 40)`, no pixel-precise collision; gameplay uses circles.

Prompt: `Design three original small enemy sprite strips for Fractureborn's Green Plains: a slow bright moss slime, a quick ochre-green goblin with a short tool-blade, and a goblin archer with a clearly visible simple bow and rust sash. Each occupies its own transparent row on a sprite sheet, every frame exactly 48x48. Show down, left, right and up idle (2 frames each) and move (4 each); add 4 attack frames, 2 hurt frames and 4 death frames for each enemy. Top-down 3/4 view, consistent feet pivot at x=24 y=40, limited distinct palettes, expressive chunky silhouettes, crisp pixel clusters, no antialiasing, no text, fully original fantasy design.`

## Goblin Captain

Destination: `res://assets/enemies/green_plains/goblin_captain.png`

Frame size: `64x64`; idle 4, melee combo 8, charge 6, telegraph 2, hurt 2, defeat 6. Four facings for idle/move; combat can use down-facing plus horizontal mirroring only if the silhouette remains readable.

Style: larger armored goblin with a patched crimson shoulder mantle and oversized cleaver; readable charge silhouette. Transparent, pivot `(32, 51)`. Circle collision remains separate.

Prompt: `Create an original 64x64-frame pixel-art mini-boss sheet for Fractureborn: the Goblin Captain, a broad but nimble plains raider wearing patched bronze-green armor, a crimson shoulder mantle, and an oversized chipped cleaver. Top-down 3/4 view. Include idle 4 frames, telegraph 2, three-hit melee combo 8, forward charge 6, hurt 2, defeat 6; include four-direction idle and clear left/right attack silhouettes. Pivot at x=32 y=51, transparent background, strong readable poses, disciplined pixel clusters, no antialiasing, no written labels, original design.`

## Ancient Treant

Destination: `res://assets/bosses/green_plains/ancient_treant.png`

Frame size: `96x96`; idle 4, root telegraph 3, root strike 5, slam telegraph 3, slam 6, summon 5, stagger 4, defeat 8. Four-direction idle; attacks may face toward target.

Style: old living tree with fern crown, mossy bark plates, pale amber core, and long branch arms. Pivot `(48, 79)`, transparent background. Use a separate simple circle for the boss body.

Prompt: `Draw an original 96x96-frame pixel-art boss sheet for Fractureborn: the Ancient Treant, an old plains guardian with layered bark plates, fern crown, a pale amber heart-knot, and long branch arms. Top-down 3/4 view with a grounded centered pivot at x=48 y=79. Include idle 4, root telegraph 3, root attack 5, slam telegraph 3, slam 6, summon 5, stagger 4, defeat 8 frames. Show phase escalation through increasing leaf glow and branch posture while keeping the same readable shape. Transparent background, crisp limited pixel clusters, no antialiasing, no text, wholly original fantasy design.`

## Human Skill Effects and Waystone

Destination: `res://assets/vfx/human_skills_atlas.png`

Frame size: `64x64` cells in a `256x128` atlas. Sword Art slash 6 frames; Weapon Focus accent 4 frames; Battle Instinct ring 6 frames; Waystone activation pulse 8 frames.

Style: opaque pixel clusters with transparent outer pixels, amber/teal palette, short lifetimes, small footprints. No full-screen glows or required real-time lights.

Prompt: `Create a compact original 4x2 atlas of 64x64 pixel-art VFX cells for Fractureborn. Cells: a short amber directional sword crescent (6-frame sequence), a restrained teal weapon-focus flash (4), an amber-green battle-instinct ring (6), and a cool violet waystone activation pulse (8). Transparent background, crisp clusters, readable at small scale, no antialiasing, no huge bloom, no text, effects remain local to the character or waypoint.`

