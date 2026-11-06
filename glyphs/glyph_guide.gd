@tool
class_name GlyphGuide extends TextureRect

signal glyph_made(glyph:Curve2D)

#enum PreviewStyle { BASIC, PULSE, TRAVEL}
var active_glyph:Glyph

#@export_storage var previewed_glyph:GlyphPreview

@export var glyph_preview_data:GlyphPreviewData

func new_preview(v:GlyphPreviewData)->void:
	for ch in find_children("", "Line2D", true, false):
		ch.queue_free()
	if v and v.data:
		var glyph_line := Glyph.newLineFromGlyph(v.data.glyph, false,Color(Glyph.DEFAULT_LINE_COLOR, v.alpha),Glyph.DEFAULT_LINE_WIDTH * v.weight)
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
	if not is_instance_valid(active_glyph):
		active_glyph = Glyph.new()
		active_glyph.complete.connect(glyph_made.emit)
		add_sibling(active_glyph)

func m_exit() -> void:
	if active_glyph:
		active_glyph.finalize()
