extends Sprite2D

@export var target_right:bool

var spawn_sequence
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_instance_valid(spawn_sequence):
		do_spawn()

func do_spawn():
	spawn_sequence = Node.new()
	get_tree().create_timer(randfn(12.0, 2.0)).timeout.connect(func():spawn_sequence=null)
	var m:= Monster2D.newGremlin(name)
	m.t_dir = Vector2.RIGHT if target_right else Vector2.LEFT
	add_child(m)
	
