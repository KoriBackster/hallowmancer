extends AttackComponent
class_name MeleeComponent


@export var max_enemies_affected: int = 1 # INCREASE TO MAKE IT AOE

func attack() -> bool:
	if not super(): return false
	
	var enemies : Array[Monster2D] = range_component.return_enemies(monster.side)
	for i in max_enemies_affected:
		if not enemies.get(i): continue
		var enemy : Monster2D = enemies.get(i)
		if enemy.get_node("HealthComponent"):
			var hc : HealthComponent = enemy.get_node("HealthComponent")
			hc.current_health -= attack_damage
			#print("hit ", enemy)
	
	return true
