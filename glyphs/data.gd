class_name GlyphData extends Resource

@export var glyph:Curve2D
	
var resample:PackedVector2Array:
	get:return Glyph.newResample(glyph)
		#return resample

func _init(_glyph:Curve2D= Curve2D.new()) -> void:
	glyph = _glyph
