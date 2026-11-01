extends Node
class_name NavigationComponent

@export var movement_component : MovementComponent
@export var navigation_agent : NavigationAgent2D
@export var enemy_base : CharacterBody2D # EXPERIMENTAL, MAYBE REMOVED LATER

@onready var target : Vector2 = movement_component.character.global_position

func _process(_delta: float) -> void:
	if not movement_component or not navigation_agent:
		printerr("yo forgot yo components!", self)
		return
	
	navigation_agent.target_position = target
	if navigation_agent.is_navigation_finished():
		movement_component.direction = Vector2.ZERO
		return
	
	var target_path = navigation_agent.get_next_path_position()
	movement_component.direction = movement_component.character.global_position.direction_to(target_path)

func set_target(target_node: Node2D) -> void:
	target = target_node.global_position

func find_nearest_target() -> void: # EXPERIMENTAL
	if not enemy_base:
		printerr("Enemy base not assigned", self)
		return
	
	var closest : Monster2D = null
	for node in enemy_base.get_children():
		if not node is Monster2D: continue
		
		if closest == null:
			closest = node
			continue
		elif closest.global_position.distance_to(node.global_position) > closest.global_position.distance_to(target):
			closest = node
			
	target = closest.global_position
