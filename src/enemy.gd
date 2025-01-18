class_name Enemy
extends Entity
## The base enemy class
##
## Everything all enemies should be able to do

@onready var attack1 := $Attack ## the first attack
var detected : Area2D = null ## the player that was detected


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if detected and $AtttackTime.is_stopped():
		attack()


## Performs an attack
func attack() -> void: 
	var coll := attack1.get_child(0) as CollisionShape2D
	var rect := coll.get_child((0)) as CanvasItem
	var dist : float = detected.global_position.x - $Detector.global_position.x
	is_right = true if dist > 0 else false if dist < 0 else is_right
	attack1.position.x = 16 if is_right else -16
	coll.disabled = false
	rect.visible = true
	$AtttackTime.start(1)


func _on_hitbox_area_entered(area: Area2D) -> void:
	queue_free()


func _on_detector_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		return
	detected = area


func _on_atttack_time_timeout() -> void:
	var coll := attack1.get_child(0) as CollisionShape2D
	var rect := coll.get_child((0)) as CanvasItem
	coll.disabled = true
	rect.visible = false
	$AtttackTime.stop()


func _on_detector_area_exited(area: Area2D) -> void:
	if area.is_in_group("Enemy"):
		return
	detected = null
