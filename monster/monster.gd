class_name Monster2D extends CharacterBody2D

signal merge(Tag:StringName) # self yourself for the "merge_handler" to access your active_data...
# ? How would the merge_handler determine which monster's have linked merge calls?
#-> perhaps with a unique tag youd send with the merge signal so the handler can catch all related emitters 
# in order for the handler to catch the signals, the handler must be listening for the signal... when the objects are created theyll automatically link their signals to the handler
# So then, when you call a signal on an entity, you'd need to call that signal within an environment that maintains that unique emit signal
# the handler is requested to create a call; for which, the request must contain a list of all relavent monsters.
# perhaps via selection-system into an event-machine. -> click and drag, a set of monsters are selected (partitionable by a set of factors\
# HIGH_LEVEL -> "Summoner"(enemy/ally/environmental/occasional), "Functionality"(flying/crawler/undead), "Formation Position"(leading, battling, transporting, traveling)
# LOW_LEVEL -> "Stats"(speed/damage/position)
signal death(Tag:StringName)
signal creation(Tag:StringName)

signal interaction(Tag:StringName)

@export var active_data:MonsterData
var t_dir:Vector2

func _physics_process(_delta: float) -> void:
	velocity = t_dir * active_data.speed
	move_and_slide()
func spawn()->void:
	pass

func die()->void:
	death.emit()

func take_step(_over:int,_fps:int)->void:
	pass

func deal_damage()->void:
	pass

# This would be used for keeping track of "sides"...an enemy just check whether the object is on thier side, if not, is hostile.
# Additionally, this allows for non-territory oriented entities (Neutral monster's or event-related competitions)
var summoner:StringName
@export_enum("ATTACKING", "DEFENDING") var side : String = "ATTACKING"

@export_storage var environment_responses:Array[monster_response]

func _set_config_by_tag(tag:StringName):
	#var monster_data:MonsterData
	var dir = DirAccess.open(MONSTER_DIR)

	if not dir.dir_exists(tag):
		active_data = null
		environment_responses.clear()
		_update()
		#%Skin.texture = null
		return

	var monster_data :MonsterData = ResourceLoader.load(MONSTER_DIR.path_join(tag) + DATA_FILE, "MonsterData")
	#print(MONSTER_DIR.path_join(tag) + DATA_FILE)
	active_data = monster_data
	environment_responses.assign(collectResponses(tag))
	for key in active_data.component_keys:
		dir = DirAccess.open(COMPONENT_DIR)
		var jordan_key:String = key.to_pascal_case()

		if dir.dir_exists(jordan_key):
			dir.change_dir(jordan_key)
			for file in dir.get_files():
				if file.ends_with(".uid") or file.ends_with(".gd"):
					continue
				elif file.ends_with(".tscn"):
					var target_comp:PackedScene= load(dir.get_current_dir().path_join(file))
					var inst_comp := target_comp.instantiate()
					add_child(inst_comp)
	
	name = active_data.tag.to_pascal_case()
	_update()
	#%Skin.texture = active_data.texture

func _update():
	pass

func _enter_tree() -> void:
	all.append(self)

func _exit_tree() -> void:
	all.erase(self)

#region Class Functions
static var MONSTER_DIR: StringName = Config.MONSTER_DIR
static var COMPONENT_DIR: StringName = Config.MONSTER_COMPONENT_DIR
static var BASE_SCENE: StringName = Config.MONSTER_BASE_FILE
static var ENVIRONMENT_RESPONSE_DIR: StringName = Config.MONSTER_RESPONSE_DIR
static var DATA_FILE: StringName = Config.MONSTER_DATA_FILE

static var all:Array[Monster2D] = []

static var filterDB:Dictionary[StringName,Callable] = {
	"zombie": func(_e:Monster2D)->bool: return _e.active_data.tag == "zombie",
	"gremlin": func(_e:Monster2D)->bool:return _e.active_data.tag == "gremlin",
	
}

static func _static_init() -> void:
	MONSTER_DIR = Config.MONSTER_DIR
	BASE_SCENE = Config.MONSTER_BASE_FILE
	ENVIRONMENT_RESPONSE_DIR = Config.MONSTER_RESPONSE_DIR
	DATA_FILE = Config.MONSTER_DATA_FILE
	
	COMPONENT_DIR = Config.MONSTER_COMPONENT_DIR

# Returns a list of monsters that fit ALL filters
static func find_exclusive(filter_tag_list:Array[StringName] = [], custom_filter_list:Array[Callable]=[])->Array[Monster2D]:
	#return all.filter(filterDB.get(filter_tag), func(_e)->bool:return false)
	var ret :Array[Monster2D]= all.duplicate()
	var filter_used:bool = false
	
	for tag in filter_tag_list:
		if ret.is_empty():
			break
		if tag.is_empty():
			continue
		filter_used = true
		ret = ret.filter(filterDB.get(tag, func(_e)->bool:return false))
	for filter in custom_filter_list:
		if ret.is_empty():
			break
		if filter.is_valid():
			filter_used = true
			ret = ret.filter(filter)
	return ret if filter_used else []

# Returns a list of monsters that fit ANY filter
static func find_inclusive(filter_tag_list:Array[StringName]=[], custom_filter_list:Array[Callable]=[])->Array[Monster2D]:
	var ret :Array[Monster2D]= []
	
	var is_needed_filter:Callable = func(monst:Monster2D, second_filter:Callable)->bool: return (not monst in ret) and second_filter.call(monst)
	for tag in filter_tag_list:
		#var new_m:Array[Monster2D] = []
		if tag.is_empty() or not filterDB.has(tag):
			continue
		ret.append_array(all.filter(is_needed_filter.bind(filterDB.get(tag, func(_e)->bool:return false))))
		#ret.append_array(all.filter(filterDB.get([tag], func(_e)->bool:return false)))
	for filter in custom_filter_list:
		#var new_m:Array[Monster2D] = []
		if filter.is_valid():
			ret.append_array(all.filter(is_needed_filter.bind(filter)))
	
	return ret

static func newZombie(_summoner:StringName = &"") -> Monster2D:
	#const tag:StringName = "zombie"
	var new_monster:Monster2D = load(BASE_SCENE).instantiate()
	new_monster._set_config_by_tag(&"zombie")
	new_monster.summoner = _summoner
	return new_monster

static func newGremlin(_summoner:StringName = &"")->Monster2D:
	#const tag:StringName = "gremlin"
	var new_m:Monster2D = load(BASE_SCENE).instantiate()
	new_m._set_config_by_tag(&"gremlin")
	new_m.summoner = _summoner
	return new_m

static func getMonsterList()->PackedStringArray:
	#var monster_list:Array[StringName] = []
	var dir_acc := DirAccess.open(MONSTER_DIR)
	return dir_acc.get_directories()


static func collectResponses(tag:StringName)->Array[monster_response]:
	var responses :Array[monster_response] = []
	#var dir_path :StringName = ENVIRONMENT_RESPONSES_DIR + tag
	var dir_acc := DirAccess.open(MONSTER_DIR)
	if dir_acc.dir_exists(tag) and dir_acc.dir_exists(tag+ENVIRONMENT_RESPONSE_DIR):
		dir_acc.change_dir(tag + ENVIRONMENT_RESPONSE_DIR)
	elif dir_acc.dir_exists(tag):
		dir_acc.make_dir(tag + ENVIRONMENT_RESPONSE_DIR)
		return []
	else:
		printerr("'%s' does not have a dedicated directory" %tag)
		return []
	for file_name in dir_acc.get_files():
		if file_name.ends_with(".uid"):
			#print(tag)
			continue

		var resp_script_path := dir_acc.get_current_dir().path_join(file_name)
		var script_as_resource := load(resp_script_path)
		var script_instance :monster_response= script_as_resource.new()
		responses.append(script_instance)
	return responses
#endregion
