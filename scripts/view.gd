extends Node3D

@export_group("Properties")
@export var target: Node3D

func _ready() -> void:
	add_to_group("view")

func set_target(new_target : Node3D):
	target = new_target

func _physics_process(delta):
	if not target:
		return
	self.position = self.position.lerp(target.global_position, delta * 4)
