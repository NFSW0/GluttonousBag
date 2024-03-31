# 功能2: 修改瓦片
# 功能1: 初始化瓦片
class_name World
extends TileMap


var world_data: Dictionary # 同步数据
var world_data_path: String # 数据存储路径


## 获取地图数据并初始化
func _ready() -> void:
	if multiplayer.is_server():
		world_data_path = (get_tree().current_scene as GM).archive_path + "world.json"
		if FileAccess.file_exists(world_data_path):
			world_data = JSON.parse_string(FileAccess.open(world_data_path, FileAccess.READ).get_as_text())
		initialize_map(world_data)
	else:
		rpc_id(1, "send_world_data")


## 服务端-发送地图数据
@rpc("any_peer", "reliable")
func send_world_data() -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	rpc_id(sender_id, "initialize_map", world_data)


## 根据数据初始化地图
@rpc("reliable")
func initialize_map(_world_data: Dictionary) -> void:
	clear()
	for section in _world_data:
		for key in _world_data[section]:
			var source_id = _world_data[section][key][0]
			var atlas_coords = _world_data[section][key][1]
			var alternative_tile = _world_data[section][key][2]
			set_cell(int(section), to_vector2i(key), source_id, to_vector2i(atlas_coords), alternative_tile)


## 放置瓦片("人偶可用","本地生效","低频重要")
@rpc("any_peer", "call_local", "reliable")
func set_tile(layer: int, coords: Vector2i, source_id: int, atlas_coords: Vector2i, alternative_tile: int = 0) -> void:
	set_cell(layer, coords, source_id, atlas_coords, alternative_tile)
	if world_data != null:
		if world_data.has(str(layer)):
			world_data[str(layer)][str(coords)] = [source_id, atlas_coords, alternative_tile]
		else:
			world_data[str(layer)] = {}
			world_data[str(layer)][str(coords)] = [source_id, atlas_coords, alternative_tile]


## 移除瓦片("人偶可用","本地生效","低频重要")
@rpc("any_peer", "call_local", "reliable")
func remove_tile(layer: int, coords: Vector2i) -> void:
	set_cell(layer, coords)
	var section = str(layer)
	var key = str(coords)
	if world_data != null:
		if world_data.has(section) and world_data[section].has(key):
			world_data[section].erase(key)


## 字符转二维数组
func to_vector2i(text: String) -> Vector2i:
	var cleanedStr = text.replace("(", "").replace(")", "")
	var parts = cleanedStr.split(",")
	var x = parts[0].to_int()
	var y = parts[1].to_int()
	return Vector2i(x, y)


## 保存地图数据
func save_world_data() -> void:
	if multiplayer.is_server() and world_data != null:
		var json_data = JSON.stringify(world_data)
		var file = FileAccess.open(world_data_path, FileAccess.WRITE)
		file.store_string(json_data)
		file.close()


'因多人同步淘汰CFG数据，config => Dictionary'
## 功能2:修改瓦片
## 功能1:初始化瓦片
#class_name World
#extends TileMap
#var world_data:ConfigFile
### 获取地图数据并初始化
#func _ready():
	#if multiplayer.is_server():
		#world_data = (get_tree().current_scene as GM).world_data
		#initialize_map(world_data)
	#else:
		#rpc_id(1,"send_world_data")
### 服务端-发送地图数据
#@rpc("any_peer","reliable")
#func send_world_data():
	#var sender_id = multiplayer.get_remote_sender_id()
	#rpc_id(sender_id,"initialize_map",world_data)
### 根据数据初始化地图
#@rpc("reliable")
#func initialize_map(_world_data:ConfigFile):
	#clear()
	#for section:String in _world_data.get_sections(): # Layer
		#for key:String in _world_data.get_section_keys(section): # Coord
			#var source_id = _world_data.get_value(section,key)[0]
			#var atlas_coords = _world_data.get_value(section,key)[1]
			#var alternative_tile = _world_data.get_value(section,key)[2]
			#set_tile(int(section),to_vector2i(key),source_id,atlas_coords,alternative_tile)
### 放置瓦片("人偶可用","本地生效","低频重要")
#@rpc("any_peer","call_local","reliable")
#func set_tile(layer:int,coords:Vector2i,source_id:int,atlas_coords:Vector2i,alternative_tile:int = 0):
	#set_cell(layer,coords,source_id,atlas_coords,alternative_tile)
	#if world_data != null:
		#world_data.set_value(str(layer),str(coords),[source_id,atlas_coords,alternative_tile])
### 移除瓦片("人偶可用","本地生效","低频重要")
#@rpc("any_peer","call_local","reliable")
#func remove_tile(layer:int,coords:Vector2i):
	#set_cell(layer,coords)
	#var section:String = str(layer)
	#var key:String = str(coords)
	#if world_data != null:
		#if world_data.has_section_key(section,key):
			#world_data.erase_section_key(section,key)
### 字符转二维数组
#func to_vector2i(text: String) -> Vector2i:
	#var cleanedStr = text.replace("(", "").replace(")", "")
	#var parts = cleanedStr.split(",")
	#var x = parts[0].to_int()
	#var y = parts[1].to_int()
	#var vector2i = Vector2i(x, y)
	#return vector2i
