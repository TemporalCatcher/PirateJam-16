class_name Gamepad
extends Object
## A Gamepad class to better manage inputs
##
## keeps track of the direction, jump, and attack inputs from the players

var direction := Vector2(0, 0) ## the direction of the gamepad
var jump := false ## the jump input of the gamepad
var attack := false ## the attack input of the gamepad
var attack_hold := false ## the attack input being held on the gamepad

func get_control_state() -> void:
	direction = Input.get_vector("left", "right", "up", "down")
	if direction.length_squared() > 1:
		direction = direction.normalized()
	jump = Input.is_action_just_pressed("jump")
	attack = Input.is_action_just_pressed("action")
	attack_hold = Input.is_action_pressed("action")
