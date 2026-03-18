extends MultiplayerSynchronizer
class_name PlayerVehicleInput

@onready var vehicle : Vehicle = self.get_parent()

@export var authority_id : int = 1:
	set(id):
		authority_id = id
		set_multiplayer_authority(id)

func _ready() -> void:
	if authority_id == multiplayer.get_unique_id():
		get_tree().call_group("view", "set_target", get_parent())

func _process(delta: float) -> void:
	if not is_multiplayer_authority():
		return;
	vehicle.input.x = Input.get_axis("left", "right")
	vehicle.input.z = Input.get_axis("back", "forward")
