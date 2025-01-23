class_name Enemy
extends Actor
## The base enemy class
##
## Everything all enemies should be able to do

@onready var attack1 := $Attack ## the first attack
var detected : Area2D = null ## the player that was detected
@onready var anim : AnimationState = $AnimationState

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if detected and anim.state != anim.SLASH:
		attack()


## Performs an attack
func attack() -> void: 
	var dist : float = detected.global_position.x - $Detector.global_position.x
	is_left = false if dist > 0 else true if dist < 0 else is_left
	anim.state = anim.SLASH


func _on_hitbox_area_entered(area: Area2D) -> void:
	if not area.is_in_group(&"Attack") or area.get_parent().is_in_group(&"Enemy"):
		return
	queue_free()


func _on_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group(&"Attack") or area.get_parent().is_in_group(&"Enemy"):
		return
	detected = area



func _on_detector_area_exited(area: Area2D) -> void:
	if area == detected:
		detected = null


func _on_animation_state_animation_finished(_anim_name: StringName) -> void:
	match(anim.state):
		anim.SLASH:
			anim.state = anim.IDLE
