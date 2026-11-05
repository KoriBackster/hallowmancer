extends Control

#@export var first_level: PackedScene
@onready var GAME_SCENE:= preload(Config.GAME_SCENE)

func _ready() -> void:
	queue_animation()
	$GlyphGuide.glyph_made.connect(_on_glyph_guide_glyph_made)


func queue_animation()->void:
	get_tree().create_timer(randfn(6,2)).timeout.connect(func():
		var anim_pl:= $AnimationPlayer
		anim_pl.play(&"chase")
		anim_pl.animation_finished.connect(queue_animation.unbind(1))
		)

func _on_glyph_guide_glyph_made(gesture: Curve2D) -> void:
	match Gesture.Verify(gesture):
		&"starter":
			var tree:= get_tree()
		
			#tree.unload_current_scene()
			tree.change_scene_to_packed(load(Config.GAME_SCENE))
