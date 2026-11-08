@tool
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
@export var preview_mode:bool = false
@export var anim_style:Style
#var data:GlyphPreviewData
var org_point_list:PackedVector2Array

var anim_tw:Tween

func load_preview_data(data:GlyphPreviewData = null)->void:
	org_point_list.clear()
	if not data:
		points = org_point_list
		default_color = Color.TRANSPARENT
		anim_style = Style.STATIC
		position = Vector2.ZERO
		scale = Vector2.ONE
		width = 10.0
		return
	
	if data.data:
		var _org = data.data.glyph.get_baked_points()
		for p:Vector2 in _org:
			org_point_list.append(p*GlyphGuide.DEFAULT_SIZE * 0.9 * data.data.scale)
		scale = data.data.scale
		position = data.data.offset
	else:
		scale = Vector2.ONE
		position = Vector2.ZERO
	points = org_point_list
	default_color.a = data.alpha
	anim_style = data.style
	width = Glyph.DEFAULT_LINE_WIDTH * data.weight
	
func travel_point_list(weight:float, trail:float = 1.0):
	trail = maxf(trail, 0.05)
	var new_arr:= org_point_list.duplicate()
	new_arr.resize(int(org_point_list.size() * weight))
	#new_arr.reverse()
	#new_arr.resize(int(new_arr.size() * trail))
	#new_arr.reverse()
	#print(new_arr.size())
	points = new_arr

func reverse_travel_point_list(weight:float, trail:float = 1.0):
	trail = maxf(trail, 0.05)
	var new_arr:= org_point_list.duplicate()
	new_arr.reverse()
	new_arr.resize(int(org_point_list.size() * weight))
	new_arr.reverse()
	#new_arr.resize(int(new_arr.size() * trail))
	#new_arr.reverse()
	#new_arr.reverse()
	points = new_arr

func _process(delta: float) -> void:
	if not preview_mode:
		return
	#print(anim_style)
	match anim_style:
		Style.STATIC:
			#points = org_point_list
			if is_instance_valid(anim_tw) and anim_tw.is_valid():
				anim_tw.kill()
			return
		Style.TRAVEL:
			if is_instance_valid(anim_tw) and anim_tw.is_valid() and anim_tw.is_running():
				return
			else:
				anim_tw = create_tween().set_trans(Tween.TRANS_EXPO)
				anim_tw.tween_method(travel_point_list.bind(1.0), 0.0, 1.0, 2.0)
				anim_tw.tween_interval(1.5)
				anim_tw.tween_method(reverse_travel_point_list.bind(1.0), 1.0, 0.0, 2.0)
				#anim_tw.tween_callback(clear_points)
				#anim_tw.tween_method(set_point_list, PackedVector2Array([]), org_point_list, 2.0)
				#anim_tw = create_tween()
		Style.PULSE:
			#points = org_point_list
			if is_instance_valid(anim_tw) and anim_tw.is_valid() and anim_tw.is_running():
				return
			else:
				anim_tw = create_tween()
				anim_tw.tween_property(self, ^"modulate:a", 0, 1.2)
				anim_tw.tween_property(self, ^"modulate:a", 1.0, 1.2)
