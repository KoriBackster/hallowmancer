extends AttackComponent
class_name MeleeComponent


@export var max_enemies_affected: int = 1 # INCREASE TO MAKE IT AOE
const DAMAGE_NUMBERS = preload("uid://ddh6uv87frcec")

func attack() -> bool:
	if not super(): return false
	
	var enemies : Array[Monster2D] = range_component.return_enemies(monster.side)
	for i in max_enemies_affected:
		if not enemies.get(i): continue
		var enemy : Monster2D = enemies.get(i)
		if enemy.get_node("HealthComponent"):
			var hc : HealthComponent = enemy.get_node("HealthComponent")
			hc.current_health -= attack_damage
			
			var numbers := DAMAGE_NUMBERS.instantiate()
			numbers.global_position = enemy.global_position
			numbers.get_node("Label").text = str(attack_damage)
			get_tree().current_scene.add_child(numbers)
	
	return true
