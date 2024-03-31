extends CharacterBody2D


# 移动参数
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # 重力
var move_speed = 300.0 # 移动速度
var jump_speed = -400.0 # 跳跃速度


# 交互参数
var all_interactive_items = [] # 范围内全部交互项目
var target_interactive_item # 目标交互项目
var interacted_item # 交互中的项目






var player_data: Dictionary ## 服务端-玩家数据
var player_data_path: String ## 服务端-数据存储路径

## 存档加载
func _ready():
	var player_name = get_player_name()
	if multiplayer.is_server():
		# 服务端 - 主动初始化
		player_data = get_player_data(player_name)
		initialize_player(player_data)
	else:
		# 客户端 - 被动初始化
		rpc_id(1,"send_player_data",player_name)

## 获取玩家名称
func get_player_name():
	var setting_config:ConfigFile = ConfigFile.new()
	setting_config.load_encrypted_pass(Config.setting_config_path,Config.setting_config_password)
	return setting_config.get_value("other","player_name","")

## 服务端-读取玩家数据
func get_player_data(save_name:String) -> Dictionary:
	player_data_path = (get_tree().current_scene as GM).archive_path + save_name + ".json"
	if FileAccess.file_exists(player_data_path):
		return JSON.parse_string(FileAccess.open(player_data_path, FileAccess.READ).get_as_text())
	else:
		return {"player_name":save_name}

## 服务端-主动初始化 客户端-被动初始化
@rpc("any_peer","reliable")
func initialize_player(data:Dictionary):
	position.x = float(data.get("position_x","0"))
	position.y = float(data.get("position_y","0"))

## 服务端-发送玩家数据
@rpc("any_peer", "reliable")
func send_player_data(player_name) -> void:
	var sender_id = multiplayer.get_remote_sender_id()
	player_data = get_player_data(player_name)
	rpc_id(sender_id, "initialize_player", player_data)

## 服务端-保存玩家数据
@rpc("any_peer","call_local","reliable")
func save_player_data() -> void:
	if multiplayer.is_server():
		player_data["position_x"] = str(position.x)
		player_data["position_y"] = str(position.y)
		var json_data = JSON.stringify(player_data)
		var file = FileAccess.open(player_data_path, FileAccess.WRITE)
		file.store_string(json_data)
		file.close()





# 多人游戏
func _enter_tree():
	set_multiplayer_authority(name.to_int())


# 逻辑实现
func _physics_process(delta):
	if is_multiplayer_authority():
		# 重力逻辑
		#TODO 爬梯
		if not is_on_floor():
			velocity.y += gravity * delta
		# 移动逻辑
		handle_move()
		# 交互逻辑
		interaction_or_use()
		# 中断逻辑
		cancel_or_discard()


# 移动逻辑
func handle_move():
	# 跳跃逻辑
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_speed
	# 行动逻辑
	var direction = Input.get_vector("move_left", "move_right","move_up","move_down")
	#TODO 垂直速度需判断body区域是否与爬梯区域有重合
	if direction:
		velocity.x = direction.x * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
	move_and_slide()


# 交互逻辑
func interaction_or_use():
	# 确定交互目标
	if all_interactive_items.is_empty():
		target_interactive_item = null
	else:
		for interactive_item in all_interactive_items:
			if target_interactive_item == null or position.distance_squared_to(interactive_item.position)<position.distance_squared_to(target_interactive_item.position):
				target_interactive_item = interactive_item
	# 执行交互行为
	if Input.is_action_just_pressed("interaction_or_use"):
		if interacted_item == null:
			if not target_interactive_item == null:
				if target_interactive_item.has_method("interaction"):
					target_interactive_item.rpc("interaction",name)
					#target_interactive_item.interaction(self)
					interacted_item = target_interactive_item
		else:
			if interacted_item.has_method("use"):
				interacted_item.rpc("use")


# 中断逻辑
func cancel_or_discard():
	if Input.is_action_just_pressed("cancel_or_discard"):
		if interacted_item != null:
			if interacted_item.has_method("cancel_or_discard"):
				interacted_item.rpc("cancel_or_discard")
				interacted_item = null


# 添加进入交互范围的物体
func _on__item_area_area_entered(area):
	all_interactive_items.append(area.owner)


# 移除离开交互范围的物体
func _on__item_area_area_exited(area):
	all_interactive_items.erase(area.owner)
