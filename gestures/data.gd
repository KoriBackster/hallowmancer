class_name GestureData extends Resource

@export var gesture:Curve2D

var resample:Array[Vector2]:
	get:return Gesture.newResample(gesture)
		#return resample

func _init(_gesture:Curve2D= Curve2D.new()) -> void:
	gesture = _gesture
