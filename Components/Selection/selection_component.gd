extends Node
class_name SelectionComponent

const MOVE_MARKER = preload("uid://dg5lau3faijus")


@onready var range_component: RangeComponent = $RangeComponent
@onready var selection_polygon: Polygon2D = $SelectionPolygon
var current_selection : CollisionShape2D
var origin : Vector2
var rect : Rect2

var group_selection : Array[Monster2D]

func _process(_delta: float) -> void:
	send_target()
	
	if not Input.is_action_pressed("select"):
		if current_selection:
			current_selection.queue_free()
			add_to_group_selection()
		selection_polygon.visible = false
		return
	
	var mouse_pos : Vector2 = range_component.get_global_mouse_position()
	selection_polygon.visible = true
	
	if not current_selection:
		var new_selection = CollisionShape2D.new()
		new_selection.shape = RectangleShape2D.new()
		range_component.add_child(new_selection)
		current_selection = new_selection
		origin = mouse_pos
		
	
	rect = Rect2(origin, Vector2.ZERO).expand(mouse_pos)
	current_selection.global_position = rect.get_center()
	current_selection.shape.size = rect.size

	selection_polygon.global_position = rect.position
	selection_polygon.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(rect.size.x, 0),
		rect.size,
		Vector2(0, rect.size.y),
	])
	

func add_to_group_selection() -> void:
	group_selection.clear()
	for minion : Monster2D in range_component.objects_in_range:
		if minion.side == "ATTACKING":
			group_selection.append(minion)
	#print(group_selection)

func send_target() -> void:
	if not Input.is_action_just_pressed("move"): return
	
	var mouse_pos := range_component.get_global_mouse_position()
	
	for minion : Monster2D in group_selection:
		minion.get_node("NavigationComponent").target = mouse_pos
	var c_marker = MOVE_MARKER.instantiate()
	get_tree().current_scene.add_child(c_marker)
	c_marker.global_position = mouse_pos
	$MoveSound.play()
