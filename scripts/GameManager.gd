extends Node

var colors: Array[Color] = [
	Color("#ff595e"),
	Color("#ffca3a"),
	Color("#8ac926"),
	Color("#1982c4"),
	Color("#6a4c93"),
	Color("#ff924c"),
	Color("#4267ac"),
	Color("#35264a"),
]

var players: Array[Player]:
	get:
		var ps: Array[Player] = []
		for c in get_children():
			if c is Player:
				ps.append(c as Player)
		return ps

var max_players: int = colors.size()

func _process(delta: float) -> void:
	for device_id in range(max_players):
		if Input.is_joy_button_pressed(device_id,JOY_BUTTON_A):
			var player_already_connected = players.any(func(p: Player) -> bool: return p.device_id == device_id)
			if !player_already_connected:
				add_player(device_id)

func add_player(device_id: int) -> void:
	print(device_id)
	const player_prefab = preload("res://Player Managemet/player.tscn")
	var new_player: Player = player_prefab.instantiate() as Player
	add_child(new_player)
	new_player.device_id = device_id
