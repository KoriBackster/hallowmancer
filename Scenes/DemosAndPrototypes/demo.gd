extends Button

const MINION = preload("uid://b0wqg4ggqdkxy")

func _on_pressed() -> void:
	var minion = MINION.instantiate()
	get_tree().current_scene.add_child(minion)
