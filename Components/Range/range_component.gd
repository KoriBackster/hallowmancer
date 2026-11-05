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

func check_enemies(side: String = "DEFENDING") -> bool:
	for obj in objects_in_range:
		if not obj is Monster2D:
			behavior_tree.blackboard.set_var("EnemiesBound", false)
			return false
		var monster : Monster2D = obj
		if monster.side == side:
			behavior_tree.blackboard.set_var("EnemiesBound", monster.side == side)
			return true
	behavior_tree.blackboard.set_var("EnemiesBound", false)
	return false
