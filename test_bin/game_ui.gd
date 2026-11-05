extends Control
@onready var mana_label: Label = %ManaLabel
@onready var mana_pool: ProgressBar = %ManaPool


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mana_label.text = "%2.2f / %2.2f" %[mana_pool.value, mana_pool.max_value]

func summoner_glyph_made(glyph:Curve2D):
	match Gesture.Verify(glyph):
		"starter":
			print("HelloWorld")
	#print(Gesture.Verify(glyph))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var active_gesture:Gesture

func _on_glyph_guide_2_gui_input(event: InputEvent) -> void:
	
	if not is_instance_valid(active_gesture):
		#print('s')
		active_gesture = Gesture.new()
		active_gesture.complete.connect(summoner_glyph_made)
		add_sibling(active_gesture)


#func _on_glyph_guide_2_mouse_entered() -> void:
	#active_gesture = Gesture.new()
	#active_gesture.complete.connect(summoner_glyph_made)
	#add_sibling(active_gesture)


func _on_glyph_guide_2_mouse_exited() -> void:
	if active_gesture:
		active_gesture.finalize()


func _on_mana_pool_value_changed(value: float) -> void:
	mana_label.text = "%2.2f / %2.2f" %[mana_pool.value, mana_pool.max_value]
