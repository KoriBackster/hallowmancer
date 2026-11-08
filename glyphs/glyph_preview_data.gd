@tool
class_name GlyphPreviewData extends Resource


@export var data:GlyphData:
	set(v):
		data = v
		if data and not data.changed.is_connected(emit_changed):
			data.changed.connect(emit_changed)
		emit_changed()

@export var style:GlyphPreview.Style=GlyphPreview.Style.STATIC:
	set(v):
		style = v
		emit_changed()

@export var weight:float = 0.4:
	set(v):
		weight = v
		emit_changed()

@export var alpha:float = 0.2:
	set(v):
		alpha = v
		emit_changed()
