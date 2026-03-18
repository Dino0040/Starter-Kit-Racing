extends Node

var seconds : float = .001

func _ready() -> void:
	while true:
		await get_tree().create_timer(1.0).timeout
		if multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
			continue
		if multiplayer.is_server():
			continue
		ping.rpc_id(1, Time.get_ticks_usec())

@rpc("any_peer", "call_remote", "unreliable_ordered")
func ping(time_usec : int) -> void:
	pong.rpc_id(multiplayer.get_remote_sender_id(), time_usec)

@rpc("authority", "call_remote", "unreliable_ordered")
func pong(time_usec : int) -> void:
	var ping_pong_time_in_usec = Time.get_ticks_usec() - time_usec
	seconds = ping_pong_time_in_usec / 1000000.0
	print("%0.1f" % (seconds * 1000) + "ms")
