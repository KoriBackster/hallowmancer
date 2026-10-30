class_name Monster2D extends CharacterBody2D

const MONSTER_BASE_SCENE := preload("res://monster/prefabs/monster_base.tscn")

const ENVIRONMENT_RESPONSES_DIR :StringName = &"res://monster/environment_responses/"
const TEXTURE_DIR:StringName = &"res://raw/textures/monsters/"
const TEXTURE_FILE_EXT :StringName = &".svg"
# .svg is for testing, for a proper file format it will likely be ".png" etc.

const DEFAULT_UNIT_TAG:StringName = &"gremlin"
const DEFAULT_UNIT_SPEED:float = 50.0
const DEFAULT_UNIT_RANGE:float = 40.0
const DEFAULT_UNIT_DAMAGE:float = 20.0

# placeholder signal to remind me to implement the functionality... intended to send the collided object with a ref to itself...
signal interaction(body:CharacterBody2D)

@export var nametag:StringName = "Base"
@export var speed:float = 300.0
@export var damage:float = 300.0
@export var attack_range:float = 40.0
@export var texture:Texture2D

@export_storage var environment_responses:Array[monster_response]

func _set_config(_tag:StringName, _speed:float, _damage:float, _range:float, _texture:Texture2D, _env_resp:Array[monster_response]):
	nametag = _tag
	speed = _speed
	damage = _damage
	attack_range = _range
	texture = _texture
	environment_responses.assign(_env_resp)

	find_child("Sprite2D").texture = texture
	# this is the current name of the node responsible for showing the texture, this will change when we add animations and need to replace the basic sprite2D node.


func _ready() -> void:
	#for resp in environment_responses:
		#resp.legend()
	pass

func _physics_process(delta: float) -> void:
	pass


static func newZombie() -> Monster2D:
	const _tag:StringName = "zombie"
	# tag is currently used for both the *(folder name) of response dir, and the *(name tag) that the monster is assigned when spawned in
	const _speed :float = 200.0
	const _damage :float = 600.0
	const _range :float = 20.0
	const _texture:Texture2D = preload(TEXTURE_DIR + _tag + TEXTURE_FILE_EXT)
	var _env_resp:Array[monster_response] = CollectResponses(_tag)

	var new_monster:Monster2D = MONSTER_BASE_SCENE.instantiate()
	new_monster._set_config(_tag, _speed, _damage, _range, _texture, _env_resp)

	return new_monster



# Monster2D.new() -> makes the base gremlin. for the lane spawning
func _init(_nametag:StringName = DEFAULT_UNIT_TAG, _speed:float = DEFAULT_UNIT_SPEED, _damage:float = DEFAULT_UNIT_DAMAGE, _attack_range:float = DEFAULT_UNIT_RANGE, _texture:Texture2D = preload(TEXTURE_DIR + DEFAULT_UNIT_TAG + TEXTURE_FILE_EXT), env_responses:Array[monster_response] = CollectResponses(DEFAULT_UNIT_TAG)) -> void:
	nametag = _nametag
	speed = _speed
	damage = _damage
	attack_range = _attack_range
	texture = _texture

	environment_responses.assign(env_responses)

static func CollectResponses(m_tag:StringName)->Array[monster_response]:
	var responses :Array[monster_response] = []
	var dir_path :StringName = ENVIRONMENT_RESPONSES_DIR + m_tag
	for file_name in DirAccess.get_files_at(dir_path):
		if file_name.ends_with("uid"):
			continue
		# "get_files_at" gets ALL files, there is an alternative function that theoretically would eliminate the need to filter out "uid" files, but this folder should only have scripts inside it, so the basic filter should be good enough
		var resp_script_path := dir_path.path_join(file_name)
		var script_as_resource := load(resp_script_path)
		var script_instance :monster_response= script_as_resource.new()
		responses.append(script_instance)
	return responses
