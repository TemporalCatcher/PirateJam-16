class_name Player
extends Actor
## The entity that the player controls
##
## This entity will contain all of the logic pertaining to the  player character

@onready var attack1 : Area2D = $Attack ## the first attack 
@onready var anim_tree : AnimTree = $AnimTree
var gamepad := Gamepad.new() ## the input that the player uses


func _ready() -> void:
	anim_tree.controls[anim_tree.STANDARD].flip_check.connect(_on_flip_checked)
	anim_tree.flip_check.connect(_on_flip_checked)
	anim_tree.gamepad = gamepad
	

func _physics_process(delta: float) -> void:
	gamepad.get_control_state()
	
	update_animation()
	
	velocity.y += GRAVITY * delta
	move_and_slide()



func update_animation() -> void:
	var walls : int = int(is_on_floor()) + int(is_on_ceiling()) * 2 + 4 * int(is_on_wall())
	anim_tree.update_conditions(velocity, walls)
	velocity.x = anim_tree.x_move(gamepad.direction.x, velocity.x)
	if anim_tree["parameters/Standard/playback"].get_current_node() == &"Ground" and gamepad.jump:
		velocity.y -= 300.0


## The attack from the player
func attack(n : StringName) -> void:
	match n:
		&"spear":
			velocity = Vector2(pow(-1, is_left) * 250, -200)
		&"hammer":
			pass
		&"gauntlet":
			velocity = Vector2(pow(-1, is_left) * 200, -300)
		&"dash_slash":
			velocity = Vector2(pow(-1, is_left) * 800, 0)
		&"stop":
			velocity = Vector2.ZERO


func _on_hitbox_area_entered(area: Area2D) -> void:
	if not area.is_in_group(&"Attack") or area.get_parent().is_in_group(&"Player"):
		return
	queue_free()


func _on_flip_checked(x : float):
	is_left = false if x > 0 else true if x < 0 else is_left
