extends Node
class_name HealthComponent

@export var max_health : float = 100.0

@onready var current_health : float = max_health:
	set(new_health):
		if new_health > current_health: healed.emit(new_health)
		else: damaged.emit(new_health)
		
		current_health = new_health 

signal damaged(new_health)
signal healed(new_health)

func damage(amount: float) -> void:
	current_health -= amount

func heal(amount: float) -> void:
	damage(-amount)
