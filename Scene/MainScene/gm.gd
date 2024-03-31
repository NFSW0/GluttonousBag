## 功能7:读取存档开始游戏 #TODO 读取保存的掉落物信息和怪物信息并加载
## 功能6:记录存档使用路径
## 功能5:存储全敌人数据
## 功能4:存储全物品数据
## 功能3:处理多人游戏 TODO 同伴退出时保存同伴数据
## 功能2:发送多人消息
## 功能1:初始化游戏程序(读取并应用全部设置)
class_name GM
extends Node


# 测试用方法
func _input(event):
	if event.is_action_pressed("ui_left"): # 掉落物测试
		generate_drop_item(randi_range(0,1))
	if event.is_action_pressed("ui_right"): # 保存测试
		get_tree().get_first_node_in_group("world").save_world_data()
		for _player in get_tree().get_nodes_in_group("player"):
			_player.rpc("save_player_data")
		for _drop_item in get_tree().get_nodes_in_group("drop_item"):
			pass
	if event.is_action_pressed("ui_up"): # 地图编辑测试
		get_tree().get_first_node_in_group("world").rpc("set_tile",0,Vector2i(1,1),0,Vector2i(0,0),0)


signal play_game # 用于处理用户加入过快
@export var um:UM # 界面管理器
@export var sm:MultiplayerSpawner # 同步管理器
@export var enemy:PackedScene # 敌人场景
@export var world:PackedScene # 地图场景
@export var player:PackedScene # 玩家场景
@export var drop_item:PackedScene # 掉落物场景
@export var items:Array[Item] # 全物品集合
@export var enemies:Array[PackedScene] # 全敌人集合
var game_playing:bool # 用于处理客户端加入过快
var archive_path:String # 存档路径


func _ready():
	initialize_the_game_program()
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)
	multiplayer.server_disconnected.connect(_server_disconnected)


## 初始化游戏程序
func initialize_the_game_program():
	if not FileAccess.file_exists(Config.setting_config_path):
		um.get_ui("LanguageSetting")
	else:
		um.get_ui("TitleScreen")
	var setting_config:ConfigFile = ConfigFile.new()
	setting_config.load_encrypted_pass(Config.setting_config_path,Config.setting_config_password)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if setting_config.get_value("graphic","full_screen",false) else DisplayServer.WINDOW_MODE_WINDOWED)
	match setting_config.get_value("graphic","resolution",0):
		1:
			DisplayServer.window_set_size(Vector2i(720, 480))
		2:
			DisplayServer.window_set_size(Vector2i(720, 576))
		3:
			DisplayServer.window_set_size(Vector2i(1280, 720))
		4:
			DisplayServer.window_set_size(Vector2i(1366, 768))
		5:
			DisplayServer.window_set_size(Vector2i(1920, 1080))
		_:
			DisplayServer.window_set_size(Vector2i(640, 480))
	match setting_config.get_value("graphic","v_sync",1):
		0:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)# 快速更新，可能同时显示前后帧内容
		1:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)# 限制更新，保证每一帧完整显示
		2:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)# 动态更新，相对于屏幕刷新率实现在垂直同步和非垂直同步间切换
		3:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)# 跳跃更新，可能可以用于减少输入滞后情况
	Engine.max_fps = setting_config.get_value("graphic","max_fps",60)
	ThemeDB.fallback_base_scale = setting_config.get_value("graphic","hud_scale",1)
	var master_bus = AudioServer.get_bus_index("Master")
	var bgm_bus = AudioServer.get_bus_index("BGM")
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if master_bus >-1:
		AudioServer.set_bus_volume_db(master_bus,setting_config.get_value("audio","master_volume",0))
	if bgm_bus >-1:
		AudioServer.set_bus_volume_db(bgm_bus,setting_config.get_value("audio","bgm_volume",0))
	if sfx_bus >-1:
		AudioServer.set_bus_volume_db(sfx_bus,setting_config.get_value("audio","sfx_volume",0))
	if setting_config.has_section("control"):
		InputMap.action_erase_events("move_up")
		InputMap.action_erase_events("move_down")
		InputMap.action_erase_events("move_left")
		InputMap.action_erase_events("move_right")
		InputMap.action_erase_events("jump")
		InputMap.action_erase_events("interaction_or_use")
		InputMap.action_erase_events("cancel_or_discard")
		InputMap.action_add_event("move_up",setting_config.get_value("control","move_up"))
		InputMap.action_add_event("move_down",setting_config.get_value("control","move_down"))
		InputMap.action_add_event("move_left",setting_config.get_value("control","move_left"))
		InputMap.action_add_event("move_right",setting_config.get_value("control","move_right"))
		InputMap.action_add_event("jump",setting_config.get_value("control","jump"))
		InputMap.action_add_event("interaction_or_use",setting_config.get_value("control","interaction_or_use"))
		InputMap.action_add_event("cancel_or_discard",setting_config.get_value("control","cancel_or_discard"))
	else:
		InputMap.load_from_project_settings()
		setting_config.set_value("control","move_up",InputMap.action_get_events("move_up")[0])
		setting_config.set_value("control","move_down",InputMap.action_get_events("move_down")[0])
		setting_config.set_value("control","move_left",InputMap.action_get_events("move_left")[0])
		setting_config.set_value("control","move_right",InputMap.action_get_events("move_right")[0])
		setting_config.set_value("control","jump",InputMap.action_get_events("jump")[0])
		setting_config.set_value("control","interaction_or_use",InputMap.action_get_events("interaction_or_use")[0])
		setting_config.set_value("control","cancel_or_discard",InputMap.action_get_events("cancel_or_discard")[0])
	TranslationServer.set_locale(setting_config.get_value("other","language","zh"))


## 完成存档选择 - 处理客户端加入过快
func complete_archive_selection():
	play_game.emit() # 用于触发客户端加入过快而被暂停的事件
	game_playing = true # 在此之前加入的客户端都视为过快加入
	generate_player(1) # 生成服务端玩家
	generate_world() # 生成地图


## 全端-发送多人信息(RPC:傀儡可用-自我生效-低频重要)
@rpc("any_peer","call_local","reliable")
func send_message(message:String):
	um.get_ui("MessageBar").add_message(message)


## 服务端-生成玩家
func generate_player(id):
	if multiplayer.is_server():
		if player != null:
			var player_instantiate = player.instantiate()
			player_instantiate.name = str(id)
			sm.add_child(player_instantiate)


## 服务端-生成敌人
func generate_enemy():
	if multiplayer.is_server():
		if enemy != null:
			var enemy_instantiate = enemy.instantiate()
			enemy_instantiate.name = str(Time.get_ticks_usec())
			sm.add_child(enemy_instantiate)


## 服务端-生成地图
func generate_world():
	if multiplayer.is_server():
		if world != null:
			var world_instantiate = world.instantiate()
			world_instantiate.name = str(Time.get_ticks_usec())
			sm.add_child(world_instantiate)


## 服务端-生成掉落物
func generate_drop_item(id):
	if multiplayer.is_server():
		if drop_item != null:
			var drop_item_instantiate:DropItem = drop_item.instantiate()
			drop_item_instantiate.name = str(Time.get_ticks_usec())
			drop_item_instantiate.item_id = id
			sm.add_child(drop_item_instantiate)


## 服务端-同伴加入游戏
func _peer_connected(id):
	if multiplayer.is_server():
		print(str(multiplayer.get_unique_id()),":",str(id),"-加入游戏")
		print(str(multiplayer.get_unique_id()),":生成玩家-",str(id))
		if game_playing:
			generate_player(id)
		else:
			await play_game
			generate_player(id)


## 服务端-同伴退出游戏
func _peer_disconnected(id):
	if multiplayer.is_server():
		print(str(multiplayer.get_unique_id()),":",str(id),"-离开游戏")
		print(str(multiplayer.get_unique_id()),":销毁玩家-",str(id))
		for child in sm.get_children():
			if child.name == str(id):
				child.queue_free()


## 客户端-与服务器断开时
func _server_disconnected():
	multiplayer.multiplayer_peer = null
	um.get_ui("TitleScreen")
