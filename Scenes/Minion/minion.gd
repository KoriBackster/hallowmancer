extends CharacterBody2D
class_name Minion

@export var minion_resource : MinionResource

enum SIDES {
	ATTACKING,
	DEFENDING,
}


@export var what_side : SIDES = SIDES.ATTACKING

@onready var navigation_component: NavigationComponent = $NavigationComponent


func _ready () -> void:
	$Sprite2D.texture = minion_resource.texture
	$HealthComponent.max_health = minion_resource.max_health
	$MovementComponent.max_speed = minion_resource.max_speed
	$MovementComponent.acceleration = minion_resource.acceleration

func _process(_delta: float) -> void:
	pass
	#$NavigationComponent.target = get_global_mouse_position() # Debug, move constantly to mouse
