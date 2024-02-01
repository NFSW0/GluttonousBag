extends Control


var setting_config: ConfigFile = ConfigFile.new()


var opener_owner # 用于隐藏多余UI


@onready var setting_page : TabContainer = $MarginContainer/VBoxContainer/Body/SettingPage # 用于更换设置页面
@onready var graphic_full_screen : CheckBox = $MarginContainer/VBoxContainer/Body/SettingPage/GraphicsSetting/GraphicsSetting/FullScreenOption/FullScreen
@onready var graphic_resolution : OptionButton = $MarginContainer/VBoxContainer/Body/SettingPage/GraphicsSetting/GraphicsSetting/ResolutionOption/Resolution
@onready var graphic_v_sync : OptionButton = $"MarginContainer/VBoxContainer/Body/SettingPage/GraphicsSetting/GraphicsSetting/V-SyncOption/V-Sync"
@onready var graphic_max_fps : SpinBox = $MarginContainer/VBoxContainer/Body/SettingPage/GraphicsSetting/GraphicsSetting/MaxFPSOption/MaxFPS
@onready var graphic_screen_vibration : CheckBox = $MarginContainer/VBoxContainer/Body/SettingPage/GraphicsSetting/GraphicsSetting/ScreenVibrationOption/ScreenVibration
@onready var audio_master_volume : SpinBox = $MarginContainer/VBoxContainer/Body/SettingPage/AudioSetting/AudioSetting/MasterVolumeOption/MasterVolume
@onready var audio_bgm_volume : SpinBox = $MarginContainer/VBoxContainer/Body/SettingPage/AudioSetting/AudioSetting/BGMVolumeOption/BGMVolume
@onready var audio_sfx_volume : SpinBox = $MarginContainer/VBoxContainer/Body/SettingPage/AudioSetting/AudioSetting/SFXVolumeOption/SFXVolume


func _ready():
	setting_config.load_encrypted_pass(GameManager.setting_config_path,GameManager.data_password)
	# 初始化设置选项
	graphic_full_screen.set_pressed_no_signal(setting_config.get_value("graphic","full_screen",false))
	graphic_resolution.selected = setting_config.get_value("graphic","resolution",0)
	graphic_v_sync.selected = setting_config.get_value("graphic","v_sync",1)
	graphic_max_fps.value = setting_config.get_value("graphic","max_fps",60)
	graphic_screen_vibration.set_pressed_no_signal(setting_config.get_value("graphic","screen_vibration",true))
	audio_master_volume.value = setting_config.get_value("audio","master_volume",0)
	audio_bgm_volume.value = setting_config.get_value("audio","bgm_volume",0)
	audio_sfx_volume.value = setting_config.get_value("audio","sfx_volume",0)


# 开启设置
func open_setting(opener:Node):
	if opener.owner:
		opener_owner = opener.owner
	else:
		opener_owner = opener
	if opener.has_method("hide"):
		opener_owner.hide()
# 关闭设置
func _on_completed_pressed():
	setting_config.save_encrypted_pass(GameManager.setting_config_path,GameManager.data_password)
	if opener_owner:
		if opener_owner.has_method("hide"):
			opener_owner.show()
		call_deferred("queue_free")
	else:
		get_tree().change_scene_to_file("res://MainScene/StartScene/start_scene.tscn")


# 跳转图像设置界面
func _on_graphic_pressed():
	setting_page.current_tab = 0
# 跳转声音设置界面
func _on_audio_pressed():
	setting_page.current_tab = 1
# 跳转控制设置界面
func _on_control_pressed():
	setting_page.current_tab = 2
# 跳转其他设置界面
func _on_other_pressed():
	setting_page.current_tab = 3


# 图像-全屏选项
func _on_full_screen_toggled(toggled_on):
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED)
	$MarginContainer/VBoxContainer/Body/SettingPage/GraphicsSetting/GraphicsSetting/ResolutionOption.visible = !toggled_on
	setting_config.set_value("graphic","full_screen",toggled_on)
# 图像-分辨率选项
func _on_resolution_item_selected(index):
	var old_resolution = DisplayServer.window_get_size()
	var target_resolution: Vector2i
	match index:
		1:
			target_resolution = Vector2i(720, 480)
		2:
			target_resolution = Vector2i(720, 576)
		3:
			target_resolution = Vector2i(1280, 720)
		4:
			target_resolution = Vector2i(1366, 768)
		5:
			target_resolution = Vector2i(1920, 1080)
		_:
			target_resolution = Vector2i(640, 480)
	DisplayServer.window_set_size(target_resolution)
	# 弹窗
	var pop = Popup.new()
	pop.popup_hide.connect(func():DisplayServer.window_set_size(old_resolution))
	add_child(pop)
	pop.popup_centered_ratio(0.2)
	var accept_button = Button.new()
	accept_button.text = "<ClickToKeepChange>"
	accept_button.pressed.connect(func():setting_config.set_value("graphic","resolution",index))
	accept_button.pressed.connect(func():pop.queue_free())
	pop.add_child(accept_button)
	accept_button.anchors_preset = PRESET_FULL_RECT
# 图像-垂直同步选项
func _on_v_sync_item_selected(index):
	match index:
		0:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)# 快速更新，可能同时显示前后帧内容
		1:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)# 限制更新，保证每一帧完整显示
		2:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)# 动态更新，相对于屏幕刷新率实现在垂直同步和非垂直同步间切换
		3:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)# 跳跃更新，可能可以用于减少输入滞后情况
	setting_config.set_value("graphic","v_sync",index)
# 图像-最大帧率选项
func _on_max_fps_value_changed(value):
	Engine.max_fps = value
	setting_config.set_value("graphic","max_fps",value)
#TODO 图像-屏幕震动选项(TODO 包括游戏启动时-GameManger)
func _on_screen_vibration_toggled(toggled_on):
	setting_config.set_value("graphic","screen_vibration",toggled_on)


# 声音-主音量选项
func _on_master_volume_value_changed(value):
	var audio_bus = AudioServer.get_bus_index("Master")
	if audio_bus >-1:
		AudioServer.set_bus_volume_db(audio_bus,value)
		setting_config.set_value("audio","master_volume",value)
# 声音-音乐音量
func _on_bgm_volume_value_changed(value):
	var audio_bus = AudioServer.get_bus_index("BGM")
	if audio_bus >-1:
		AudioServer.set_bus_volume_db(audio_bus,value)
		setting_config.set_value("audio","bgm_volume",value)
# 声音-音效音量
func _on_sfx_volume_value_changed(value):
	var audio_bus = AudioServer.get_bus_index("SFX")
	if audio_bus >-1:
		AudioServer.set_bus_volume_db(audio_bus,value)
		setting_config.set_value("audio","sfx_volume",value)
