extends Area2D
class_name TerritoryTile

var color: Color:
	get:
		return modulate
	set(new_val):
		modulate = new_val
		if connected_tower:
			connected_tower.color = new_val
		if color != new_val:
			color_changed.emit()

signal color_changed

var connected_tower: Tower = null



func _on_body_entered(body: Node2D) -> void:
	if body is Projectile:
		body.collided_with(self)
