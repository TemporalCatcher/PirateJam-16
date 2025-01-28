class_name  Actor
extends CharacterBody2D
## The parent class for players and enemies
##
## The parent class that covers everything that all entities uses
## such as collision shape and hitbox

@export var health : int = 10
@export var start_left := false
@export var is_left := start_left: ## the direction that the actor is facing
	set(left):
		if left == is_left:
			return
		scale.x = -1
		is_left = left
const GRAVITY := 400.0 ## how fast the entities accelerate to the floor
const HORIZ_VEL := 20.0 ## How fast the entities move horizontallyy
const MAX_VEL := 200.0 ## how fast the entitiy can end up


func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	move_and_slide()


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent() == self:
		return
	queue_free()
