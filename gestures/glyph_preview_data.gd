class_name GlyphPreviewData extends Resource

@export var style:GlyphPreview.Style=GlyphPreview.Style.STATIC:
	set(v):
		style = v
		emit_changed()

@export var data:GestureData:
	set(v):
		data = v
		emit_changed()

@export_custom(PROPERTY_HINT_LINK, "suffix:px") var scale:Vector2 = Vector2.ONE:
	set(v):
		scale = v
		emit_changed()

@export var offset:Vector2:
	set(v):
		offset = v
		emit_changed()

@export var weight:float = 0.4:
	set(v):
		weight = v
		emit_changed()

@export var alpha:float = 0.2:
	set(v):
		alpha = v
		emit_changed()
