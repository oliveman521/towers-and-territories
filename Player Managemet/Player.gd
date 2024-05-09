extends Node
class_name Player

var color: Color
var device_id: int = 0
@onready var current_tower: Tower = $"../../Tower"

var controlled_towers: Array[Tower]


var shoot_debounce: bool = false #for making sure we soot semi auto
func _process(delta: float) -> void:
	if controlled_towers.size() == 0: 
		#Bird Mode
		pass
	else: 
		#shooting mode
		if !current_tower:
			current_tower = controlled_towers[0]
			
		var joystick_input: Vector2 = Vector2(Input.get_joy_axis(device_id,JOY_AXIS_LEFT_X),Input.get_joy_axis(device_id,JOY_AXIS_LEFT_Y))
		var shoot_button: bool = Input.is_joy_button_pressed(device_id,JOY_BUTTON_X) || Input.get_joy_axis(device_id,JOY_AXIS_TRIGGER_RIGHT) >= 0.5
		if joystick_input != Vector2.ZERO && shoot_button && !shoot_debounce:
			shoot_debounce = true
			current_tower.shoot(joystick_input)
		if !shoot_button:
			shoot_debounce = false
