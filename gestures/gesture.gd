class_name Gesture extends Node

const GESTURE_DIR:StringName = &"res://gestures"
const SAVED_GESTURES:StringName = &"/saved"
const RESAMPLE_TARGET:int = 24

signal complete(gesture:Curve2D)

var gesture:Curve2D
var line:Line2D

func _init() -> void:
	gesture = Curve2D.new()
	line = createLine()
	add_child(line)

func _input(event:InputEvent)->void:

	if event is InputEventMouseMotion and Input.is_action_pressed(&"select") and not gesture.get_baked_points().has(event.position):
		gesture.add_point(event.position)
		line.points = gesture.get_baked_points()

	if Input.is_action_just_released(&"select"):
		line.points = PackedVector2Array(Resample(gesture))
		line.reparent(get_parent())
		finalize(gesture)
	if Input.is_action_just_released(&"right click"):
		finalize()


func finalize(_output:Curve2D= null):
	complete.emit(_output)
	queue_free()

static func createLine(color:Color = Color.RED, width:float = 5.0)->Line2D:
	var _line:= Line2D.new()
	_line.default_color = color
	_line.width = width
	return _line

static func createLineFromGesture(_gesture:Curve2D, line_color:Color = Color.RED, line_width:float = 5.0 )->Line2D:
	var shape_line:Line2D = Line2D.new()
	shape_line.default_color = line_color
	shape_line.width = line_width
	shape_line.points = PackedVector2Array(Resample(_gesture))
	return shape_line

static func Resample(_gesture:Curve2D)->Array[Vector2]:
	var resampled_points_array:Array[Vector2] = []

	if _gesture.get_baked_length() > 0:
		var distance_between_points:float = _gesture.get_baked_length() / (RESAMPLE_TARGET - 1) # d = l/(n-1)
		for point in range(RESAMPLE_TARGET):
			var distance_offset:float = distance_between_points * point
			resampled_points_array.append(_gesture.sample_baked(distance_offset))

	return resampled_points_array

#static func getVectorArrayFromGesture(_gesture:Curve2D)->Array[Vector2]:
	#var vector_array:Array[Vector2]= []
#
	#var resampled_points_array:Array[Vector2] = resampleGesture(_gesture)
#
	#for point in resampled_points_array.size():
		#if point > 0:
			#var direction_to_previous:Vector2 = resampled_points_array[point].direction_to(resampled_points_array[point - 1])
			#vector_array.append(direction_to_previous.snappedf(0.01))
	#return vector_array

#static func getAverageFromVectorArray(vector_array:Array[Vector2])->Array[Vector2]:
	#var average_vector_array:Array[Vector2]= []
	#var united_vector_array:Array[Vector2]= []
#
	#for array:Array in vector_array:

static func GetKnown()->Dictionary[StringName,GestureData]:
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
	#print(err)


	#print(prop)

static func GetDirectionalGestureVector(_gesture:Curve2D)->Array[Vector2]:
	var vector_array:Array[Vector2] = []
	var resampled_gesture:= Resample(_gesture)
	for point in resampled_gesture.size():
		if point != 0:
			var direction_to_previous: Vector2 = resampled_gesture[point].direction_to(resampled_gesture[point-1])
			vector_array.append(direction_to_previous.snappedf(0.01))
	return vector_array

static func Verify(_gesture:Curve2D)->StringName:
	var directional_vector_array:Array[Vector2] = GetDirectionalGestureVector(_gesture)
	var identified:StringName = &""
	var matches :int
	var compare_offset:float = 0.2

	var similar_gestures_dict:Dictionary

	var knownGestures:= GetKnown()
	for known in knownGestures:
		var csm:int = 0
		var resamp:= Gesture.Resample(knownGestures[known].origin_gesture)
		for index:int in resamp.size():
			var vect := resamp[index]
			if abs(vect.x - directional_vector_array[index].x) <= compare_offset and abs(vect.y - directional_vector_array[index].y) <= compare_offset:
				csm += 1
		matches = csm

		var resampled_size:int = directional_vector_array.size()
		var compare_accuracy:float = snappedf((float(matches)/ float(resampled_size)) * 100, 0.01)
		var accuracy_percent:float = 50
		if compare_accuracy >= accuracy_percent:
			similar_gestures_dict[known] = compare_accuracy

	var max_similarity:float = -1.0
	for title:StringName in similar_gestures_dict:
		if similar_gestures_dict[title] > max_similarity:
			max_similarity = similar_gestures_dict[title]
			identified = title

	return identified
