extends Area2D
class_name RangeComponent

var objects_in_range : Array[CharacterBody2D]



func _on_body_entered(body: Node2D) -> void:
	if not body is CharacterBody2D: return
	objects_in_range.append(body)


func _on_body_exited(body: Node2D) -> void:
	if not body in objects_in_range: return
	objects_in_range.pop_at(objects_in_range.find(body))
