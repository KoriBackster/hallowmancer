class_name Gesture extends Node


signal complete(gesture:Curve2D)

var gesture:Curve2D
var line:Line2D

func _input(event:InputEvent)->void:

	if event is InputEventMouseMotion and Input.is_action_pressed(&"select") and not gesture.get_baked_points().has(event.position):
		gesture.add_point(event.position)
		line.points = gesture.get_baked_points()

	if Input.is_action_just_released(&"select"):
		line.points = PackedVector2Array(newResample(gesture))
		line.reparent(get_parent())
		finalize(gesture)
	if Input.is_action_just_released(&"right click"):
		finalize()


func finalize(_output:Curve2D= null):
	complete.emit(_output)
	queue_free()

func _init(color:Color=DEFAULT_LINE_COLOR) -> void:
	gesture = Curve2D.new()
	line = newLine(color)
	add_child(line)

const GESTURE_DIR:StringName = &"res://gestures"
const SAVED_GESTURES:StringName = &"/saved"
const RESAMPLE_TARGET:int = 24
const DEFAULT_LINE_COLOR:Color = Color.RED
const DEFAULT_LINE_WIDTH:float = 5.0
const GESTURE_ACCURACY_THRESHOLD:float = 0.5
const GESTURE_COMPARISON_THRESHOLD:float = 0.2

static func newLine(color:Color = DEFAULT_LINE_COLOR, width:float = DEFAULT_LINE_WIDTH)->Line2D:
	var _line:= Line2D.new()
	_line.default_color = color
	_line.width = width
	return _line

static func newLineFromGesture(_gesture:Curve2D, resampled:bool = true, color:Color = DEFAULT_LINE_COLOR, width:float = DEFAULT_LINE_WIDTH)->Line2D:
	var _line  := newLine(color, width)
	var point_list := PackedVector2Array(newResample(_gesture)) if resampled else _gesture.get_baked_points()
	_line.points = point_list
	return _line

static func newResample(_gesture:Curve2D)->Array[Vector2]:
	var resampled_points_array:Array[Vector2] = []

	if _gesture.get_baked_length() > 0:
		var distance_between_points:float = _gesture.get_baked_length() / (RESAMPLE_TARGET - 1) # d = l/(n-1)
		for point in range(RESAMPLE_TARGET):
			var distance_offset:float = distance_between_points * point
			resampled_points_array.append(_gesture.sample_baked(distance_offset))

	return resampled_points_array

static func getKnown()->Dictionary[StringName,GestureData]:
	var known_gestures:Dictionary[StringName, GestureData] = {}
	var dir := DirAccess.open(GESTURE_DIR + SAVED_GESTURES)
	for file in dir.get_files():
		if file.ends_with(".uid"):
			continue
		known_gestures[file.get_slice(".",0)] = (load(dir.get_current_dir().path_join(file)) as GestureData)
	return known_gestures

static func Save(title:StringName, _gesture:Curve2D):
	var new_gesture := GestureData.new(_gesture)
	new_gesture.resource_name = title
	ResourceSaver.save(new_gesture, GESTURE_DIR + SAVED_GESTURES.path_join("%s.tres" %title))

static func newDirectionalVector(_gesture:Curve2D)->Array[Vector2]:
	var vector_array:Array[Vector2] = []
	var resampled_gesture:= newResample(_gesture)
	for point in resampled_gesture.size():
		if point != 0:
			var direction_to_previous: Vector2 = resampled_gesture[point].direction_to(resampled_gesture[point-1])
			vector_array.append(direction_to_previous.snappedf(0.01))
	return vector_array

static func Verify(_gesture:Curve2D)->StringName:
	var incoming_directional:Array[Vector2] = newDirectionalVector(_gesture)

	var identified:StringName = &""
	var matches :int

	var similar_gestures_dict:Dictionary

	var knownGestures:= getKnown()
	for known_tag in knownGestures.keys():
		#var resamp:= Resample()
		var compare_directional:= newDirectionalVector(knownGestures[known_tag].origin_gesture)
		if compare_directional.is_empty():
			continue

		var viable_matches:int = 0
		#print(compare_directional)
		for index:int in range(RESAMPLE_TARGET-1):
			var incoming_vect := incoming_directional[index]
			var resamp_vect := compare_directional[index]

			if abs(resamp_vect.x - incoming_vect.x) <= GESTURE_COMPARISON_THRESHOLD and abs(resamp_vect.y - incoming_vect.y) <= GESTURE_COMPARISON_THRESHOLD:
				viable_matches += 1
		matches = viable_matches

		#var resampled_size:int = directional_vector_array.size()

		var compare_accuracy:float = snappedf((float(matches)/ float(RESAMPLE_TARGET)), 0.01)
		#var accuracy_threshold:float = .5
		if compare_accuracy >= GESTURE_ACCURACY_THRESHOLD:
			similar_gestures_dict[known_tag] = compare_accuracy

	var max_similarity:float = -1.0
	for title in similar_gestures_dict.keys():
		if similar_gestures_dict[title] > max_similarity:
			identified = title

	if identified.is_empty():
		print("No Gesture Identified")
		
	return identified
