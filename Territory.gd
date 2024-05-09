extends Area2D
class_name Territory_Tile

var color: Color:
	get:
		return modulate
	set(new_val):
		modulate = new_val
		if color != new_val:
			color_changed.emit()

signal color_changed
