class_name AnimTree
extends AnimationTree
## This class deals with all transitions of animations

signal flip_check(x : float)

enum {
	STANDARD,
	ATTACK,
	HURT,
}

enum {
	RESET = 0b0000,
	UP = 0b0010,
	DOWN = 0b0001,
	SIDE = 0b0100,
	NEUTRAL = 0b1000,
}

enum {
	FLOOR = 0b001,
	CEILING = 0b010,
	WALL = 0b100,
}


var control : int = STANDARD
var controls : Array[State] = [
	Standard.new(self),
	Attack.new(self),
	Damaged.new(self),
]

var gamepad : Gamepad ## The gamepad used by the parent player
var direction : int = RESET ## The directions for attack
var direction_done : int = RESET ## The directions of previous attacks while in air
var contact_walls : int = RESET ## directions of walls
var velocity := Vector2.ZERO ## the velocity of the parent player
var queued : int = RESET ## The attack that is queued
var queueable := true ## if attack is queueable


func update_conditions(vel : Vector2, walls : int) -> void:
	queued = RESET
	contact_walls = walls
	velocity = vel
	match self[&"parameters/playback"].get_current_node():
		&"Standard":
			control = STANDARD
			if walls & FLOOR:
				direction_done = RESET
				queueable = true
		&"Attack":
			control = ATTACK


func gamepad_direction() -> int:
	var dir = gamepad.direction
	if dir == Vector2.ZERO:
		return NEUTRAL
	if abs(dir.y) >= abs(dir.x):
		return UP if dir.y < 0 else DOWN
	return SIDE


func is_attack_queued() -> bool:
	if queueable and gamepad.attack:
		var dir := gamepad_direction()
		if not (dir & direction_done):
			flip_check.emit(gamepad.direction.x)
			direction = dir
			queued = dir
			direction_done += dir
			queueable = false
			return true
	return false


func is_combo_queued(dir : int) -> bool:
	if queueable and gamepad.attack:
		var dire := gamepad_direction()
		if dir ==  dire:
			direction = dir
			queueable = false
			return true
	return false


func make_queueable() -> void:
	queueable = true


func x_move(x : float, x_vel : float) -> float:
	return controls[control]._x_move(x, x_vel)


func y_move() -> float:
	return 0.0


func is_exit_ground() -> bool:
	return gamepad.jump or is_exit_standard()


func is_exit_standard() -> bool:
	return is_attack_queued()


func has_landed() -> bool:
	if contact_walls & FLOOR:
		direction_done = direction
		return true
	return false



class State:
	signal flip_check(x : float)
	const HORIZ_VEL = Player.HORIZ_VEL
	const MAX_VEL = Player.MAX_VEL
	var anim : AnimTree
	
	func _init(animation : AnimTree) :
		anim = animation
	
	
	func _x_move(x : float, x_vel : float) -> float:
		if x == 0.0:
			return max(abs(x_vel) - HORIZ_VEL / 2.0, 0.0) * sign(x_vel)
		flip_check.emit(x)
		return clamp(-MAX_VEL, x * HORIZ_VEL + x_vel, MAX_VEL)


class Standard extends State:
	pass


class Attack extends State:
	func _x_move(x : float, x_vel : float) -> float:
		if anim.direction == SIDE:
			return x_vel
		if anim.contact_walls & 1:
			return max(abs(x_vel) - HORIZ_VEL / 2.0, 0.0) * sign(x_vel)
		return super._x_move(x, x_vel)


class Damaged extends State:
	func _x_move(_x : float, x_vel : float) -> float:
		return x_vel
