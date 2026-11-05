@tool
class_name GlyphGuide extends TextureRect

signal glyph_made(gesture:Curve2D)

#enum PreviewStyle { BASIC, PULSE, TRAVEL}
var active_gesture:Gesture

var previewed_glyph:Line2D
@export_group("Glyph Preview Settings", "glyph")

@export var glyph_preview_data:GestureData:
	set(v):
		glyph_preview_data = v
		apply_preview_gesture(glyph_preview_data, GlyphPreview.Style.STATIC)

@export_custom(PROPERTY_HINT_LINK, "suffix:px") var glyph_preview_scale:Vector2 = Vector2.ONE:
	set(v):
		glyph_preview_scale = v
		if is_instance_valid(previewed_glyph):
			previewed_glyph.scale = v

@export var glyph_preview_offset:Vector2:
	set(v):
		glyph_preview_offset = v
		if is_instance_valid(previewed_glyph):
			previewed_glyph.position = glyph_preview_offset

@export var glyph_preview_weight:float = 0.4:
	set(v):
		glyph_preview_weight = v
		if is_instance_valid(previewed_glyph):
			previewed_glyph.width = Gesture.DEFAULT_LINE_WIDTH * glyph_preview_weight

@export var glyph_preview_alpha:float = 0.2:
	set(v):
		glyph_preview_alpha = v
		if is_instance_valid(previewed_glyph):
			previewed_glyph.default_color.a = glyph_preview_alpha


func apply_preview_gesture(v:GestureData, preview_style:GlyphPreview.Style)->void:
	for ch in find_children("", "Line2D", true, false):
		ch.queue_free()
	if v:
		var glyph_line := Gesture.newLineFromGesture(v.gesture, false,Color(Gesture.DEFAULT_LINE_COLOR, glyph_preview_alpha),Gesture.DEFAULT_LINE_WIDTH * glyph_preview_weight)
		
		glyph_line.position = glyph_preview_offset
		glyph_line.scale = glyph_preview_scale
		glyph_line.tree_exiting.connect(func():previewed_glyph = null)
		glyph_line.anim_style = preview_style
		previewed_glyph = glyph_line
		
		#previewed_glyph.owner = get_tree().root
		add_child(glyph_line)

		
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	gui_input.connect(i_in)
	mouse_exited.connect(m_exit)
	apply_preview_gesture(glyph_preview_data, GlyphPreview.Style.TRAVEL)

func i_in(event: InputEvent) -> void:
	if not is_instance_valid(active_gesture):
		active_gesture = Gesture.new()
		active_gesture.complete.connect(glyph_made.emit)
		add_sibling(active_gesture)

func m_exit() -> void:
	if active_gesture:
		active_gesture.finalize()
