extends RefCounted
class_name MapTileFactory

const TILE_SIZE := 32
const TILE_COUNT := 4
static var _tile_sets: Dictionary = {}


static func get_tile_set(theme_id: StringName) -> TileSet:
	if _tile_sets.has(theme_id):
		return _tile_sets[theme_id]
	var palette := _palette(theme_id)
	var image := Image.create(TILE_SIZE * TILE_COUNT, TILE_SIZE, false, Image.FORMAT_RGBA8)
	for tile_index in range(TILE_COUNT):
		var base: Color = palette[tile_index]
		for y in range(TILE_SIZE):
			for x in range(TILE_SIZE):
				var noise := ((x * 17 + y * 29 + tile_index * 11) % 23)
				var color := base
				if noise == 0:
					color = base.lightened(0.08)
				elif noise == 1:
					color = base.darkened(0.07)
				image.set_pixel(tile_index * TILE_SIZE + x, y, color)
	var texture := ImageTexture.create_from_image(image)
	var atlas := TileSetAtlasSource.new()
	atlas.texture = texture
	atlas.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	for tile_index in range(TILE_COUNT):
		atlas.create_tile(Vector2i(tile_index, 0))
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	tile_set.add_source(atlas, 0)
	_tile_sets[theme_id] = tile_set
	return tile_set


static func populate(layer: TileMapLayer, map_size: Vector2i, theme_id: StringName, tile_for_cell: Callable) -> void:
	layer.tile_set = get_tile_set(theme_id)
	layer.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var cell_count := Vector2i(ceili(float(map_size.x) / TILE_SIZE), ceili(float(map_size.y) / TILE_SIZE))
	for y in range(cell_count.y):
		for x in range(cell_count.x):
			layer.set_cell(Vector2i(x, y), 0, Vector2i(clampi(int(tile_for_cell.call(x, y)), 0, TILE_COUNT - 1), 0))


static func _palette(theme_id: StringName) -> Array[Color]:
	if theme_id == &"village":
		return [Color("5a9b56"), Color("72ad64"), Color("bea36e"), Color("d0ba81")]
	return [Color("4a9950"), Color("5da457"), Color("bd995f"), Color("86b36a")]
