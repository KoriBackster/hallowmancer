@tool
class_name GlyphGuide extends TextureRect

signal glyph_made(gesture:Curve2D)

#enum PreviewStyle { BASIC, PULSE, TRAVEL}
var active_gesture:Gesture

#@export_storage var previewed_glyph:GlyphPreview

@export var glyph_preview_data:GlyphPreviewData

func new_preview(v:GlyphPreviewData)->void:
	for ch in find_children("", "Line2D", true, false):
		ch.queue_free()
	if v and v.data:
		var glyph_line := Gesture.newLineFromGesture(v.data.gesture, false,Color(Gesture.DEFAULT_LINE_COLOR, v.alpha),Gesture.DEFAULT_LINE_WIDTH * v.weight)
		glyph_line.data = v
		v.changed.connect(glyph_line.update_data)
		glyph_line.position = v.offset
		glyph_line.scale = v.scale
		glyph_line.anim_style = v.style
		add_child(glyph_line)

		
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	gui_input.connect(i_in)
	mouse_exited.connect(m_exit)
	new_preview(glyph_preview_data)

func i_in(event: InputEvent) -> void:
	if not is_instance_valid(active_gesture):
		active_gesture = Gesture.new()
		active_gesture.complete.connect(glyph_made.emit)
		add_sibling(active_gesture)

func m_exit() -> void:
	if active_gesture:
		active_gesture.finalize()
