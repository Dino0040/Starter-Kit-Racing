extends Node

@export var player_vehicle_scene : PackedScene
var spawn_id : int = 0

const PORT = 7040
const DEFAULT_SERVER_IP = "127.0.0.1"

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connection_failed.connect(remove_multiplayer_peer)
	multiplayer.server_disconnected.connect(remove_multiplayer_peer)
	_start.call_deferred()

func _start():
	var args = Array(OS.get_cmdline_args())
	if args.has("host"):
		DisplayServer.window_set_title("Host")
		create_game()
	if args.has("client"):
		DisplayServer.window_set_title("Client")
		join_game()

func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer


func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	spawn_player(1)

func _on_player_connected(id):
	if is_multiplayer_authority():
		spawn_player(id)

func spawn_player(id):
	var player : Node3D = player_vehicle_scene.instantiate()
	var input : PlayerVehicleInput = player.get_node_or_null("PlayerVehicleInput")
	input.authority_id = id
	var spawn = get_child(spawn_id)
	spawn_id = (spawn_id + 1) % get_child_count()
	player.position = spawn.global_position + Vector3.UP * randf() * 3
	get_parent().add_child(player, true)

func _on_player_disconnected(id):
	if not is_multiplayer_authority():
		return
	for player in get_tree().get_nodes_in_group("players"):
		var input : PlayerVehicleInput = player.get_node_or_null("PlayerVehicleInput")
		if input.authority_id == id:
			player.queue_free()

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
