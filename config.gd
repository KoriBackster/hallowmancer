extends Node

const GESTURE_DIR:StringName = &"res://gestures"
const GESTURE_RESAMPLE:int = 12
const GESTURE_COLOR:Color = Color.RED
const GESTURE_WEIGHT:float = 5.0
const GESTURE_ACCURACY:float = 0.5
const GESTURE_COMPARISON:float = 0.2

const MONSTER_DIR:StringName = &"res://monster"
const MONSTER_BASE_SCENE := preload(MONSTER_DIR + "/monster_base.tscn")
const ENVIRONMENT_RESPONSE_DIR :StringName = &"/environment_responses"
const DATA_FILE:StringName = &"/data.tres"

const COMPONENT_DIR:StringName = &"res://Components"

const GAME_SCENE:= "res://test_bin/game_ui.tscn"
const MENU_SCENE:= "res://Scenes/MainMenu/main_menu.tscn"
