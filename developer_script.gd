@tool
extends EditorScript


# Called when the script is executed (using File -> Run in Script Editor).
func _run() -> void:
	#var known_glyphs:Dictionary[StringName, GlyphData] = {}
	var dir := DirAccess.open(Config.SAVED_GLYPH_DIR)
	for file in dir.get_files():
		if not file.ends_with(".tres"):
			continue
		var gld := load(dir.get_current_dir().path_join(file)) as GlyphData
		gld.glyph = Glyph.Normalize(gld.glyph)
		#known_glyphs[file.get_slice(".",0)] = (load(dir.get_current_dir().path_join(file)) as GlyphData)
