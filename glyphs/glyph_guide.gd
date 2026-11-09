@tool
class_name GlyphGuide extends TextureRect

signal glyph_made(glyph:Curve2D)

#enum PreviewStyle { BASIC, PULSE, TRAVEL}
var active_glyph:Glyph
const DEFAULT_SIZE:Vector2=Vector2.ONE * 648
#@export_storage var previewed_glyph:GlyphPreview

@export var glyph_preview_data:GlyphPreviewData

@onready var glyph_fatigue:Timer = $FatigueTimer

func new_preview()->void:
	var v := glyph_preview_data
	for ch in find_children("", "Line2D", true, false):
		ch.queue_free()
	if v and v.data:
		var glyph_preview := Glyph.newPreviewFromGlyph(
				v.data.glyph,
				false,
				Color(Glyph.DEFAULT_LINE_COLOR,v.alpha),
				Glyph.DEFAULT_LINE_WIDTH * v.weight
				)
		#glyph_preview.data = v
		#v.changed.connect(glyph_preview.load_preview_data.bind(v))
		glyph_preview.load_preview_data(v)
		add_child(glyph_preview)
		#glyph_line.owner = get_tree().edited_scene_root


func _ready() -> void:
	#if Engine.is_editor_hint():
	size = DEFAULT_SIZE
	if glyph_preview_data:
		glyph_preview_data.changed.connect(new_preview)
	if not Engine.is_editor_hint():
		gui_input.connect(i_in)
		mouse_exited.connect(m_exit)
	new_preview()

func i_in(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"select"):
		glyph_fatigue.stop()
	if glyph_fatigue.is_stopped() and not is_instance_valid(active_glyph):
		active_glyph = Glyph.new()
		active_glyph.complete.connect(glyph_made.emit)
		add_sibling(active_glyph)


func m_exit() -> void:
	if glyph_fatigue:
		glyph_fatigue.start(0.2)
	if active_glyph:
		active_glyph.finalize()
