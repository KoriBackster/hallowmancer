@tool
extends Control

@onready var start_test: Button = $TestDraw
@onready var create_new: Button = $CreateNew
@onready var gesture_name_insert:LineEdit = $NewName
@onready var preview_options:OptionButton = $OptionButton
#@export var gesture_name:StringName
@export var preview_gesture:Variant:
	set(v):
		if v is GestureData:
			_preview_gesture = v
			return
		elif v is StringName:
			var known_gests:= Gesture.getKnown()
			for title in known_gests.keys():
				if title == v:
					_preview_gesture = known_gests[title]
					return
		elif v == null:
			_preview_gesture = v
	get():
		#var title:StringName = _preview_gesture.resource_name
		return _preview_gesture.resource_name as StringName if _preview_gesture else &""

var active_gest:Gesture
var _preview_gesture:GestureData:
	set(v):
		for ch in find_children("", "Line2D", true, false):
			ch.queue_free()
		if v:
			add_child(Gesture.newLineFromGesture(v.gesture, true,Color(Gesture.DEFAULT_LINE_COLOR, 0.2),Gesture.DEFAULT_LINE_WIDTH * 0.4))

func _ready() -> void:
	if Engine.is_editor_hint():return
	create_new.pressed.connect(
		func():
			if gesture_name_insert.text.is_empty() or Gesture.getKnown().keys().has(gesture_name_insert.text):
				print("invalid name")
				return
			create_new.disabled = true
			start_test.disabled = true

			var gest:=Gesture.new()
			active_gest = gest
			gest.complete.connect(func(v):
				if v:
					Gesture.Save(gesture_name_insert.text, v)
					print(v, gesture_name_insert.text)
				active_gest = null
				create_new.disabled = false
				start_test.disabled = false
				)
			add_sibling(gest)
	)
	start_test.pressed.connect(func():
		create_new.disabled = start_test.button_pressed
		gesture_name_insert.editable = not start_test.button_pressed
		if not start_test.button_pressed:
			active_gest.finalize()
			active_gest = null
			for ch in get_tree().root.find_children("", "Line2D", true, false):
				ch.queue_free()
			)
	preview_options.pressed.connect(func():
		
		#var selected:= preview_options.get_selectable_item()
		preview_options.clear()
		
		
		var known_gests:= Gesture.getKnown()
		for gest_ind in range(known_gests.keys().size()):
			preview_options.add_item(known_gests.keys()[gest_ind], gest_ind)
		
		preview_options.select(-1)
		_preview_gesture = null
		)
	preview_options.item_selected.connect(func(v:int):
		#var curr := preview_options.get_item_text(preview_options.get_selectable_item())
		var selected:= preview_options.get_item_text(v)
		#if selected == curr:
			#_preview_gesture = null
			#preview_options.select(-1)
			#return
		print(selected)
		_preview_gesture = Gesture.getKnown()[selected]
		)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():return
	var free_draw_mode :bool = start_test.button_pressed
	if free_draw_mode and not is_instance_valid(active_gest):
		var gest := Gesture.new()
		gest.complete.connect(func(v):
			print(Gesture.Verify(v)))
		add_sibling(gest)
		active_gest = gest
