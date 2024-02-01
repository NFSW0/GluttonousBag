extends Node

var server = null
var client = null

var same_computer = true
var ip_address = ""

func _ready():
	match OS.get_name():
		"Window":
			ip_address = IP.get_local_addresses()[3]
		"Android":
			ip_address = IP.get_local_addresses()[0]
		_:
			ip_address = IP.get_local_addresses()[3]
	
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") and not ip.ends_with(".1"):
			ip_address = ip
	
	if same_computer:
		ip_address = "127.0.0.1"
	
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.server_disconnected.connect(_server_disconnected)


func creat_server(prot:int,max_clients:int):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(prot, max_clients)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

func join_server(address:String,port:int):
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

func _connected_to_server():
	print(str(multiplayer.get_unique_id()),":连接到服务器")

func _server_disconnected():
	print(str(multiplayer.get_unique_id()),":关闭服务器")
