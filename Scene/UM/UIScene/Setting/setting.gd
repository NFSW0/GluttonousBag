# 设置界面
extends Control


var setting_config:ConfigFile
var setting_config_path:String = Config.setting_config_path
var setting_config_password:String = Config.setting_config_password


@onready var setting_page:TabContainer = %SettingPage
@onready var full_screen:CheckButton = %FullScreen
@onready var resolution:OptionButton = %Resolution
@onready var v_sync:OptionButton = %V_Sync
@onready var max_fps:SpinBox = %MaxFPS
@onready var screen_vibration:CheckButton = %ScreenVibration
@onready var hud_scale:HSlider = %HUDScale
@onready var master_volume:HSlider = %MasterVolume
@onready var bgm_volume:HSlider = %BGMVolume
@onready var sfx_volume:HSlider = %SFXVolume
@onready var move_up:Button = %MoveUp
@onready var move_down:Button = %MoveDown
@onready var move_left:Button = %MoveLeft
@onready var move_right:Button = %MoveRight
@onready var jump:Button = %Jump
@onready var interaction_or_use:Button = %InteractionOrUse
@onready var cancel_or_discard:Button = %CancelOrDiscard
@onready var language:Button = %Language


# 设置初始化
func _ready():
	setting_config = ConfigFile.new()
	setting_config.load_encrypted_pass(setting_config_path,setting_config_password)
	setting_page.current_tab = 0
	full_screen.set_pressed_no_signal(setting_config.get_value("graphic","full_screen",false))
	resolution.selected = setting_config.get_value("graphic","resolution",0)
	v_sync.selected = setting_config.get_value("graphic","v_sync",1)
	max_fps.value = setting_config.get_value("graphic","max_fps",60)
	screen_vibration.set_pressed_no_signal(setting_config.get_value("graphic","screen_vibration",true))
	hud_scale.value = setting_config.get_value("graphic","hud_scale",1)
	master_volume.value = setting_config.get_value("audio","master_volume",0)
	bgm_volume.value = setting_config.get_value("audio","bgm_volume",0)
	sfx_volume.value = setting_config.get_value("audio","sfx_volume",0)
	if setting_config.has_section("control"):
		move_up.text = setting_config.get_value("control","move_up").as_text()
		move_down.text = setting_config.get_value("control","move_down").as_text()
		move_left.text = setting_config.get_value("control","move_left").as_text()
		move_right.text = setting_config.get_value("control","move_right").as_text()
		jump.text = setting_config.get_value("control","jump").as_text()
		interaction_or_use.text = setting_config.get_value("control","interaction_or_use").as_text()
		cancel_or_discard.text = setting_config.get_value("control","cancel_or_discard").as_text()
	else:
		move_up.text = "W"
		move_down.text = "S"
		move_left.text = "A"
		move_right.text = "D"
		jump.text = "Space"
		interaction_or_use.text = "Left Mouse Button"
		cancel_or_discard.text = "Right Mouse Button"
	language.text = setting_config.get_value("other","language","--")


# 完成设置
func _on_complete_pressed():
	setting_config.save_encrypted_pass(setting_config_path,setting_config_password)
	(get_tree().current_scene as GM).um.get_ui("TitleScreen")
	queue_free()


# 设置分页
func _on_graphic_focus_entered():
	setting_page.set_current_tab(0)
func _on_audio_focus_entered():
	setting_page.set_current_tab(1)
func _on_control_focus_entered():
	setting_page.set_current_tab(2)
func _on_other_focus_entered():
	setting_page.set_current_tab(3)


# 图像
func _on_full_screen_toggled(toggled_on):
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED)
	setting_config.set_value("graphic","full_screen",toggled_on)
func _on_resolution_item_selected(index):
	var old_resolution = DisplayServer.window_get_size()
	match index:
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
	var pop = Popup.new()
	pop.popup_hide.connect(func():DisplayServer.window_set_size(old_resolution))
	pop.popup_hide.connect(func():pop.queue_free())
	add_child(pop)
	pop.popup_centered_ratio(0.2)
	var accept_button = Button.new()
	accept_button.text = "即将取消(3),点击确认"
	accept_button.pressed.connect(func():setting_config.set_value("graphic","resolution",index))
	accept_button.pressed.connect(func():pop.queue_free())
	pop.add_child(accept_button)
	accept_button.anchors_preset = PRESET_FULL_RECT
	var tween = accept_button.create_tween()
	tween.tween_property(accept_button, "text", "即将取消(2),点击确认", 1)
	tween.tween_property(accept_button, "text", "即将取消(1),点击确认", 1)
	tween.tween_property(accept_button, "text", "即将取消(0),点击确认", 1)
	tween.tween_callback(pop.hide)
func _on_v_sync_item_selected(index):
	match index:
		0:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		1:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		2:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
		3:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)
	setting_config.set_value("graphic","v_sync",index)
func _on_max_fps_value_changed(value):
	Engine.max_fps = value
	setting_config.set_value("graphic","max_fps",value)
func _on_screen_vibration_toggled(toggled_on):
	(get_tree().current_scene as GM).rpc("send_message","开启屏幕震动" if toggled_on else "关闭屏幕震动")
	setting_config.set_value("graphic","screen_vibration",toggled_on)
func _on_hud_scale_drag_ended(value_changed):
	if value_changed:
		var value = master_volume.value
		ThemeDB.fallback_base_scale = value
		setting_config.set_value("graphic","hud_scale",value)


# 声音
func _on_master_volume_drag_ended(value_changed):
	if value_changed:
		var audio_bus = AudioServer.get_bus_index("Master")
		if audio_bus >-1:
			var value = master_volume.value
			AudioServer.set_bus_volume_db(audio_bus,value)
			setting_config.set_value("audio","master_volume",value)
func _on_bgm_volume_drag_ended(value_changed):
	if value_changed:
		var audio_bus = AudioServer.get_bus_index("BGM")
		if audio_bus >-1:
			var value = bgm_volume.value
			AudioServer.set_bus_volume_db(audio_bus,value)
			setting_config.set_value("audio","bgm_volume",value)
func _on_sfx_volume_drag_ended(value_changed):
	if value_changed:
		var audio_bus = AudioServer.get_bus_index("SFX")
		if audio_bus >-1:
			var value = sfx_volume.value
			AudioServer.set_bus_volume_db(audio_bus,value)
			setting_config.set_value("audio","sfx_volume",value)


# 控制
func _on_restore_default_pressed():
	InputMap.load_from_project_settings()
	setting_config.set_value("control","move_up",InputMap.action_get_events("move_up")[0])
	setting_config.set_value("control","move_down",InputMap.action_get_events("move_down")[0])
	setting_config.set_value("control","move_left",InputMap.action_get_events("move_left")[0])
	setting_config.set_value("control","move_right",InputMap.action_get_events("move_right")[0])
	setting_config.set_value("control","jump",InputMap.action_get_events("jump")[0])
	setting_config.set_value("control","interaction_or_use",InputMap.action_get_events("interaction_or_use")[0])
	setting_config.set_value("control","cancel_or_discard",InputMap.action_get_events("cancel_or_discard")[0])
	move_up.text = "W"
	move_down.text = "S"
	move_left.text = "A"
	move_right.text = "D"
	jump.text = "Space"
	interaction_or_use.text = "Left Mouse Button"
	cancel_or_discard.text = "Right Mouse Button"
func _on_move_up_pressed():
	move_up.release_focus()
	move_up.text = "--"
	InputMap.action_erase_events("move_up")
	var input_listener = InputListener.new()
	input_listener.end.connect(func(event:InputEvent):InputMap.action_add_event("move_up",event))
	input_listener.end.connect(func(event:InputEvent):move_up.text = event.as_text())
	input_listener.end.connect(func(event:InputEvent):setting_config.set_value("control","move_up",event))
	add_child(input_listener)
func _on_move_down_pressed():
	move_down.release_focus()
	move_down.text = "--"
	InputMap.action_erase_events("move_down")
	var input_listener = InputListener.new()
	input_listener.end.connect(func(event:InputEvent):InputMap.action_add_event("move_down",event))
	input_listener.end.connect(func(event:InputEvent):move_down.text = event.as_text())
	input_listener.end.connect(func(event:InputEvent):setting_config.set_value("control","move_down",event))
	add_child(input_listener)
func _on_move_left_pressed():
	move_left.release_focus()
	move_left.text = "--"
	InputMap.action_erase_events("move_left")
	var input_listener = InputListener.new()
	input_listener.end.connect(func(event:InputEvent):InputMap.action_add_event("move_left",event))
	input_listener.end.connect(func(event:InputEvent):move_left.text = event.as_text())
	input_listener.end.connect(func(event:InputEvent):setting_config.set_value("control","move_left",event))
	add_child(input_listener)
func _on_move_right_pressed():
	move_right.release_focus()
	move_right.text = "--"
	InputMap.action_erase_events("move_right")
	var input_listener = InputListener.new()
	input_listener.end.connect(func(event:InputEvent):InputMap.action_add_event("move_right",event))
	input_listener.end.connect(func(event:InputEvent):move_right.text = event.as_text())
	input_listener.end.connect(func(event:InputEvent):setting_config.set_value("control","move_right",event))
	add_child(input_listener)
func _on_jump_pressed():
	jump.release_focus()
	jump.text = "--"
	InputMap.action_erase_events("jump")
	var input_listener = InputListener.new()
	input_listener.end.connect(func(event:InputEvent):InputMap.action_add_event("jump",event))
	input_listener.end.connect(func(event:InputEvent):jump.text = event.as_text())
	input_listener.end.connect(func(event:InputEvent):setting_config.set_value("control","jump",event))
	add_child(input_listener)
func _on_interaction_or_use_pressed():
	interaction_or_use.release_focus()
	interaction_or_use.text = "--"
	InputMap.action_erase_events("interaction_or_use")
	var input_listener = InputListener.new()
	input_listener.end.connect(func(event:InputEvent):InputMap.action_add_event("interaction_or_use",event))
	input_listener.end.connect(func(event:InputEvent):interaction_or_use.text = event.as_text())
	input_listener.end.connect(func(event:InputEvent):setting_config.set_value("control","interaction_or_use",event))
	add_child(input_listener)
func _on_cancel_or_discard_pressed():
	cancel_or_discard.release_focus()
	cancel_or_discard.text = "--"
	InputMap.action_erase_events("cancel_or_discard")
	var input_listener = InputListener.new()
	input_listener.end.connect(func(event:InputEvent):InputMap.action_add_event("cancel_or_discard",event))
	input_listener.end.connect(func(event:InputEvent):cancel_or_discard.text = event.as_text())
	input_listener.end.connect(func(event:InputEvent):setting_config.set_value("control","cancel_or_discard",event))
	add_child(input_listener)


# 其他
func _on_language_pressed():
	(get_tree().current_scene as GM).um.get_ui("LanguageSetting")
	queue_free()



