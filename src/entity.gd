class_name  Entity
extends CharacterBody2D
## The parent class for players and enemies
##
## The parent class that covers everything that all entities uses
## such as collision shape and hitbox


@export var is_right := false ## the direction that the entity is facing
const GRAVITY := 400.0 ## how fast the entities accelerate to the floor
const HORIZ_VEL := 20.0 ## How fast the entities move horizontallyy
const MAX_vEL := 200.0 ## how fast the entitiy can end up


func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	move_and_slide()
