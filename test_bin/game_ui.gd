extends Control
@onready var mana_label: Label = %ManaLabel
@onready var mana_pool: ProgressBar = %ManaPool

@onready var MENU_SCENE:= preload(Config.MENU_SCENE)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mana_label.text = "%2.2f / %2.2f" %[mana_pool.value, mana_pool.max_value]
	%GlyphGuide.glyph_made.connect(summoner_glyph_made)

func summoner_glyph_made(glyph:Curve2D):
	match Gesture.Verify(glyph):
		"starter":
			var tree:=get_tree()
			#tree.unload_current_scene()
			tree.change_scene_to_packed(load(Config.MENU_SCENE))
	#print(Gesture.Verify(glyph))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



#func _on_glyph_guide_2_mouse_entered() -> void:
	#active_gesture = Gesture.new()
	#active_gesture.complete.connect(summoner_glyph_made)
	#add_sibling(active_gesture)




func _on_mana_pool_value_changed(value: float) -> void:
	mana_label.text = "%2.2f / %2.2f" %[mana_pool.value, mana_pool.max_value]
