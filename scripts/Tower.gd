extends Node2D
class_name Tower

@onready var tower_fill: ColorRect = $"Tower Fill"
@onready var tower_orb: Sprite2D = $TowerOrb

@export var color: Color

@export var charge_rate: float = 1
@export var max_charge: int = 6
@export var current_charge: float = 0

const PROJECTILE: PackedScene = preload("res://projectile.tscn")
@onready var projectile_container: Node2D = %"Projectile Container"


func _ready() -> void:
	tower_fill.self_modulate = color
	tower_orb.self_modulate = color


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	current_charge += delta * charge_rate
	current_charge = clamp(current_charge,0,max_charge)
	var percent_max_charge: float = current_charge / max_charge
	tower_fill.scale.y = percent_max_charge
	
	if Input.is_action_just_pressed("ui_right"):
		fire(Vector2.RIGHT)

func fire(dir: Vector2) -> void:
	if current_charge < 1: return
	current_charge -= 1
	var new_projectile: Projectile = PROJECTILE.instantiate()
	new_projectile.global_position = global_position
	new_projectile.dir = dir
	projectile_container.add_child(new_projectile)
