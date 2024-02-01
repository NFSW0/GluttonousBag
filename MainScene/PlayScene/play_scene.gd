# 主要作用:承载多人游戏的全部内容
# 主要功能:生成同步实体
extends Node


# 不可preload以防止循环加载
var start_scene_path = "res://MainScene/StartScene/start_scene.tscn"


var tile_map = preload("res://OtherScene/TileMap/tile_map.tscn")# 初始地图
var player = preload("res://OtherScene/Player/player.tscn")# 初始玩家
var number = 0

# 生成实体(RPC:傀儡可用-自我生效-低频重要)
@rpc("any_peer","call_local","reliable")
func generate_entity(file_path:String):
	if multiplayer.is_server():
		var unique_name = str(file_path.hash())+str(number)
		number = number +1
		var ins = (load(file_path)as PackedScene).instantiate()
		ins.name = unique_name
		add_child(ins)


func _ready():
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_peer_connected)
		multiplayer.peer_disconnected.connect(_peer_disconnected)
		# 生成主机地图
		add_child(tile_map.instantiate())
		# 生成主机角色
		var _player = player.instantiate()
		_player.name = "1"
		add_child(_player)
	else:
		multiplayer.server_disconnected.connect(_server_disconnected)
	GameManager.play_scene_has_loaded()


## 服务端-同伴加入游戏
func _peer_connected(id):
	print(str(multiplayer.get_unique_id()),":",str(id),"-加入游戏")
	print(str(multiplayer.get_unique_id()),":生成玩家-",str(id))
	var _player = player.instantiate()
	_player.name = str(id)
	add_child(_player)


## 服务端-同伴退出游戏
func _peer_disconnected(id):
	print(str(multiplayer.get_unique_id()),":",str(id),"-离开游戏")
	print(str(multiplayer.get_unique_id()),":销毁玩家-",str(id))
	for child in get_children():
		if child.name == str(id):
			child.queue_free()


## 客户端-与服务器断开时
func _server_disconnected():
	get_tree().change_scene_to_file(start_scene_path)
