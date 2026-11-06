extends Node

#region Scenes

const GAME_SCENE:= &"res://Scenes/game_ui.tscn"
const MENU_SCENE:= "res://Scenes/MainMenu/main_menu.tscn"

#endregion

#region Glyphs

const GLYPH_DIR:StringName = &"res://glyphs"
const SAVED_GLYPH_DIR:StringName = GLYPH_DIR + &"/saved"

const GLYPH_RESAMPLE:int = 12
const GLYPH_COLOR:Color = Color.RED
const GLYPH_WEIGHT:float = 5.0
const GLYPH_ACCURACY:float = 0.5
const GLYPH_COMPARISON:float = 0.2

#endregion

#region Monsters

const MONSTER_DIR := &"res://monster"
const MONSTER_BASE_FILE := MONSTER_DIR + &"/base.tscn"

const MONSTER_RESPONSE_DIR:= &"/environment_responses"
const MONSTER_DATA_FILE:= &"/data.tres"

#endregion

#region Components

const COMPONENT_DIR:= &"res://Components"

#endregion
