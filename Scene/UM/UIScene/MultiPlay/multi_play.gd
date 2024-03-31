extends Control


@onready var max_client:SpinBox = %MaxClient
@onready var open_port:SpinBox = %OpenPort
@onready var ip:LineEdit = %IP
@onready var connect_port:SpinBox = %ConnectPort


## 创建游戏
func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(round(open_port.value), round(max_client.value))
	if error:
		return
	multiplayer.multiplayer_peer = peer
	print("<多人-创建游戏>")
	(get_tree().current_scene as GM).um.get_ui("SelectArchive")
	queue_free()


## 加入游戏
func _on_join_pressed():
	if ip.text.is_empty():
		(get_tree().current_scene as GM).rpc("send_message","IP不可为空")
		return
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip.text, round(connect_port.value))
	if error:
		return
	multiplayer.multiplayer_peer = peer
	print("<多人-加入游戏>")
	queue_free()


## 取消多人游戏
func _on_back_pressed():
	(get_tree().current_scene as GM).um.get_ui("TitleScreen")
	queue_free()
