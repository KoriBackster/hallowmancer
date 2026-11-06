class_name Glyph extends Node


signal complete(glyph:Curve2D)

var persistant:bool = false
var glyph:Curve2D
var line:GlyphPreview

func _input(event:InputEvent)->void:

	if event is InputEventMouseMotion and Input.is_action_pressed(&"select") and (glyph.get_baked_points().is_empty() or not glyph.get_baked_points()[-1] == (event.position)):
		glyph.add_point(event.position)
		line.points = glyph.get_baked_points()

	if Input.is_action_just_released(&"select"):
		line.points = PackedVector2Array(newResample(glyph))
		
		if persistant:
			line.reparent(get_parent())
		finalize(glyph)
	if Input.is_action_just_released(&"right click"):
		finalize()


func finalize(_output:Curve2D= null):
	complete.emit(_output)
	var validity:= is_instance_valid(self)
	if (validity and is_queued_for_deletion()) or not validity:
		return
	
	queue_free()

func _init(persistant_line:bool = false, color:Color=DEFAULT_LINE_COLOR) -> void:
	glyph = Curve2D.new()
	line = newLine(color)
	persistant = persistant_line
	add_child(line)

const SAVED_GLYPHS:StringName = &"/saved"

static var GLYPH_DIR:StringName = &"res://glyphs"
static var RESAMPLE_TARGET:int = 24
static var DEFAULT_LINE_COLOR:Color = Color.RED
static var DEFAULT_LINE_WIDTH:float = 5.0
static var GLYPH_ACCURACY_THRESHOLD:float = 0.5
static var GLYPH_COMPARISON_THRESHOLD:float = 0.2

static func _static_init() -> void:
	#var config_file :GameConfig = Config
	GLYPH_DIR = Config.GLYPH_DIR
	RESAMPLE_TARGET = Config.GLYPH_RESAMPLE
	DEFAULT_LINE_COLOR = Config.GLYPH_COLOR
	DEFAULT_LINE_WIDTH = Config.GLYPH_WEIGHT
	GLYPH_ACCURACY_THRESHOLD = Config.GLYPH_ACCURACY
	GLYPH_COMPARISON_THRESHOLD = Config.GLYPH_COMPARISON

static func newLine(color:Color = DEFAULT_LINE_COLOR, width:float = DEFAULT_LINE_WIDTH)->GlyphPreview:
	#var _line:= Line2D.new()
	var _line := GlyphPreview.new()
	_line.preview_mode = false
	_line.default_color = color
	_line.width = width
	_line.begin_cap_mode = Line2D.LINE_CAP_BOX
	_line.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	return _line

static func newLineFromGlyph(_glyph:Curve2D, resampled:bool = true, color:Color = DEFAULT_LINE_COLOR, width:float = DEFAULT_LINE_WIDTH)->GlyphPreview:
	var _line  := newLine(color, width)
	var point_list := PackedVector2Array(newResample(_glyph)) if resampled else _glyph.get_baked_points()
	_line.org_point_list = point_list
	_line.preview_mode = true
	return _line

static func newResample(_glyph:Curve2D)->PackedVector2Array:
	var resampled_points_array:PackedVector2Array = []

	if _glyph.get_baked_length() > 0:
		var distance_between_points:float = _glyph.get_baked_length() / (RESAMPLE_TARGET - 1) # d = l/(n-1)
		for point in range(RESAMPLE_TARGET):
			var distance_offset:float = distance_between_points * point
			resampled_points_array.append(_glyph.sample_baked(distance_offset))

	return resampled_points_array

static func getKnown()->Dictionary[StringName,GlyphData]:
	var known_glyphs:Dictionary[StringName, GlyphData] = {}
	var dir := DirAccess.open(GLYPH_DIR + SAVED_GLYPHS)
	for file in dir.get_files():
		if not file.ends_with(".tres"):
			continue
		known_glyphs[file.get_slice(".",0)] = (load(dir.get_current_dir().path_join(file)) as GlyphData)
	#print(known_glyphs)
	return known_glyphs

static func Save(title:StringName, _glyph:Curve2D):
	var new_glyph := GlyphData.new(_glyph)
	new_glyph.resource_name = title
	ResourceSaver.save(new_glyph, GLYPH_DIR + SAVED_GLYPHS.path_join("%s.tres" %title))

static func newDirectionalVector(_glyph:Curve2D)->Array[Vector2]:
	var vector_array:Array[Vector2] = []
	var resampled_glyph:= newResample(_glyph)
	for point in resampled_glyph.size():
		if point != 0:
			var direction_to_previous: Vector2 = resampled_glyph[point].direction_to(resampled_glyph[point-1])
			vector_array.append(direction_to_previous.snappedf(0.01))
	return vector_array

static func Verify(_glyph:Curve2D)->StringName:
	var identified:StringName = &""
	if not _glyph or not _glyph.get_baked_length() > 0:
		print("Invalid Glyph")
		return identified
	
	var incoming_directional:Array[Vector2] = newDirectionalVector(_glyph)

	var matches :int

	var similar_glyphs_dict:Dictionary

	var knownGlyphs:= getKnown()
	for known_tag in knownGlyphs.keys():
		#var resamp:= Resample()
		var compare_directional:= newDirectionalVector(knownGlyphs[known_tag].glyph)
		if compare_directional.is_empty():
			continue

		var viable_matches:int = 0
		#print(compare_directional)
		for index:int in range(RESAMPLE_TARGET-1):
			var incoming_vect := incoming_directional[index]
			var resamp_vect := compare_directional[index]

			if abs(resamp_vect.x - incoming_vect.x) <= GLYPH_COMPARISON_THRESHOLD and abs(resamp_vect.y - incoming_vect.y) <= GLYPH_COMPARISON_THRESHOLD:
				viable_matches += 1
		matches = viable_matches

		#var resampled_size:int = directional_vector_array.size()

		var compare_accuracy:float = snappedf((float(matches)/ float(RESAMPLE_TARGET)), 0.01)
		#var accuracy_threshold:float = .5
		if compare_accuracy >= GLYPH_ACCURACY_THRESHOLD:
			similar_glyphs_dict[known_tag] = compare_accuracy

	var max_similarity:float = -1.0
	for title in similar_glyphs_dict.keys():
		if similar_glyphs_dict[title] > max_similarity:
			identified = title

	if identified.is_empty():
		print("No Glyph Identified")
		
	return identified
