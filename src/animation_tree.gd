class_name AnimTree
extends AnimationTree

enum {
	STANDARD,
	ATTACK,
	HURT,
}

const ZERO := Vector2.ZERO
const LEFT := Vector2.LEFT
const RIGHT := Vector2.RIGHT
const UP := Vector2.UP
const DOWN := Vector2.DOWN

var control : int = STANDARD
var controls : Array[State] = [
	Standard.new(self),
	Attack.new(self),
	Damaged.new(self),
]

var jump := false
var fall := false
var fast_fall := false
var ground := false
var move := false
var attack := false
var contact := false
var direction:= Vector2.ZERO


func update_conditions(pad : Gamepad, vel : Vector2, walls : int) -> void:
	ground = walls & 1
	jump = pad.jump
	fall = not ground and vel.y >= 0
	fast_fall = vel.y > 200
	move = pad.direction.x != 0
	attack = pad.attack
	contact = bool(walls)
	var dir := pad.direction
	if pad.attack:
		direction = Vector2(abs(dir.x), dir.y).normalized()
	match self[&"parameters/playback"].get_current_node():
		&"Standard":
			control = STANDARD
		&"Attack":
			control = ATTACK			


func x_move(x : float, x_vel : float) -> float:
	return controls[control]._x_move(x, x_vel)


func y_move() -> float:
	return 0.0


class State:
	signal flip_check(x : float)
	const HORIZ_VEL = Player.HORIZ_VEL
	const MAX_VEL = Player.MAX_VEL
	var anim : AnimTree
	
	func _init(animation : AnimTree) :
		anim = animation
	
	
	func _x_move(x : float, x_vel : float) -> float:
		
		if x == 0.0:
			var temp : float = x_vel - HORIZ_VEL * sign(x_vel) / 2.0
			return temp if abs(temp) > 0.5 else 0.0
		flip_check.emit(x)
		return clamp(-MAX_VEL, x * HORIZ_VEL + x_vel, MAX_VEL)


class Standard extends State:
	pass


class Attack extends State:
	func _x_move(x : float, x_vel : float) -> float:
		if anim.direction == Vector2.RIGHT:
			return x_vel
		if anim.ground:
			var temp : float = x_vel - HORIZ_VEL * sign(x_vel) / 2.0
			return temp if abs(temp) > 0.5 else 0.0
		return super._x_move(x, x_vel)


class Damaged extends State:
	func _x_move(_x : float, x_vel : float) -> float:
		return x_vel
