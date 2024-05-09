extends Node2D
class_name Tower

@onready var tower_fill: ColorRect = $"Tower Fill"
@onready var tower_orb: Sprite2D = $TowerOrb

@export var color: Color:
	set(new_val):
		color = new_val
		if !is_node_ready():
			await ready
		tower_fill.self_modulate = color
		tower_orb.self_modulate = color

@export var charge_rate: float = 1
@export var max_charge: int = 6
@export var current_charge: float = 0

const PROJECTILE: PackedScene = preload("res://projectile.tscn")
@onready var projectile_container: Node2D = %"Projectile Container"
@onready var tile_map: TileMap = %TileMap

var input_device: int = 0
var connected_tile: Territory_Tile

func _ready() -> void:
	
	#align to the closest tile
	global_position = tile_map.to_global(tile_map.map_to_local(tile_map.local_to_map(tile_map.to_local(global_position))))
	
	for c: Node in tile_map.get_children():
		if c is Territory_Tile:
			var ter: Territory_Tile = c as Territory_Tile
			if ter.global_position == global_position:
				connected_tile = ter
	
	connected_tile.color_changed.connect(func()->void:
		color = connected_tile.color
		)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_charge += delta * charge_rate
	current_charge = clamp(current_charge,0,max_charge)
	var percent_max_charge: float = current_charge / max_charge
	tower_fill.scale.y = percent_max_charge

func shoot(dir: Vector2) -> void:
	if current_charge < 1: return
	dir = dir.normalized()
	current_charge -= 1
	var new_projectile: Projectile = PROJECTILE.instantiate()
	new_projectile.global_position = global_position
	new_projectile.dir = dir
	new_projectile.color = color
	projectile_container.add_child(new_projectile)
