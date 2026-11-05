extends Node
class_name NavigationComponent

@export var movement_component : MovementComponent
@export var navigation_agent : NavigationAgent2D
@export var enemy_base : CharacterBody2D # EXPERIMENTAL, MAYBE REMOVED LATER
@export var behavior_tree : BTPlayer

@onready var target : Vector2 = movement_component.character.global_position

func _ready() -> void:
	if not get_parent() is Monster2D: return
	
	var monster : Monster2D = get_parent()
	if monster.side == "ATTACKING":
		if get_tree().current_scene.find_child("EnemyBase"):
			enemy_base = get_tree().current_scene.get_node("EnemyBase")
		behavior_tree.blackboard.set_var("SideToAttack", "DEFENDING")
	else:
		if get_tree().current_scene.find_child("PlayerBase"):
			enemy_base = get_tree().current_scene.get_node("PlayerBase")
		behavior_tree.blackboard.set_var("SideToAttack", "ATTACKING")
	

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

func find_nearest_target(bt_triggered: bool = false) -> Vector2: # EXPERIMENTAL
	if not enemy_base:
		printerr("Enemy base not assigned", self)
		return target
	
	var closest : CharacterBody2D = null
	
	if not enemy_base.find_child("UnitFolder"):
		printerr("Unit folder not added", enemy_base)
		return target
		
	
	for node in enemy_base.get_node("UnitFolder").get_children():
		if not node is Monster2D: continue
		
		if closest == null:
			closest = node
			continue
		elif closest.global_position.distance_to(node.global_position) > closest.global_position.distance_to(target):
			closest = node
	if enemy_base.get_node("UnitFolder").get_child_count() <= 0: closest = enemy_base
			
	if bt_triggered and behavior_tree:
		target = closest.global_position
		behavior_tree.blackboard.set_var("NavigationTarget", closest.global_position)
	return closest.global_position

func reset_target() -> void:
	target = movement_component.character.global_position

func check_close_to_target() -> bool:
	var dist = movement_component.character.global_position.distance_to(target)
	if behavior_tree:
		behavior_tree.blackboard.set_var("CloseToTarget", dist < 3)
	return dist < 3
