# Fractureborn Phase 1 Asset Requests

All assets must be original and made for Fractureborn. Keep nearest-neighbor pixel edges, use a limited readable palette, and do not reference or imitate existing game art.

## Human Base Character

Purpose: replace the player placeholder while keeping collision and movement independent of art.

Output filename: `human_base.png`

Destination folder: `res://assets/characters/human/`

Destination: `res://assets/characters/human/human_base.png`

Canvas: `1056x240`; frame size: `48x48`; total: 92 frames. Four direction rows each contain 22 frames in the animation order below. A fifth row holds four downed frames; unused cells stay transparent.

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

Perspective: top-down 3/4. Palette: muted teal cloth, warm leather, amber accent. Transparency: required. Feet/pivot: `(24, 39)` in each frame. Collision: a separate radius-12 circle centered near the feet; art dimensions must not define gameplay collision.

Style: original frontier-fantasy traveler, clear face/weapon silhouette, muted teal cloth with warm leather and a small amber accent, crisp clusters, no anti-aliasing, no gradients, no text.

Prompt: `Create an original 2D pixel-art sprite sheet for Fractureborn, a frontier fantasy action RPG. One agile human adventurer with teal travel coat, warm leather straps, dark boots, short dark hair, and a simple training sword. Top-down three-quarter view. Arrange a transparent sprite sheet in labeled-by-position rows (no written labels): down, left, right, up. Each direction row contains idle 4 frames, walk 6, sword attack 6, dodge 4, hit 2; final down-facing row contains downed 4 frames. Every cell exactly 48x48 pixels, consistent centered feet pivot at x=24 y=39. Distinct poses, readable silhouette, original design, tight palette, chunky clean pixel clusters, crisp nearest-neighbor pixels, no antialiasing, no blur, no background, no shadows outside the cells.`

## Green Plains Ground Atlas

Purpose: replace the runtime grass and path tiles without creating individual ground sprites.

Output filename: `green_plains_atlas.png`

Destination folder: `res://assets/world/green_plains/`

Destination: `res://assets/world/green_plains/green_plains_atlas.png`

Canvas: `256x256`; frame/tile size: `32x32`; total: 64 static tiles. Animations: none. Directions: no character facings; path and transition edges must tile north, east, south, and west. Perspective: top-down 3/4 ground plane. Transparency: only transition/decal cells. Pivot: tile top-left. Collision: none in the atlas; world obstacles use separate simple shapes.

Tiles: grass A/B/C, two grass transitions, dirt path straight/corner/junction, short grass, flower accents, rock ground, arena moss, water edge. Seamless edges for repeatable ground tiles. No scripts or per-tile animation. Use Godot TileSet atlas regions.

Style: warm green field, dusty ochre trail, cool slate stones; readable at 1x zoom; subtle clusters that remain calm during combat. Transparent pixels only for transition/decal cells.

Prompt: `Draw an original seamless 8 by 8 atlas of 32x32 pixel tiles for Fractureborn's Green Plains, a connected open grassland with one winding ochre dirt trail. Include multiple subtly varied grass tiles, clean grass-to-dirt edges, path straight/corners/junctions, short grass, a few tiny flower tufts, slate rock ground and mossy arena ground. Consistent top-down 3/4 pixel-art perspective, limited natural palette, pixel clusters readable when enlarged with nearest-neighbor, no antialiasing, no baked grid lines, no text, no copyrighted or recognizable existing-game motifs. Transparent pixels only on transition/decal cells.`

## Central Village Ground Atlas

Purpose: replace the village grass, footpaths, and plaza without per-tile nodes.

Output filename: `village_atlas.png`

Destination folder: `res://assets/world/village/`

Destination: `res://assets/world/village/village_atlas.png`

Canvas: `256x256`; frame/tile size: `32x32`; total: 64 static tiles. Animations: none. Directions: no character facings; paving and edge transitions tile north, east, south, and west. Perspective: top-down 3/4 ground plane. Transparency: only transition/decal cells. Pivot: tile top-left. Collision: none in the atlas; collision geometry remains separate.

Tiles: village grass, stone/dirt footpath, plaza paving, path transitions, well paving, garden edge, worn threshold. Ground tiles only; props remain separate atlas entries in a later request.

Style: welcoming, handmade frontier hamlet; warm tan paving against the same family of greens as the Plains. Lossless import, no mipmaps, transparent transition edges where useful.

Prompt: `Create an original 8x8 atlas of 32x32 pixel-art floor tiles for Fractureborn's small frontier village. Include calm green grass variants, warm worn footpath, a compact pale-stone plaza, path-to-grass transitions, well paving, garden edges, and cottage thresholds. Top-down 3/4 perspective, clean repeatable edges, restrained warm palette, crisp pixel clusters, no antialiasing, no text, no character or building sprites, no recognizable existing-game content.`

## Common Enemies: Slime, Goblin, and Archer

Purpose: give the three common enemies distinct readable combat silhouettes.

Output filename: `common_enemies.png`

Destination folder: `res://assets/enemies/green_plains/`

Destination: `res://assets/enemies/green_plains/common_enemies.png`

Canvas: `768x576`; frame size: `48x48`; total: 192 frames. Arrange 12 rows: four directions for Slime, then four for Goblin, then four for Goblin Archer. Each row contains 16 frames in the order below.

Directions: down, left, right, up for each enemy. Animations per direction: idle 2, move 4, attack 4, hurt 2, death 4.

Perspective: top-down 3/4. Palette: bright moss slime, ochre-green goblin, archer with a rust sash. Transparency: required. Feet pivot: `(24, 40)`. Collision: separate simple circles; no pixel-precise collision.

Prompt: `Design an original transparent 768x576 pixel-art sprite sheet for three Fractureborn Green Plains enemies: a slow bright moss slime, a quick ochre-green goblin with a short tool-blade, and a goblin archer with a visible simple bow and rust sash. Make a 16-column by 12-row grid of exact 48x48 cells. Rows 1-4 are Slime down/left/right/up, rows 5-8 Goblin down/left/right/up, rows 9-12 Archer down/left/right/up. In every row put idle 2, move 4, attack 4, hurt 2, death 4 in that order. Top-down 3/4 view, consistent feet pivot x=24 y=40, distinct limited palettes, clear silhouettes, crisp clusters, no antialiasing, no text, fully original design.`

## Goblin Captain

Purpose: replace the mini-boss placeholder and show melee combo and charge telegraphs.

Output filename: `goblin_captain.png`

Destination folder: `res://assets/enemies/green_plains/`

Destination: `res://assets/enemies/green_plains/goblin_captain.png`

Canvas: `2176x256`; frame size: `64x64`; total: 136 frames. Four rows in down/left/right/up order, with 34 frames per row: idle 4, move 6, telegraph 2, melee combo 8, charge 6, hurt 2, defeat 6.

Perspective: top-down 3/4. Palette: bronze-green armor, crimson mantle, cool cleaver. Transparency: required. Feet pivot: `(32, 51)`. Collision: separate circle with size tuned in enemy data; charge uses gameplay geometry.

Prompt: `Create an original transparent 2176x256 pixel-art mini-boss sheet for Fractureborn's Goblin Captain, a broad plains raider with bronze-green armor, a patched crimson mantle, and an oversized chipped cleaver. Use 64x64 cells, four rows down/left/right/up, 34 frames per row in this exact order: idle 4, move 6, attack telegraph 2, three-hit melee combo 8, charge 6, hurt 2, defeat 6. Top-down 3/4 view, feet pivot x=32 y=51 in every cell, readable charge silhouette and clear swing arcs, limited palette, clean pixel clusters, no antialiasing, no text, original design.`

## Ancient Treant

Purpose: replace the main boss placeholder with readable root, slam, summon, phase, and stagger poses.

Output filename: `ancient_treant.png`

Destination folder: `res://assets/bosses/green_plains/`

Destination: `res://assets/bosses/green_plains/ancient_treant.png`

Canvas: `960x480`; frame size: `96x96`; total: 50 frames in a 10-column by 5-row grid, row-major. Frames 1-16: idle 4 for down/left/right/up. Frames 17-50: root telegraph 3, root strike 5, slam telegraph 3, slam 6, summon 5, stagger 4, defeat 8. Attacks face down and may mirror/rotate toward the target.

Perspective: top-down 3/4. Palette: moss green, dark bark, pale amber heart-knot. Transparency: required. Feet pivot: `(48, 79)`. Collision: separate simple circle for boss body and separate telegraph geometry.

Prompt: `Draw an original transparent 960x480 pixel-art boss sheet for Fractureborn's Ancient Treant, an old guardian with layered bark plates, fern crown, pale amber heart-knot, and long branch arms. Use a 10-column by 5-row grid of exact 96x96 cells in row-major order. First 16 frames: idle 4 each facing down, left, right, up. Next 34 frames: root telegraph 3, root strike 5, slam telegraph 3, slam 6, summon 5, stagger 4, defeat 8, facing down so the game can aim the attacks. Pivot x=48 y=79 in every frame. Show increasing leaf glow and branch posture in phase poses, crisp clusters, limited palette, no antialiasing, no text, fully original design.`

## Human Skill Effects and Waystone

Purpose: replace the gameplay effect placeholders with local sprite-sheet animations.

Output filename: `human_skills_atlas.png`

Destination folder: `res://assets/vfx/`

Destination: `res://assets/vfx/human_skills_atlas.png`

Canvas: `512x192`; frame size: `64x64`; total: 24 frames in an 8-column by 3-row grid, row-major. Animations: Sword Art slash 6, Weapon Focus flash 4, Battle Instinct ring 6, Waystone activation pulse 8. Directions: Sword Art points right in source art and rotates in game; others are radial. Perspective: top-down 3/4. Transparency: required. Pivot: `(32, 32)`. Collision: none; gameplay hitboxes remain separate.

Style: opaque pixel clusters with transparent outer pixels, amber/teal palette, short lifetimes, small footprints. No full-screen glows or required real-time lights.

Prompt: `Create an original transparent 512x192 pixel-art VFX sheet for Fractureborn: 8 columns by 3 rows of exact 64x64 cells, 24 frames in row-major order. Frames 1-6: right-facing amber Sword Art crescent; 7-10: restrained teal Weapon Focus flash; 11-16: amber-green Battle Instinct ring; 17-24: cool violet waystone activation pulse. Center each effect at x=32 y=32. Top-down 3/4 view, crisp clusters, limited palette, no antialiasing, no bloom, no text, small local effects only.`

## Archivist Edda

Purpose: replace the village quest NPC placeholder and make the quest giver easy to identify.

Output filename: `archivist_edda.png`

Destination folder: `res://assets/characters/npcs/`

Destination: `res://assets/characters/npcs/archivist_edda.png`

Canvas: `192x192`; frame size: `48x48`; total: 16 frames. Animations: idle 4 per direction. Directions: down, left, right, up, one row each. Perspective: top-down 3/4. Palette: indigo robes, pale linen, amber book clasp. Transparency: required. Feet pivot: `(24, 40)`. Collision: interaction uses a separate radius-52 area; NPC art does not define collision.

Prompt: `Create an original transparent 192x192 pixel-art NPC sprite sheet for Archivist Edda in Fractureborn. Exact 48x48 cells, four rows down/left/right/up, four gentle idle frames per row. Edda is a village historian in indigo travel robes with a pale linen scarf and a small amber book clasp. Top-down 3/4 view, centered feet pivot x=24 y=40, warm friendly silhouette, restrained palette, crisp pixels, no antialiasing, no text, no existing-game motifs.`

## Village Buildings and Stalls

Purpose: replace the cottage, forge, shop, market, well, and signs drawn as simple shapes.

Output filename: `village_props_atlas.png`

Destination folder: `res://assets/world/village/`

Destination: `res://assets/world/village/village_props_atlas.png`

Canvas: `512x256`; cell size: `32x32`; total: 128 static atlas cells. Reserve tile-aligned groups for one 5x3 cottage, one 5x3 forge, one 4x3 market stall, one 2x2 well, four 1x2 signposts, and remaining cells for roof/edge variants. Animations: none. Directions: front/down view with side and back roof edges where needed. Perspective: top-down 3/4. Palette: warm tan timber, blue slate, cream cloth, subdued rust. Transparency: required around prop silhouettes. Pivot: cell top-left; assembled props anchor at their ground-contact center. Collision: separate rectangles for buildings and a circle for the well; no per-pixel collision.

Prompt: `Draw an original transparent 512x256 pixel-art atlas for Fractureborn's Central Village, aligned to a 16-column by 8-row grid of 32x32 cells. Include a 5x3 timber cottage, a 5x3 stone-and-timber forge, a 4x3 cloth-roof market stall, a 2x2 carved well, four 1x2 signposts, and spare roof/edge variants. Top-down 3/4 perspective, warm frontier village palette with tan wood, blue slate and cream cloth, readable 32-pixel construction, crisp clusters, no antialiasing, no text, fully original architecture. Keep building silhouettes transparent outside their ground footprint.`

## Green Plains Props and Puzzle Stones

Purpose: replace the trees, rocks, bramble wall, chest, rune stones, and waystone placeholders.

Output filename: `green_plains_props_atlas.png`

Destination folder: `res://assets/world/green_plains/`

Destination: `res://assets/world/green_plains/green_plains_props_atlas.png`

Canvas: `512x256`; cell size: `32x32`; total: 128 static atlas cells. Use tile-aligned groups for three 2x3 trees, two 2x2 rocks, four 1x1 bramble segments, one 2x1 chest, three 1x2 rune stones, one 2x2 waystone, and variants. Animations: none; activation pulse comes from the VFX sheet. Directions: objects face down/front; bramble edges have north/east/south/west variants. Perspective: top-down 3/4. Palette: leaf green, cool slate, muted violet on the waystone. Transparency: required around props. Pivot: cell top-left, assembled object ground-contact center. Collision: simple tree-trunk and rock rectangles; chest/runes/waystone use separate interaction areas.

Prompt: `Create an original transparent 512x256 pixel-art atlas for Fractureborn's Green Plains, 16 by 8 cells of 32x32 pixels. Tile-aligned props: three 2x3 leafy trees with visible trunks, two 2x2 slate rocks, four 1x1 bramble wall segments with connecting edges, a 2x1 tangled trail chest, three distinct 1x2 Dawn/Sun/Leaf rune stones with symbols represented only by shapes, and a 2x2 violet carved waystone. Top-down 3/4 view, restrained grass-green/slate/violet palette, clear silhouettes and ground contact, no antialiasing, no labels or text, no copied fantasy landmarks.`

## Weapon Icons

Purpose: distinguish the five Phase 1 weapons in the inventory and hotbar.

Output filename: `weapon_icons.png`

Destination folder: `res://assets/weapons/`

Destination: `res://assets/weapons/weapon_icons.png`

Canvas: `240x48`; frame size: `48x48`; total: 5 static frames in this order: Training Sword, Iron Sword, Wooden Bow, Basic Pistol, Basic Shotgun. Animations: none. Directions: right-facing icon orientation. Perspective: top-down 3/4 item art. Palette: iron gray, warm wood, restrained brass. Transparency: required. Pivot: icon center `(24, 24)`. Collision: none; weapon hitboxes/projectiles remain data-driven.

Prompt: `Draw five original 48x48 pixel-art weapon icons for Fractureborn on one transparent 240x48 horizontal sheet. Exact order: a worn Training Sword, sturdy Iron Sword, simple Wooden Bow, compact Basic Pistol, and short-barrel Basic Shotgun. Top-down 3/4 item view pointing generally right, consistent centered pivot x=24 y=24, warm wood and cool metal palette, readable silhouettes at small size, crisp pixels, no antialiasing, no text, no existing-game weapon designs.`

## Combat Projectiles

Purpose: give bow, pistol, shotgun, and enemy ranged attacks distinct low-cost visuals.

Output filename: `projectiles.png`

Destination folder: `res://assets/weapons/`

Destination: `res://assets/weapons/projectiles.png`

Canvas: `80x16`; frame size: `16x16`; total: 5 static frames: player arrow, player pistol shot, shotgun pellet, goblin arrow, Treant root seed. Animations: none. Directions: all point right in the source; rotate in game. Perspective: top-down 3/4. Palette: wood/cream, brass/amber, moss green. Transparency: required. Pivot: `(8, 8)`. Collision: separate circle with narrow projectile masks; visual size must not set hit radius.

Prompt: `Create an original transparent 80x16 pixel-art projectile strip for Fractureborn, five exact 16x16 cells. In order: short wooden player arrow, tiny amber pistol shot, compact shotgun pellet, rough ochre goblin arrow, mossy Treant root seed. All face right for rotation in game, centered pivot x=8 y=8, top-down 3/4 style, crisp limited palette, no blur, no antialiasing, no text.`

## Loot Icons

Purpose: make gold, materials, and healing potions readable in pickup and inventory views.

Output filename: `loot_icons.png`

Destination folder: `res://assets/ui/`

Destination: `res://assets/ui/loot_icons.png`

Canvas: `160x32`; frame size: `32x32`; total: 5 static frames: gold, Sunleaf, Moss Fragment, Ancient Bark, Health Potion. Animations: none. Directions: none. Perspective: top-down 3/4 item art. Palette: amber gold, leaf green, dark moss, bark brown, coral-red potion. Transparency: required. Pivot: `(16, 16)`. Collision: none; loot pickups use a separate radius-14 area.

Prompt: `Draw an original transparent 160x32 pixel-art loot icon strip for Fractureborn, five exact 32x32 cells. In order: one warm gold coin, bright Sunleaf sprig, compact Moss Fragment, textured Ancient Bark shard, small coral-red Health Potion bottle. Top-down 3/4 item view, centered pivots x=16 y=16, distinct silhouettes and limited palette, crisp pixels, no antialiasing, no text, no mana bottle or existing-game motifs.`
