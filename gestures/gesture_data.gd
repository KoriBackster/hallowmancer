class_name GestureData extends Resource

@export var origin_gesture:Curve2D
@export var resample:Array[Vector2]:
	get:
		if resample.is_empty():
			resample = Gesture.Resample(origin_gesture)
		return resample

func _init(gesture:Curve2D= Curve2D.new()) -> void:
	origin_gesture = gesture
