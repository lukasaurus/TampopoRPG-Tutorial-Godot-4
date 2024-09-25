@tool
extends EditorScript


class Rect2iIterator:
	var _begin: Vector2i
	var _current: Vector2i
	var _rect: Rect2i

	static func from_vector2(vector2: Vector2i) -> Rect2iIterator:
		return Rect2iIterator.new(Rect2i(Vector2i(0, 0), vector2))

	func _init(rect: Rect2i):
		self._begin = rect.position
		self._current = self._begin
		self._rect = rect

	func _iter_init(_arg):
		self._current = self._begin
		return self._rect.size.x > 0 and self._rect.size.y > 0

	func _iter_next(_arg):
		self._current.x += 1
		if self._current.x >= self._rect.position.x + self._rect.size.x:
			self._current.x = self._rect.position.x
			self._current.y += 1
		if self._current.y >= self._rect.position.y + self._rect.size.y:
			return false
		return true

	func _iter_get(_arg):
		return self._current

class ImageSpan:
	var data: Object
	var rect: Rect2i

	func _init(p_data: Object, p_rect: Rect2i):
		self.data = p_data
		self.rect = p_rect
		assert(ImageSpan._check_size(p_data.get_size(), p_rect))

	static func from_image(image: Image) -> ImageSpan:
		return ImageSpan.new(image, Rect2i(Vector2i(0, 0), image.get_size()))

	static func _check_size(old_size: Vector2i, new_rect: Rect2i) -> bool:
		var new_size = new_rect.size
		if not (new_size.x > 0 and new_size.y > 0) or\
		   not (new_size.x + new_rect.position.x <= old_size.x and new_size.y + new_rect.position.y <= old_size.y):
			push_error("Invalid rect: %s, the original size: %s" % [new_rect, old_size])
			return false
		return true

	func get_base_image() -> Image:
		if self.data.is_class("Image"):
			return self.data
		else:
			return self.data.get_base_image()

	func get_base_position() -> Vector2i:
		return ImageSpan._get_base_position(self.data, self.rect.position)

	static func _get_base_position(curr_data: Object, curr_pos: Vector2i) -> Vector2i:
		if curr_data.is_class("Image"):
			return curr_pos
		else:
			return _get_base_position(curr_data.data, curr_pos + curr_data.rect.position)

	func get_size() -> Vector2i:
		return self.rect.size

	func get_format() -> int:
		return self.get_base_image().get_format()

	func blit_rect(src: ImageSpan, src_rect: Rect2i, dst: Vector2i):
		assert(ImageSpan._check_size(self.get_size(), Rect2i(dst, src_rect.size)))
		self.get_base_image().blit_rect(src.get_base_image(), Rect2i(src.get_base_position() + src_rect.position, src_rect.size), self.get_base_position() + dst)

	func to_image() -> Image:
		var result = Image.create(self.get_size().x, self.get_size().y, false, self.get_base_image().get_format())
		ImageSpan.from_image(result).blit_rect(self, Rect2i(Vector2i(0, 0), self.get_size()), Vector2i(0, 0))
		return result


enum TilesetViewUnitKind { Image, ImageSpan, TilesetView }

class TilesetViewUnit:
	var kind: TilesetViewUnitKind

	func _init(p_kind: TilesetViewUnitKind):
		self.kind = p_kind

class ImageTilesetViewUnit extends TilesetViewUnit:
	var data: Image
	var rect: Rect2i

	func _init(p_data: Image, p_rect: Rect2i):
		super(TilesetViewUnitKind.Image)
		self.data = p_data
		self.rect = p_rect

class ImageSpanTilesetViewUnit extends TilesetViewUnit:
	var data: ImageSpan
	var rect: Rect2i

	func _init(p_data: ImageSpan, p_rect: Rect2i):
		super(TilesetViewUnitKind.ImageSpan)
		self.data = p_data
		self.rect = p_rect

class TilesetViewTilesetViewUnit extends TilesetViewUnit:
	var data: TilesetView
	var rect: Rect2i

	func _init(p_data: TilesetView, p_rect: Rect2i):
		super(TilesetViewUnitKind.TilesetView)
		self.data = p_data
		self.rect = p_rect

class TilesetView:
	var image_format: int
	var size: Vector2i
	var tile_size: Vector2i
	var _data: Array[TilesetViewUnit]

	func _init(p_image_format: int, p_size: Vector2i, p_tile_size: Vector2i):
		self.image_format = p_image_format
		self.size = p_size
		self.tile_size = p_tile_size
		self._data = []
		self._data.resize(self.size.x * self.size.y)

	func _get_index(pos: Vector2i) -> int:
		if pos.x < self.size.x and pos.y < self.size.y and pos.x >= 0 and pos.y >= 0:
			return pos.y * self.size.x + pos.x
		else:
			push_error("Invalid position: %s" % pos)
			return 0

	func get_tile_data(pos: Vector2i) -> TilesetViewUnit:
		return self._data[_get_index(pos)]

	func set_tile_data(pos: Vector2i, src: TilesetViewUnit):
		self._data[_get_index(pos)] = src

	func set_image_unit_tile_data(pos: Vector2i, image: Image, src: Vector2i):
		self._data[_get_index(pos)] = ImageTilesetViewUnit.new(image, Rect2i(src, Vector2i(1, 1)))

	func set_imagespan_unit_tile_data(pos: Vector2i, image_span: ImageSpan, src: Vector2i):
		self._data[_get_index(pos)] = ImageSpanTilesetViewUnit.new(image_span, Rect2i(src, Vector2i(1, 1)))

	func set_image_unit_tile_data_from_list(image: Image, src_list: Array):
		assert(self._data.size() == src_list.size())
		for i in range(self._data.size()):
			var src = src_list[i]
			if typeof(src) == TYPE_VECTOR2I:
				self._data[i] = ImageTilesetViewUnit.new(image, Rect2i(src, Vector2i(1, 1)))
			else:
				self._data[i] = ImageTilesetViewUnit.new(image, Rect2i(Vector2i(src[0], src[1]), Vector2i(1, 1)))

	func set_imagespan_unit_tile_data_from_list(image_span: ImageSpan, src_list: Array):
		assert(self._data.size() == src_list.size())
		for i in range(self._data.size()):
			var src = src_list[i]
			if typeof(src) == TYPE_VECTOR2I:
				self._data[i] = ImageSpanTilesetViewUnit.new(image_span, Rect2i(src, Vector2i(1, 1)))
			else:
				self._data[i] = ImageSpanTilesetViewUnit.new(image_span, Rect2i(Vector2i(src[0], src[1]), Vector2i(1, 1)))

	func set_tilesetview_tile_data(pos: Vector2i, tilesetview: TilesetView):
		self.set_tile_data(pos, TilesetViewTilesetViewUnit.new(tilesetview, Rect2i(Vector2i(), tilesetview.size)))

	func assemble_tileset_image() -> Image:
		var image_size = self.size * self.tile_size
		var result = Image.create(image_size.x, image_size.y, false, self.image_format)
		for pos in Rect2iIterator.from_vector2(self.size):
			var v = self.get_tile_data(pos)
			if v:
				match v.kind:
					TilesetViewUnitKind.Image:
						result.blit_rect(v.data, Rect2i(v.rect.position * self.tile_size, v.rect.size * self.tile_size), pos * self.tile_size)
					TilesetViewUnitKind.ImageSpan:
						ImageSpan.from_image(result).blit_rect(v.data, Rect2i(v.rect.position * self.tile_size, v.rect.size * self.tile_size), pos * self.tile_size)
					TilesetViewUnitKind.TilesetView:
						var image = v.data.assemble_tileset_image()
						result.blit_rect(image, Rect2i(v.rect.position * self.tile_size, v.rect.size * self.tile_size), pos * self.tile_size)
		return result


func __is_palettle_format(file: FileAccess) -> bool:
	if file.get_length() < 43:  # PNG signature + ... + PLTE + first palettle
		return false
	var file_position = file.get_position()
	# 137 80 78 71 13 10 26 10
	file.seek(0)
	for v in [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]:
		if file.get_8() != v:
			file.seek(file_position)
			return false
	# P Mode, 8 bits
	file.seek(0x18)
	for v in [0x08, 0x03]:
		if file.get_8() != v:
			file.seek(file_position)
			return false

	file.seek(file_position)
	return true


func __get_first_palette_colour(file: FileAccess) -> Color:
	assert(__is_palettle_format(file))
	# First colour
	var file_position = file.get_position()

	file.seek_end()
	var file_size = file.get_position()

	file.seek(0x21)
	while file.get_position() < file_size:
		var buffer = []
		for _i in range(4):
			buffer.append(file.get_8())
		var length = buffer[0] * 0x1000 + buffer[1] * 0x0100 + buffer[2] * 0x0010 + buffer[3] * 0x0001

		buffer = []
		for _i in range(4):
			buffer.append(file.get_8())
		var chunk_kind = "".join(buffer.map(func(c): return String.chr(c)))

		if chunk_kind == "PLTE":
			var r = file.get_8()
			var g = file.get_8()
			var b = file.get_8()
			file.seek(file_position)
			return Color("#%02x%02x%02x" % [r, g, b])
		else:
			file.seek(file.get_position() + length + 4)

	file.seek(file_position)
	push_error("Can not find first palette colour.")
	return Color()


func __make_color_transparent(image: Image, transparent_colour: Color):
	for x in range(image.get_width()):
		for y in range(image.get_height()):
			if image.get_pixel(x, y) == transparent_colour:
				image.set_pixel(x, y, Color(0, 0, 0, 0))


func load_may_transparent_image(path: String) -> Image:
	var file = FileAccess.open(path, FileAccess.READ)
	if file and file.is_open():
		if __is_palettle_format(file):
			var transparent_colour: Color = __get_first_palette_colour(file)
			var image: Image = Image.load_from_file(path)
			image.convert(Image.FORMAT_RGBA8)
			__make_color_transparent(image, transparent_colour)
			return image
		else:
			return Image.load_from_file(path)
	else:
		return null


func __get_tile_rect(position: Vector2i, tile_size: Vector2i) -> Rect2i:
	return Rect2i(position.x * tile_size.x, position.y * tile_size.y, tile_size.x, tile_size.y)


func __check_tile_size(image: Image, tile_size: Vector2i, size: Vector2i) -> bool:
	return image.get_size() == size * tile_size


func reorganize_autotiles_from_3x4_to_2x3(image: Image, tile_size: Vector2i) -> Image:
	assert(__check_tile_size(image, tile_size, Vector2i(3, 4)))

	var positions = [[0, 0], [0, 2], [1, 0], [1, 2], [3, 0], [3, 2]]
	var new_image = Image.create(2 * tile_size.x, 3 * tile_size.y, false, image.get_format())

	var index = 0
	for row in range(3):
		for col in range(2):
			var position = Vector2i(positions[index][1], positions[index][0])
			var rect = __get_tile_rect(position, tile_size)
			new_image.blit_rect(image, rect, Vector2i(col, row) * tile_size)
			index += 1

	return new_image


func reorganize_autotiles_from_3x4_to_2x3_span(image_span: ImageSpan, tile_size: Vector2i) -> Image:
	assert(image_span.get_size() == tile_size * Vector2i(3, 4))

	var tileset = TilesetView.new(image_span.get_format(), Vector2i(2, 3), tile_size)
	tileset.set_imagespan_unit_tile_data_from_list(image_span, [[0, 0], [2, 0], [0, 1], [2, 1], [0, 3], [2, 3]])
	return tileset.assemble_tileset_image()


func get_godot_autotiles_size() -> Vector2i:
	return Vector2i(12, 4)


func __init_autotiles_data():
	const I1 = [2, 0]; const I2 = [3, 0]; const I3 = [2, 1]; const I4 = [3, 1]  # Inner corner
	const O1 = [0, 0]; const O2 = [1, 0]; const O3 = [0, 1]; const O4 = [1, 1]  # Outer corner
	const TL = [0, 2]; const TR = [3, 2]; const BL = [0, 5]; const BR = [3, 5]  # Corners
	const T1 = [1, 2]; const T2 = [2, 2]; const L1 = [0, 3]; const L2 = [0, 4]  # Edge part
	const R1 = [3, 3]; const R2 = [3, 4]; const B1 = [1, 5]; const B2 = [2, 5]  # Edge part
	const N1 = [1, 3]; const N2 = [2, 3]; const N3 = [1, 4]; const N4 = [2, 4]  # Normal path

	return [
		TL,TR, TL,T1,T2,T1,T2,TR,  N4,I2,T2,T1,T2,T1,I1,N3,  TL,T1,I1,I2,T2,T1,T2,TR,
		L1,R1, L1,I4,I3,I4,I3,R1,  I3,I4,I3,N1,N2,I4,I3,I4,  L1,N1,N2,N1,N2,N1,N2,R1,
		L2,R2, L2,I2,I1,I2,I1,R2,  L2,I2,I1,N3,N4,I2,I1,R2,  L2,N3,I1,N3,O1,O2,N4,I2,
		L1,R1, L1,I4,I3,I4,I3,R1,  L1,N1,N2,N1,N2,N1,N2,R1,  L1,N1,N2,I4,O3,O4,N2,I4,
		L2,R2, L2,I2,I1,I2,I1,R2,  L2,N3,N4,N3,N4,N3,N4,R2,  I1,N3,N4,N3,N4,I2,N4,R2,
		BL,BR, BL,B1,B2,B1,B2,BR,  L1,I4,I3,N1,N2,I4,I3,R1,  I3,N1,N2,N1,I3,N1,N2,R1,
		TL,TR, TL,T1,T2,T1,T2,TR,  I1,I2,I1,N3,N4,I2,I1,I2,  L2,N3,N4,N3,N4,N3,N4,R2,
		BL,BR, BL,B1,B2,B1,B2,BR,  N2,I4,B2,B1,B2,B1,I3,N1,  BL,B1,B2,B1,I3,I4,B2,BR,
	]


var AutotilesData = __init_autotiles_data()


func create_godot_autotiles_from_2x3_span(image_span: ImageSpan, tile_size: Vector2i) -> Image:
	assert(image_span.get_size() == tile_size * Vector2i(2, 3))

	var tileset = TilesetView.new(image_span.get_format(), get_godot_autotiles_size() * 2, tile_size / 2)
	tileset.set_imagespan_unit_tile_data_from_list(image_span, AutotilesData)
	return tileset.assemble_tileset_image()


func create_godot_autotiles_from_3x4_span(image_span: ImageSpan, tile_size: Vector2i) -> Image:
	var new_image = reorganize_autotiles_from_3x4_to_2x3_span(image_span, tile_size)
	return create_godot_autotiles_from_2x3_span(ImageSpan.from_image(new_image), tile_size)


func create_godot_autotiles(image_span: ImageSpan, tile_size: Vector2i, size: Vector2i) -> Image:
	if size == Vector2i(2, 3):
		return create_godot_autotiles_from_2x3_span(image_span, tile_size)
	elif size == Vector2i(3, 4):
		return create_godot_autotiles_from_3x4_span(image_span, tile_size)
	assert(false)
	return null


func __get_average_colour(image: Image, region: Rect2i) -> Color:
	var colour_count = 0
	var colour_sum = Color(0, 0, 0, 0)
	for position in Rect2iIterator.new(region):
		var colour = image.get_pixel(position.x, position.y)
		if colour.a > 0:
			colour_sum += colour
			colour_count += 1
	var result = colour_sum / colour_count
	result.a = 1
	return result


const TerrainDirectionMap = {
	1: TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
	2: TileSet.CELL_NEIGHBOR_TOP_SIDE,
	3: TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER,
	4: TileSet.CELL_NEIGHBOR_LEFT_SIDE,
	5: TileSet.CELL_NEIGHBOR_RIGHT_SIDE,
	6: TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
	7: TileSet.CELL_NEIGHBOR_BOTTOM_SIDE,
	8: TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
}

const TerrainDirectionData = [
	[0x40,0x50,0x58,0x48, 0x5b,0xd8,0x78,0x5e, 0xd0,0xfa,0xf8,0x68],
	[0x42,0x52,0x5a,0x4a, 0xd2,0xfe,0xfb,0x6a, 0xd6,0x7e,null,0x7b],
	[0x02,0x12,0x1a,0x0a, 0x56,0xdf,0x7f,0x4b, 0xde,0xff,0xdb,0x6b],
	[0x00,0x10,0x18,0x08, 0x7a,0x1e,0x1b,0xda, 0x16,0x1f,0x5f,0x0b],
]

func create_tileset_source(tileset: TileSet, image: Image, tile_size: Vector2i):
	var tileset_source = TileSetAtlasSource.new()
	tileset_source.texture = ImageTexture.create_from_image(image)
	tileset_source.texture_region_size = tile_size
	tileset.add_source(tileset_source)
	return tileset_source

func add_terrain_set(tileset: TileSet) -> int:
	tileset.add_terrain_set()
	var terrain_set = tileset.get_terrain_sets_count() - 1
	tileset.set_terrain_set_mode(terrain_set, TileSet.TERRAIN_MODE_MATCH_CORNERS_AND_SIDES)
	return terrain_set

func set_terrain(tileset_source: TileSetAtlasSource, tileset: TileSet, terrain_set: int, terrain_name: String, tile_size: Vector2i, start_position: Vector2i, frames_count: int = 0):
	tileset.add_terrain(terrain_set)
	var terrain_index = tileset.get_terrains_count(terrain_set) - 1

	var size = Vector2i(TerrainDirectionData[0].size(), TerrainDirectionData.size())
	var average_colour = __get_average_colour(tileset_source.texture.get_image(),
											  Rect2i(start_position * tile_size, size * tile_size))
	tileset.set_terrain_color(terrain_set, terrain_index, average_colour.inverted())
	tileset.set_terrain_name(terrain_set, terrain_index, terrain_name)

	for position in Rect2iIterator.new(Rect2i(start_position, size)):
		tileset_source.create_tile(position)
		if frames_count:
			tileset_source.set_tile_animation_columns(position, 1)
			tileset_source.set_tile_animation_separation(position, Vector2i(0, 3))
			tileset_source.set_tile_animation_frames_count(position, frames_count)
			tileset_source.set_tile_animation_speed(position, 2)
		var tile_data = tileset_source.get_tile_data(position, 0)
		var _direction = TerrainDirectionData[position.y % size.y][position.x % size.x]
		if _direction != null:
			tile_data.terrain_set = terrain_set
			tile_data.terrain = terrain_index
			for i in range(9):
				if _direction & (0x1 << i):
					tile_data.set_terrain_peering_bit(TerrainDirectionMap[i+1], terrain_index)


func create_godot_autotiles_animation(image: Image, config: TilesetSlice) -> Image:
	var tile_size = config.tile_size
	var size = config.size
	var new_total_image = Image.create(12 * tile_size.x, 4 * config.frames_count * tile_size.y, false, image.get_format())
	var i = 0
	for r in Rect2iIterator.new(Rect2i(Vector2i(0, 0), Vector2i(4, 1))):
		var image_position = r * tile_size * size
		var image_size = size * tile_size
		var new_image = Image.create(image_size.x, image_size.y, false, image.get_format())
		new_image.blit_rect(image, Rect2i(image_position, image_size), Vector2i(0, 0))
		new_image = create_godot_autotiles(ImageSpan.from_image(new_image), tile_size, size)
		new_total_image.blit_rect(new_image, Rect2i(Vector2i(0, 0), get_godot_autotiles_size() * tile_size), Vector2i(0, i) * get_godot_autotiles_size() * tile_size)
		i += 1
	return new_total_image


class TilesetSlice:
	var size: Vector2i
	var tile_size: Vector2i
	var frames_count: int

	func _init(p_size: Vector2i, p_tile_size: Vector2i, p_frames_count: int):
		self.size = p_size
		self.tile_size = p_tile_size
		self.frames_count = p_frames_count


func __create_rpgmaker_2000_2003_sea_autotiles(span_a: ImageSpan, span_b: ImageSpan, image_format: int, pos_map: Array, tile_size: Vector2i) -> Image:
	var tileset = TilesetView.new(image_format, Vector2i(4, 6), tile_size / 2)
	for pos in Rect2iIterator.from_vector2(Vector2i(4, 6)):
		var dat = pos_map[pos.y][pos.x]
		var span = span_a if (dat & 0x10) == 0 else span_b
		var src_pos = Vector2i((dat & 0xf) % 2, (dat & 0xf) / 2)
		tileset.set_imagespan_unit_tile_data(pos, span, src_pos)

	var tileset_image_2x3 = tileset.assemble_tileset_image()
	var tileset_image = create_godot_autotiles(ImageSpan.from_image(tileset_image_2x3), tile_size, Vector2i(2, 3))
	return tileset_image


func create_rpgmaker_2000_2003_tileset(file_path: String) -> TileSet:
	var image = load_may_transparent_image(file_path)

	var tile_size = Vector2i(16, 16)
	var tileset = TileSet.new()
	tileset.tile_size = tile_size
	var terrain_set = add_terrain_set(tileset)

	# Block A B
	var a1_index = [[0, 0], [1, 0], [2, 0]]
	var a2_index = [[3, 0], [4, 0], [5, 0]]
	var b_index = [[0, 1], [1, 1], [2, 1]]
	var to_span = func(pos): return ImageSpan.new(image, Rect2i(Vector2i(pos[0], pos[1]) * Vector2i(1, 4) * tile_size, Vector2i(1, 4) * tile_size))
	var a1_span = a1_index.map(to_span)
	var a2_span = a2_index.map(to_span)
	var b_span = b_index.map(to_span)

	const data_ab_1 = [
		[0x00, 0x01, 0x0c, 0x0d],
		[0x02, 0x03, 0x0e, 0x0f],
		[0x00, 0x09, 0x08, 0x01],
		[0x06, 0x13, 0x12, 0x07],
		[0x04, 0x11, 0x10, 0x05],
		[0x02, 0x0b, 0x0a, 0x03],
	]
	const data_ab_2 = [
		[0x00, 0x01, 0x0c, 0x0d],
		[0x02, 0x03, 0x0e, 0x0f],
		[0x00, 0x09, 0x08, 0x01],
		[0x06, 0x1f, 0x1e, 0x07],
		[0x04, 0x1d, 0x1c, 0x05],
		[0x02, 0x0b, 0x0a, 0x03],
	]
	const data_b_1 = [
		[0x18, 0x19, 0x1c, 0x1d],
		[0x1a, 0x1b, 0x1e, 0x1f],
		[0x18, 0x1d, 0x1c, 0x19],
		[0x1e, 0x1f, 0x1e, 0x1f],
		[0x1c, 0x1d, 0x1c, 0x1d],
		[0x1a, 0x1f, 0x1e, 0x1b],
	]
	const data_b_2 = [
		[0x14, 0x15, 0x10, 0x11],
		[0x16, 0x17, 0x12, 0x13],
		[0x14, 0x11, 0x10, 0x15],
		[0x12, 0x13, 0x12, 0x13],
		[0x10, 0x11, 0x10, 0x11],
		[0x16, 0x13, 0x12, 0x17],
	]

	var data = [
		[[data_ab_1, a1_span[0], b_span[0]], [data_ab_1, a2_span[0], b_span[0]], [data_b_1, null, b_span[0]]],
		[[data_ab_1, a1_span[1], b_span[1]], [data_ab_1, a2_span[1], b_span[1]], [data_b_1, null, b_span[1]]],
		[[data_ab_1, a1_span[2], b_span[2]], [data_ab_1, a2_span[2], b_span[2]], [data_b_1, null, b_span[2]]],
		[[data_ab_2, a1_span[0], b_span[0]], [data_ab_2, a2_span[0], b_span[0]], [data_b_2, null, b_span[0]]],
		[[data_ab_2, a1_span[1], b_span[1]], [data_ab_2, a2_span[1], b_span[1]], [data_b_2, null, b_span[1]]],
		[[data_ab_2, a1_span[2], b_span[2]], [data_ab_2, a2_span[2], b_span[2]], [data_b_2, null, b_span[2]]],
	]

	var tileset_block_ab = TilesetView.new(image.get_format(), Vector2i(3, 6), get_godot_autotiles_size() * tile_size)

	for pos in Rect2iIterator.from_vector2(Vector2i(3, 6)):
		var value = data[pos.y][pos.x]
		var tileset_image = __create_rpgmaker_2000_2003_sea_autotiles(value[1], value[2], image.get_format(), value[0], tile_size)
		tileset_block_ab.set_image_unit_tile_data(pos, tileset_image, Vector2i(0, 0))

	var tileset_source_block_ab = create_tileset_source(tileset, tileset_block_ab.assemble_tileset_image(), tile_size)

	var terrain_name_map = [
		["A1_shallow", "A2_shallow", "B_shallow"],
		["A1_deep",    "A2_deep",    "B_deep"],
	]

	for pos in Rect2iIterator.from_vector2(Vector2i(3, 2)):
		var terrain_name = "autotile_%s" % terrain_name_map[pos.y][pos.x]
		set_terrain(tileset_source_block_ab, tileset, terrain_set, terrain_name, tile_size, pos * Vector2i(1, 3) * get_godot_autotiles_size(), 3)

	# Block D
	var tileset_block_d = TilesetView.new(image.get_format(), Vector2i(1, 3), tile_size * Vector2i(6, 8))
	tileset_block_d.set_image_unit_tile_data_from_list(image, [[0, 1], [1, 0], [1, 1]])
	var tileset_block_d_image = tileset_block_d.assemble_tileset_image()
	var tileset_block_d_autotile = TilesetView.new(image.get_format(), Vector2i(2, 6), tile_size * get_godot_autotiles_size())
	for pos in Rect2iIterator.new(Rect2i(Vector2i(0, 0), Vector2i(2, 6))):
		var image_span_unit = ImageSpan.new(tileset_block_d_image, Rect2i(pos * Vector2i(3, 4) * tile_size, Vector2i(3, 4) * tile_size))
		var image_unit = create_godot_autotiles_from_3x4_span(image_span_unit, tile_size)
		tileset_block_d_autotile.set_image_unit_tile_data(pos, image_unit, Vector2i(0, 0))

	var tileset_source_block_d = create_tileset_source(tileset, tileset_block_d_autotile.assemble_tileset_image(), tile_size)
	
	for pos in Rect2iIterator.from_vector2(Vector2i(2, 6)):
		var terrain_name = "autotile_D%s" % (pos.y * 2 + pos.x + 1)
		set_terrain(tileset_source_block_d, tileset, terrain_set, terrain_name, tile_size, pos * get_godot_autotiles_size())

	# Block C
	var tileset_block_c = TilesetView.new(image.get_format(), Vector2i(1, 1), tile_size * Vector2i(3, 4))
	tileset_block_c.set_image_unit_tile_data_from_list(image, [[1, 1]])

	var tileset_source_block_c = create_tileset_source(tileset, tileset_block_c.assemble_tileset_image(), tile_size)

	for position in Rect2iIterator.from_vector2(Vector2i(3, 1)):
		tileset_source_block_c.create_tile(position)
		tileset_source_block_c.set_tile_animation_columns(position, 1)
		tileset_source_block_c.set_tile_animation_separation(position, Vector2i(0, 0))
		tileset_source_block_c.set_tile_animation_frames_count(position, 4)
		tileset_source_block_c.set_tile_animation_speed(position, 4)

	# Block E F
	var tileset_block_ef = TilesetView.new(image.get_format(), Vector2i(2, 3), tile_size * Vector2i(6, 8))
	tileset_block_ef.set_image_unit_tile_data_from_list(image, [[2, 0], [3, 1], [2, 1], [4, 0], [3, 0], [4, 1]])

	var tileset_source_block_ef = create_tileset_source(tileset, tileset_block_ef.assemble_tileset_image(), tile_size)

	for position in Rect2iIterator.new(Rect2i(Vector2i(0, 0), Vector2i(12, 24))):
		tileset_source_block_ef.create_tile(position)

	return tileset


func convert_rpgmaker_2000_2003_tilesets(input_dir: String, output_dir: String):
	for filename in DirAccess.get_files_at(input_dir):
		if filename.to_lower().ends_with(".png"):
			var file = input_dir.path_join(filename)
			var tileset = create_rpgmaker_2000_2003_tileset(file)
			ResourceSaver.save(tileset, output_dir.path_join("%s.tres" % filename.substr(0, filename.length() - 4)))


func _run():
	var input_dir = "res://input/"
	var output_dir = "res://output/"
	for f in DirAccess.get_files_at(output_dir):
		DirAccess.remove_absolute(output_dir.path_join(f))
	DirAccess.remove_absolute(output_dir)
	DirAccess.remove_absolute(output_dir)
	DirAccess.make_dir_recursive_absolute(output_dir)

	convert_rpgmaker_2000_2003_tilesets(input_dir, output_dir)

	EditorInterface.get_resource_filesystem().scan()
	await EditorInterface.get_resource_filesystem().filesystem_changed
	return
