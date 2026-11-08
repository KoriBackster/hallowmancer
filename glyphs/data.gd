@tool
class_name GlyphData extends Resource

@export_custom(PROPERTY_HINT_LINK, "suffix:px") var offset:Vector2:
	set(v):
		offset = v
		emit_changed()

@export_custom(PROPERTY_HINT_LINK, "suffix:*") var scale:Vector2 = Vector2.ONE:
	set(v):
		scale = v
		emit_changed()

@export var glyph:Curve2D

var resample:PackedVector2Array:
	get:return Glyph.newResample(glyph)
		#return resample

func _init(_glyph:Curve2D= Curve2D.new()) -> void:
	glyph = _glyph
