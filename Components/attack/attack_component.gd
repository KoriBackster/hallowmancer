@abstract class_name AttackComponent extends Node

@export var monster: Monster2D
@export var range_component: RangeComponent
@export var behavior_tree: BTPlayer
@export var attack_cd: float = 1.0
var attack_damage : float

@onready var cd_timer: Timer = $AttackCD

func _ready() -> void:
	cd_timer.wait_time = attack_cd
	monster = get_parent()
	range_component = monster.get_node("RangeComponent")
	behavior_tree = monster.get_node("BTPlayer")
	behavior_tree.blackboard.call_deferred("set_var", "AttackComponent", self)
	attack_damage = monster.active_data.damage

func attack() -> bool: # Always super() to check attacking state
	if not range_component or not monster or not behavior_tree:
		printerr("Confirm attack component variables", self)
		return false
		
	if not range_component.check_enemies(monster.side): 
		return false
		
	if not cd_timer.is_stopped(): return false
	cd_timer.start()
	return true
