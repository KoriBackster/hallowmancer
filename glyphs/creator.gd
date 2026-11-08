@tool
extends Control

@onready var start_test: Button = $TestDraw
@onready var create_new: Button = $CreateNew
@onready var glyph_name_insert:LineEdit = $NewName
@onready var preview_options:OptionButton = $OptionButton
@onready var delete_button:Button = $Delete
#@export var glyph_name:StringName
@export var preview_glyph:Variant:
	set(v):
		if v is GlyphData:
			_preview_glyph = v
			return
		elif v is StringName:
			var known_glyphs:= Glyph.getKnown()
			for title in known_glyphs.keys():
				if title == v:
					_preview_glyph = known_glyphs[title]
					return
		elif v == null:
			_preview_glyph = v
	get():
		#var title:StringName = _preview_glyph.resource_name
		return _preview_glyph.resource_name as StringName if _preview_glyph else &""

var active_glyph:Glyph
var _preview_glyph:GlyphData:
	set(v):
		for ch in find_children("", "Line2D", true, false):
			ch.queue_free()
		if v:
			add_child(Glyph.newPreviewFromGlyph(v.glyph, false,Color(Glyph.DEFAULT_LINE_COLOR, 0.2),Glyph.DEFAULT_LINE_WIDTH * 0.4))

func _ready() -> void:
	if Engine.is_editor_hint():return
	glyph_name_insert.text_submitted.connect(create_new.pressed.emit.unbind(1))
	create_new.pressed.connect(
		func():
			if glyph_name_insert.text.is_empty():
				print("invalid name")
				return
			elif Glyph.getKnown().keys().has(glyph_name_insert.text):
				print("Overriding existing resource")
			create_new.disabled = true
			start_test.disabled = true

			var glyph:=Glyph.new()
			active_glyph = glyph
			glyph.complete.connect(func(v):
				if v:
					Glyph.Save(glyph_name_insert.text, v)
					print(v, glyph_name_insert.text)
				active_glyph = null
				create_new.disabled = false
				start_test.disabled = false
				glyph_name_insert.edit()
				)
			add_sibling(glyph)
	)
	start_test.pressed.connect(func():
		create_new.disabled = start_test.button_pressed
		glyph_name_insert.editable = not start_test.button_pressed
		if not start_test.button_pressed:
			active_glyph.finalize()
			active_glyph = null
			for ch in get_tree().root.find_children("", "Line2D", true, false):
				ch.queue_free()
			)
	preview_options.pressed.connect(func():
		
		#var selected:= preview_options.get_selectable_item()
		preview_options.clear()
		
		
		var known_glyphs:= Glyph.getKnown()
		for glyph_ind in range(known_glyphs.keys().size()):
			preview_options.add_item(known_glyphs.keys()[glyph_ind])
		
		preview_options.select(-1)
		_preview_glyph = null
		)
	preview_options.item_selected.connect(func(v:int):
		#var curr := preview_options.get_item_text(preview_options.get_selectable_item())
		var selected:= preview_options.get_item_text(v)
		#if selected == curr:
			#_preview_glyph = null
			#preview_options.select(-1)
			#return
		print(selected)
		_preview_glyph = Glyph.getKnown()[selected]
		delete_button.visible = v != -1
		)
	delete_button.pressed.connect(func():
		var selected:=preview_options.get_selectable_item()
		var deletion_target :StringName = &"" if selected == -1 else preview_options.get_item_text(selected)
		if deletion_target.is_empty():
			print("Deletion of target node failed.")
			return
		var dir := DirAccess.open(Config.SAVED_GLYPH_DIR)
		for file in dir.get_files():
			if not file.begins_with(deletion_target):
				continue
			dir.remove(file)
		)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():return
	var free_draw_mode :bool = start_test.button_pressed
	if free_draw_mode and not is_instance_valid(active_glyph):
		var glyph := Glyph.new()
		glyph.complete.connect(func(v):
			print(Glyph.Verify(v)))
		add_sibling(glyph)
		active_glyph = glyph
