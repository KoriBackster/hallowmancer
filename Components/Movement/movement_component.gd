extends Node
class_name MovementComponent

@export var character : CharacterBody2D
var max_speed : float
var direction : Vector2
var current_speed : float
var acceleration : float
var slowdown_acceleration_multiplier : float = 4.0

func _physics_process(_delta: float) -> void:
	if acceleration != 0:
		if direction: current_speed = move_toward(current_speed, max_speed, acceleration)
		else: current_speed = move_toward(current_speed, 0, acceleration * slowdown_acceleration_multiplier)
	else:
		if direction: current_speed = max_speed
		else: current_speed = 0
	
	character.velocity = direction * current_speed
	character.move_and_slide()
