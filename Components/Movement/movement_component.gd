extends Node
class_name MovementComponent

@export var character : CharacterBody2D
@export var using_gravity : bool = true
var max_speed : float = 125.0
var direction : Vector2
var current_speed : float
var acceleration : float = 2.5
var slowdown_acceleration_multiplier : float = 4.0
var gravity : float = 9.81

func _physics_process(_delta: float) -> void:
	if not character:
		printerr("yo forgot to assign character!", self)
		return
	
	character.velocity = update_platform_speed(character.velocity) if using_gravity else update_topdown_speed(character.velocity)
	character.move_and_slide()

func update_platform_speed(current_velocity: Vector2) -> Vector2:
	current_velocity.y += gravity
	current_speed = move_toward(current_speed, max_speed, acceleration)
	var xvel = move_toward(current_velocity.x, direction.x * current_speed, acceleration)
	return Vector2(xvel, current_velocity.y)

func update_topdown_speed(current_velocity: Vector2) -> Vector2:
	current_speed = move_toward(current_speed, max_speed, acceleration)
	return current_velocity.move_toward(direction * current_speed, acceleration)
