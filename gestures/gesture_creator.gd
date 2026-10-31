extends Control
@onready var button_2: Button = $Button2

@onready var button: Button = $Button
@export var gesture_name:StringName
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.pressed.connect(
		func():
			button.disabled = true

			var gest:=Gesture.new()
			active_gest = gest
			gest.complete.connect(func(v):
				if v:
					Gesture.Save(gesture_name, v)
					print(v)
				button.disabled = false
				active_gest = null
				)
			add_sibling(gest)
	)
	button_2.pressed.connect(func():
		button.disabled = button_2.button_pressed
		if not button_2.button_pressed:
			active_gest.finalize()
			active_gest = null
			for ch in get_tree().root.find_children("", "Line2D", true, false):
				ch.queue_free()
			)

var active_gest:Gesture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var free_draw_mode :bool = button_2.button_pressed

	if free_draw_mode and not is_instance_valid(active_gest):
			var gest := Gesture.new()
			gest.complete.connect(func(v):
				print(Gesture.Verify(v)))
			add_sibling(gest)
			active_gest = gest
