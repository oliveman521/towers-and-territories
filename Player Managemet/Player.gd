extends Node2D
class_name Player

var color: Color:
	get:
		return modulate
	set(new_val):
		modulate = new_val

var device_id: int = 0
@onready var current_tower: Tower = $"../../Tower":
	set(new_val):
		if current_tower:
			current_tower.deactivate()
		current_tower = new_val
		current_tower.activate()
@onready var scout: Area2D = $Scout
var scout_speed: float = 100
var has_landed: bool = false

var controlled_towers: Array[Tower]:
	get:
		var all_towers: Array[Node] = get_tree().get_nodes_in_group("Tower")
		var ct: Array[Tower] = []
		for t in all_towers:
			if t is Tower:
				if t.color == color:
					ct.append(t)
		return ct

var tower_switch_debounce: bool = false
func _ready() -> void:
	scout.global_position = RoundManager.instance.scout_spawn_point.global_position

func _process(delta: float) -> void:
	var joy_deadzine: float = 0.3
	var joystick_input: Vector2 = Vector2(Input.get_joy_axis(device_id,JOY_AXIS_LEFT_X),Input.get_joy_axis(device_id,JOY_AXIS_LEFT_Y))
	if joystick_input.length() > joy_deadzine:
		joystick_input = joystick_input.normalized()
	else:
		joystick_input = Vector2.ZERO
	var shoot_button: bool = Input.is_joy_button_pressed(device_id,JOY_BUTTON_X) || Input.get_joy_axis(device_id,JOY_AXIS_TRIGGER_RIGHT) >= 0.5
	
	var tower_switch_input: bool = Input.is_joy_button_pressed(device_id,JOY_BUTTON_B) || Input.get_joy_axis(device_id,JOY_AXIS_TRIGGER_LEFT) >= 0.5
		
		
	if controlled_towers.size() == 0: 
		if has_landed: #We were eliminated. The game should just let us rejoin
			queue_free()
			return
		global_position += scout_speed * joystick_input * delta
		if shoot_button:
			attempt_landing()
	else: 
		#shooting mode
		if !current_tower:
			current_tower = controlled_towers[0]
		
		if current_tower.color != color: #if the tower we're currently controlling has changed owners
			change_to_next_tower()
		
		if tower_switch_debounce == false && tower_switch_input && joystick_input != Vector2.ZERO:
			tower_switch_debounce = true
			change_tower(joystick_input)
		if !tower_switch_input:
			tower_switch_debounce = false
		
		current_tower.aim(joystick_input)
		current_tower.try_shoot(shoot_button, joystick_input)

func change_tower(joystick_input: Vector2) -> void:
	var towers: Array[Tower] = controlled_towers
	const alignment_threshold: float = 0.7
	var closest_tower: Tower = null
	var shorted_dist: float = INF
	for tower: Tower in towers:
		var difference: Vector2 = tower.global_position - current_tower.global_position
		var dir: Vector2 = difference.normalized()
		var dist: float = difference.length()
		var alignment_value: float = dir.dot(joystick_input) #-1 to 1
		if dist == 0:
			continue #this tower doesn't count
		if alignment_value > alignment_threshold:
			var weighted_dist: float = dist/pow(alignment_value,2)
			if weighted_dist < shorted_dist:
				closest_tower = tower
				shorted_dist = weighted_dist
	
	if closest_tower:
		current_tower = closest_tower

func change_to_next_tower() -> void:
	var towers: Array[Tower] = controlled_towers
	towers.sort_custom(func(a,b) -> bool:
		return a.global_position.x < b.global_position.x
	)
	
	var new_index: int = towers.find(current_tower) + 1
	new_index = wrap(new_index, 0, towers.size())
	current_tower = towers[new_index]

func attempt_landing() -> void:
	var tiles: Array[TerritoryTile]
	for area in scout.get_overlapping_areas():
		if area is TerritoryTile:
			tiles.append(area as TerritoryTile)
	for tile in tiles:
		if tile.connected_tower:
			if tile.connected_tower.player:
				if tile.connected_tower.player.controlled_towers.size() <= 1:
					return #cannot steal a player's last tower
			scout.visible = false
			tile.connected_tower.color = color
			has_landed = true
			tile.color = color
			tile.connected_tower.capture_neighbors()
			return

