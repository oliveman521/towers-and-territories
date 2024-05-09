extends Node2D
class_name Projectile

var dir: Vector2
var speed: float = 100

var color: Color:
	get:
		return modulate
	set(new_val):
		modulate = new_val

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += dir * speed * delta


func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_queued_for_deletion(): return #dont do shit if we've already hit something
	
	if area is Territory_Tile:
		var ter: Territory_Tile = area as Territory_Tile
		if ter.color != color:
			ter.color = color
			queue_free()
