## 功能3:游戏阶段事件中心
## 功能2:读取并应用全部设置
## 功能1:发送多人消息
extends Node


signal play_scene_ready # PlayScene加载后触发


var data_password:String = "E1c2fBa4cd92A30fD5f20240226A0acAefeEd11Ad5f1C6b1959eEbEd2DbA6Aa9"# 数据存储密钥
var setting_config_path:String = "user://setting.cfg"# 设置数据存储路径
var is_play_scene_loaded:bool = false


func _input(event):
	if event.is_action_pressed("test_button"):
		if is_play_scene_loaded:
			get_tree().current_scene.rpc("generate_entity","res://OtherScene/DropItem/drop_item.tscn")


func _ready():
	apply_setting_data() # 应用设置数据


# 由PlayScene的Ready方法末尾调用
func play_scene_has_loaded():
	is_play_scene_loaded = true
	play_scene_ready.emit()


# 读取并应用全部设置
func apply_setting_data():
	var setting_config:ConfigFile = ConfigFile.new()
	setting_config.load_encrypted_pass(setting_config_path,data_password)
	# 图像
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
	# 声音
	var master_bus = AudioServer.get_bus_index("Master")
	var bgm_bus = AudioServer.get_bus_index("BGM")
	var sfx_bus = AudioServer.get_bus_index("SFX")
	if master_bus >-1:
		AudioServer.set_bus_volume_db(master_bus,setting_config.get_value("audio","master_volume",0))
	if bgm_bus >-1:
		AudioServer.set_bus_volume_db(bgm_bus,setting_config.get_value("audio","bgm_volume",0))
	if sfx_bus >-1:
		AudioServer.set_bus_volume_db(sfx_bus,setting_config.get_value("audio","sfx_volume",0))
	# 其他
	TranslationServer.set_locale(setting_config.get_value("other","language","en"))


# 发送多人信息(RPC:傀儡可用-自我生效-低频重要)
@rpc("any_peer","call_local","reliable")
func send_message(message:String):
	UiManager.get_ui("MessageBox").add_message(message)
