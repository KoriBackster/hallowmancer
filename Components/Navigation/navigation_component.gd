extends Node
class_name NavigationComponent

@export var movement_component : MovementComponent
@export var navigation_agent : NavigationAgent2D

var target : Vector2

func _process(_delta: float) -> void:
	navigation_agent.target_position = target
	if navigation_agent.is_navigation_finished():
		movement_component.direction = Vector2.ZERO
		return
	
	var target_path = navigation_agent.get_next_path_position()
	movement_component.direction = movement_component.character.global_position.direction_to(target_path)
