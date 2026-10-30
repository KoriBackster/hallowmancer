extends Node2D

const NAVIGATION_COMPONENT := preload("uid://cxk08qyvnfv6j")
const MOVEMENT_COMPONENT := preload("uid://yhmluvklodwb")


func _on_spawn_attack_pressed() -> void:
	var atk_monster := Monster2D.newGremlin()
	var new_mc : MovementComponent = MOVEMENT_COMPONENT.instantiate()
	var new_na : NavigationAgent2D = NavigationAgent2D.new()
	var new_nc : NavigationComponent = NAVIGATION_COMPONENT.instantiate()
	$PlayerSide.add_child(atk_monster)
	atk_monster.add_child(new_na)
	atk_monster.add_child(new_mc)
	new_mc.character = atk_monster
	new_mc.max_speed = atk_monster.active_data.speed
	atk_monster.add_child(new_nc)
	new_nc.movement_component = new_mc
	new_nc.navigation_agent = new_na
	


func _on_spawn_defending_pressed() -> void:
	var def_monster := Monster2D.newZombie()
	$EnemySide.add_child(def_monster)
