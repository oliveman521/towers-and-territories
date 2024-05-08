extends Node2D
class_name Projectile

var dir: Vector2
var speed: float = 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += dir * speed * delta


func _on_area_2d_area_entered(area: Area2D) -> void:
	print(area)

func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body)
