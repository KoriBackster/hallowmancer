@tool extends Node
# SIMPLE SOLUTION, NOT FULLY IMPLEMENTED


@export_storage var monster_node : Monster2D

func _ready() -> void:
	if not Engine.is_editor_hint():
		return
	monster_node = get_parent()

@export_tool_button("update_visuals") var update_root := func():
	var monster_skin_node :Sprite2D= monster_node.find_child("Sprite2D")
	if not monster_skin_node:
		return
	monster_skin_node.texture = monster_node.texture
