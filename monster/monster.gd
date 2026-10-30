class_name Monster2D extends CharacterBody2D

const MONSTER_ROOT_DIR :StringName = &"res://monster"
const MONSTER_BASE_SCENE := preload(MONSTER_ROOT_DIR + "/monster_base.tscn")
const ENVIRONMENT_RESPONSES_DIR :StringName = &"/environment_responses"
const DATA_FILE:StringName = &"/data.tres"

#const DEFAULT_UNIT_TAG:StringName = &"gremlin"

signal interaction(body:CharacterBody2D)

@export var active_data:MonsterData
@export_enum("ATTACKING", "DEFENDING") var side : String = "ATTACKING"

@export_storage var environment_responses:Array[monster_response]

func _set_config_by_tag(tag:StringName):
	var monster_data:MonsterData
	var dir = DirAccess.open(MONSTER_ROOT_DIR)

	if dir.dir_exists(tag):
		monster_data = load(MONSTER_ROOT_DIR.path_join(tag) + DATA_FILE)
	else:
		active_data = null
		environment_responses.clear()
		%Skin.texture = null
		return

	active_data = monster_data
	environment_responses.assign(CollectResponses(tag))

	%Skin.texture = active_data.texture
	# this is the current name of the node responsible for showing the texture, this will change when we add animations and need to replace the basic sprite2D node.


func _ready() -> void:
	#for resp in environment_responses:
		#resp.legend()
	pass

func _physics_process(delta: float) -> void:
	pass


static func newZombie() -> Monster2D:
	#const tag:StringName = "zombie"
	var new_monster:Monster2D = MONSTER_BASE_SCENE.instantiate()
	new_monster._set_config_by_tag("zombie")

	return new_monster

static func newGremlin()->Monster2D:
	#const tag:StringName = "gremlin"
	var new_m:Monster2D = MONSTER_BASE_SCENE.instantiate()
	new_m._set_config_by_tag("gremlin")

	return new_m

static func CollectResponses(tag:StringName)->Array[monster_response]:
	var responses :Array[monster_response] = []
	#var dir_path :StringName = ENVIRONMENT_RESPONSES_DIR + tag
	var dir_acc := DirAccess.open(MONSTER_ROOT_DIR)
	if dir_acc.dir_exists(tag):
		dir_acc.change_dir(tag + ENVIRONMENT_RESPONSES_DIR)
	else:
		printerr("'%s' does not have a dedicated directory" %tag)
	for file_name in dir_acc.get_files():
		if file_name.ends_with("uid"):
			#print(tag)
			continue
		
		var resp_script_path := dir_acc.get_current_dir().path_join(file_name)
		var script_as_resource := load(resp_script_path)
		var script_instance :monster_response= script_as_resource.new()
		responses.append(script_instance)
	return responses
