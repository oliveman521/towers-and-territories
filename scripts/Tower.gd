extends Node2D
class_name Tower

@onready var tower_fill: ColorRect = $"Tower Fill"
@onready var tower_top: Sprite2D = $"Tower Top"

@export var color: Color = Color.WHITE:
	set(new_val):
		targeting_arrow.visible = false
		ready_to_shoot = false
		color = new_val
		if !is_node_ready():
			await ready
		tower_fill.self_modulate = color
		tower_top.self_modulate = color

var player: Player:
	get:
		return GameManager.get_player_by_color(color)

@export var base_charge_rate: float = 0.8
@export var max_charge: int = 6
@export var current_charge: float = 0
@export var full_auto: bool = true
@export_range(1,10) var projectiles_per_shot: int = 1
@export var firing_arc_degrees: float = 0



const PROJECTILE: PackedScene = preload("res://projectile.tscn")
@onready var projectile_container: Node2D = %"Projectile Container"
@onready var tile_map: TileMap = %TileMap

var input_device: int = 0
var connected_tile: TerritoryTile
@onready var targeting_arrow = $TargetingArrow
@onready var highlight: Sprite2D = $Highlight


func aim(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		targeting_arrow.visible = false
	else:
		targeting_arrow.visible = true
		targeting_arrow.rotation = dir.angle()

func activate() -> void:
	targeting_arrow.visible = true
	highlight.visible = true
	
func deactivate() -> void:
	targeting_arrow.visible = false
	highlight.visible = false
	
func capture_neighbors() -> void:
	var capture_area: Area2D = $"Capture Area" as Area2D
	var tiles: Array[Area2D] = capture_area.get_overlapping_areas()
	for area: Area2D in tiles:
		if area is TerritoryTile:
			var tile = area as TerritoryTile
			tile.color = color


func _ready() -> void:
	targeting_arrow.visible = false
	highlight.visible = false
	
	#align to the closest tile
	global_position = tile_map.to_global(tile_map.map_to_local(tile_map.local_to_map(tile_map.to_local(global_position))))
	
	for c: Node in tile_map.get_children():
		if c is TerritoryTile:
			var ter: TerritoryTile = c as TerritoryTile
			if ter.global_position == global_position:
				connected_tile = ter
	
	connected_tile.connected_tower = self
	connected_tile.color_changed.connect(func()->void:
		color = connected_tile.color
		)
	
	var tower_body: Node2D = $"Tower body" as Node2D
	const tower_line_prefab: PackedScene = preload("res://tower_line.tscn") as PackedScene
	var bottom_marker: Marker2D = $"Tower body/Bottom Marker"  as Node2D
	var top_marker: Marker2D = $"Tower body/Top Marker"  as Node2D
	var step: Vector2 = (top_marker.global_position - bottom_marker.global_position) / max_charge
	for i in range(max_charge):
		#Currently spawns extra line right at the bottom. Probably doesn't matter
		var new_line: Line2D = tower_line_prefab.instantiate() as Line2D
		new_line.position = bottom_marker.position + i * step
		tower_body.add_child(new_line)

@export var charge_rate_curve: Curve
func _process(delta: float) -> void:
	var percent_charged: float = current_charge / max_charge
	var current_charge_rate: float = charge_rate_curve.sample(percent_charged) * base_charge_rate
	current_charge += delta * current_charge_rate
	current_charge = clamp(current_charge,0,max_charge)
	var percent_max_charge: float = current_charge / max_charge
	tower_fill.scale.y = percent_max_charge

var ready_to_shoot: bool = true
var shoot_cooldown: float = 0.15
@onready var shoot_cooldown_timer: Timer = $ShootCooldownTimer

func try_shoot(button_pressed: bool, dir: Vector2) -> void:
	if dir != Vector2.ZERO && button_pressed && ready_to_shoot:
		shoot(dir)
		ready_to_shoot = false
		shoot_cooldown_timer.wait_time = shoot_cooldown
		shoot_cooldown_timer.start()
	
	if full_auto:
		if shoot_cooldown_timer.time_left == 0:
			ready_to_shoot = true
	else:
		if button_pressed == false:
			ready_to_shoot = true

func shoot(dir: Vector2) -> void:
	if current_charge < 1: return
	dir = dir.normalized()
	var shoot_angle: float  = rad_to_deg(dir.angle())
	var min_angle: float = shoot_angle - firing_arc_degrees/2
	
	current_charge -= 1
	for i in range(projectiles_per_shot):
		var new_projectile: Projectile = PROJECTILE.instantiate()
		new_projectile.global_position = global_position
		if projectiles_per_shot > 1:
			var angle_step: float = firing_arc_degrees / (projectiles_per_shot-1)
			var new_shoot_angle: float = min_angle + angle_step * i
			dir = Vector2.from_angle(deg_to_rad(new_shoot_angle)).normalized()
		
		new_projectile.dir = dir 
		new_projectile.color = color
		projectile_container.add_child(new_projectile)
