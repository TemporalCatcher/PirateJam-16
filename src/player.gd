class_name Player
extends Entity
## The entity that the player controls
##
## This entity will contain all of the logic pertaining to the  player character

@onready var attack1 : Area2D = $Attack ## the first attack 
var gamepad := Gamepad.new() ## the input that the player uses


func _physics_process(delta: float) -> void:
	gamepad.get_control_state()
	
	velocity.x = horizontal_move(gamepad.direction.x)
	
	if gamepad.attack and $AtttackTime.is_stopped():
		attack()
	
	if gamepad.jump and velocity.y == 0:
		velocity.y -= 300.0
	
	velocity.y += GRAVITY * delta
	
	move_and_slide()


## the Horizontal movement of the player
func horizontal_move(x : float) -> float:
	if x == 0:
		var temp := velocity.x / 4.0
		return temp if abs(temp) > 0.5 else 0
	is_right = true if x > 0 else false if x < 0 else is_right
	return clamp(-MAX_vEL, x * HORIZ_VEL + velocity.x, MAX_vEL)


## The attack from the player
func attack() -> void:
	var coll := attack1.get_child(0) as CollisionShape2D
	var rect := coll.get_child(0) as CanvasItem
	attack1.position.x = 16 if is_right else -16
	coll.disabled = false
	rect.visible = true
	$AtttackTime.start(0.25)
		


func _on_atttack_time_timeout() -> void:
	var coll := attack1.get_child(0) as CollisionShape2D
	var rect := coll.get_child(0) as CanvasItem
	coll.disabled = true
	rect.visible = false
	$AtttackTime.stop()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		return
	queue_free()


## A Gamepad class to better manage inputs
##
## keeps track of the direction, jump, and attack inputs from the players
class Gamepad:
	var direction := Vector2(0, 0)
	var jump := false
	var attack := false
	
	func get_control_state() -> void:
		direction = Input.get_vector("left", "right", "up", "down")
		jump = Input.is_action_just_pressed("jump")
		attack = Input.is_action_just_pressed("action")
