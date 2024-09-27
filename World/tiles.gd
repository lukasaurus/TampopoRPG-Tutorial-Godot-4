extends Node2D
@onready var tiles: Node2D = $"."
@onready var collisions: TileMapLayer = $Collisions
@onready var enemy_spawns: TileMapLayer = $EnemySpawns

@onready var over_land: TileMapLayer = $OverLand

func _ready():
	collisions.hide()
	enemy_spawns.hide()
	
	
func check_if_tile_hides_player(pos : Vector2i):
	if over_land:
		var tile : Vector2i = over_land.local_to_map(pos)
		var tile_data = over_land.get_cell_source_id(tile)
		if tile_data != -1:
			return over_land.tile_set.get_terrain_name(0,tile_data) in Globals.terrains_that_only_show_half_the_player_sprite
	return false#set_player_visibility()	
	
func set_monster_encounter_table(pos:Vector2i):
	if enemy_spawns:
		var tile : Vector2i = enemy_spawns.local_to_map(pos)
		var tile_data = enemy_spawns.get_cell_atlas_coords(tile)
		var id = (tile_data.y+8)*tile_data.y + tile_data.x 
		print(id)
		Globals.update_enemy_region_list(id)	
