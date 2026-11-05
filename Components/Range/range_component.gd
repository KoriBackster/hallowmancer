extends Area2D
class_name RangeComponent

@export var behavior_tree: BTPlayer

var objects_in_range : Array[CharacterBody2D]

func _on_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D: return
	objects_in_range.append(body)


func _on_body_exited(body: Node2D) -> void:
	if not body is CharacterBody2D or not body in objects_in_range: return
	objects_in_range.pop_at(objects_in_range.find(body))

func check_enemies(side: String = "DEFENDING") -> bool: # Check for enemies of this side
	for obj in objects_in_range:
		if not obj is Monster2D:
			behavior_tree.blackboard.set_var("EnemiesBound", false)
			continue
		var monster : Monster2D = obj
		if monster.side == side:
			behavior_tree.blackboard.set_var("EnemiesBound", true)
			return true
	behavior_tree.blackboard.set_var("EnemiesBound", false)
	return false

func return_enemies(side: String = "DEFENDING") -> Array[Monster2D]: # Check for enemies of this side
	var temp : Array[Monster2D]
	for obj in objects_in_range:
		if not obj is Monster2D: continue
		var monster : Monster2D = obj
		if monster.side == side:
			temp.append(monster)
	return temp
