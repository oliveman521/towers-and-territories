extends TileMap

var main_layer: int = 0
var main_atlas_id: int = 0

const TERRITORY_TILE: PackedScene = preload("res://territory_tile.tscn")

func _ready() -> void:
	get_used_cells_by_id(main_layer,0)


func _input(event: InputEvent) -> void:
	if not event is InputEventMouse: return
	var mouse_event: InputEventMouse = event as InputEventMouse
	if mouse_event.button_mask != MOUSE_BUTTON_LEFT: return
	if not mouse_event.is_pressed(): return
	
	var cell_clicked: Vector2i = local_to_map(mouse_event.position)
	print(cell_clicked)
	var atlas_coord: Vector2i = get_cell_atlas_coords(main_layer,cell_clicked)
	var current_tile_alt: int = get_cell_alternative_tile(main_layer,cell_clicked)
	var alt_count: int = tile_set.get_source(main_atlas_id).get_alternative_tiles_count(atlas_coord)
	
	tile_set
	
	#set_cell(main_layer,cell_clicked,main_atlas_id,atlas_coord,(current_tile_alt + 1) % alt_count)
