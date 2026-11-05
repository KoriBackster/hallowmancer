class_name GlyphPreview extends Line2D


# Behaviors of the preview line
enum Style {
	# Solid Color
	STATIC, 
	# Travels the point data -> shows direction of drawing
	TRAVEL, 
	# Flashes glyph -> shows glyphs total state
	PULSE
	}
var preview_mode:bool = false

var data:GlyphPreviewData
var org_point_list:PackedVector2Array
var anim_style:Style

var anim_tw:Tween
	
func _ready() -> void:
	if Engine.is_editor_hint() or not preview_mode:
		return
	match anim_style:
		Style.STATIC, Style.PULSE:
			points = org_point_list
	#org_point_list = points
	#anim_tw = create_tween().set_trans(Tween.TRANS_SINE)

func update_data()->void:
	if not data.data:
		return
	org_point_list = data.data.gesture.get_baked_points()
	default_color.a = data.alpha
	anim_style = data.style
	position = data.offset
	scale = data.scale
	width = Gesture.DEFAULT_LINE_WIDTH * data.weight
	
func travel_point_list(weight:float):
	var new_arr:= org_point_list.duplicate()
	new_arr.resize(int(org_point_list.size() * weight))
	#print(new_arr.size())
	points = new_arr
func reverse_travel_point_list(weight:float):
	var new_arr:= org_point_list.duplicate()
	new_arr.reverse()
	new_arr.resize(int(org_point_list.size() * weight))
	#new_arr.reverse()
	points = new_arr

func _process(delta: float) -> void:
	if Engine.is_editor_hint() or not preview_mode:
		return
	#print(anim_style)
	match anim_style:
		Style.STATIC:
			points = org_point_list
			if is_instance_valid(anim_tw) and anim_tw.is_valid():
				anim_tw.kill()
			return
		Style.TRAVEL:
			if is_instance_valid(anim_tw) and anim_tw.is_valid() and anim_tw.is_running():
				return
			else:
				anim_tw = create_tween().set_trans(Tween.TRANS_EXPO)
				anim_tw.tween_method(travel_point_list, 0.0, 1.0, 2.0)
				anim_tw.tween_method(reverse_travel_point_list, 1.0, 0.0, 2.0)
				#anim_tw.tween_callback(clear_points)
				anim_tw.tween_interval(1.5)
				#anim_tw.tween_method(set_point_list, PackedVector2Array([]), org_point_list, 2.0)
				#anim_tw = create_tween()
		Style.PULSE:
			points = org_point_list
			if is_instance_valid(anim_tw) and anim_tw.is_valid() and anim_tw.is_running():
				return
			else:
				anim_tw = create_tween()
				anim_tw.tween_property(self, ^"modulate:a", 0, 1.2)
				anim_tw.tween_property(self, ^"modulate:a", 1.0, 1.2)
