extends Node
class_name RoundManager



var min_towers_for_victory: int = 10
var total_time: float = 10 * 60
var time_remaining: float = 0;
@onready var scout_spawn_point: Marker2D = $"Scout Spawn Point"

static var instance: RoundManager
@onready var win_label = $"Win Label"

var all_tiles: Array[TerritoryTile]:
	get:
		var tiles: Array[TerritoryTile] = []
		for c in GameMap.instance.get_children():
			if c is TerritoryTile:
				tiles.append(c)
		return tiles

func _ready():
	instance = self
	
	time_remaining = total_time * 0.8
	
	var number_box: HBoxContainer = $"Number Line/Number Box"
	for c: Node in number_box.get_children():
		c.queue_free()
	const NUMBER_PREFAB: PackedScene = preload("res://UI/number_line_number.tscn")
	for i in range(0,all_tiles.size(),25):
		var new_number: Label = NUMBER_PREFAB.instantiate() as Label
		new_number.text = str(i + 1)
		number_box.add_child(new_number)

func _process(delta):
	var percent_time_remaining: float = (time_remaining / total_time)
	
	
	#Check Victory
	for player in GameManager.players:
		var percent_map_controlled: float = (float(player.controlled_tiles.size()) / all_tiles.size())
		if percent_map_controlled >= percent_time_remaining:
			win_label.visible = true
			win_label.text = "Player " + str(player.device_id) + " Wins!"
			win_label.modulate = Color.TRANSPARENT
			var tween: Tween = get_tree().create_tween()
			tween.tween_property(win_label,"modulate",player.color,2)
	
	#Victory Number Line
	time_remaining -= delta
	var progress_bar: ColorRect = $"Number Line/Progress Bar" as ColorRect
	progress_bar.scale.x = percent_time_remaining
	
	var player_markers_container: Control = $"Number Line/Player Markers" as Control
	const player_marker_prefab: PackedScene = preload("res://UI/number_line_player_marker.tscn") as PackedScene
	var number_line: Control = $"Number Line" as Control

	for c: Node in player_markers_container.get_children():
		c.queue_free()
	
	for player: Player in GameManager.players:
		var new_marker: Node2D = player_marker_prefab.instantiate() as Node2D
		
		var width: float = number_line.get_rect().size.x
		var step: float = width / all_tiles.size()
		var x_pos: float = player.controlled_tiles.size() * step
		var y_pos: float = number_line.size.y/2
		for c:Node2D in player_markers_container.get_children():
			if c.is_queued_for_deletion(): continue
			if c.modulate == player.color: continue
			if int(c.position.x) == int(x_pos):
				y_pos += 10
		new_marker.global_position = Vector2(x_pos, y_pos)
		new_marker.modulate = player.color
		player_markers_container.add_child(new_marker)
