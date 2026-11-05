extends Control

@export var first_level: PackedScene


#func _on_play_pressed() -> void:
	#get_tree().change_scene_to_packed(first_level)


func _on_glyph_guide_glyph_made(gesture: Curve2D) -> void:
	if Gesture.Verify(gesture) == &"starter":
		get_tree().change_scene_to_packed(first_level)
