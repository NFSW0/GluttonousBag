extends Control


var setting_config:ConfigFile
@onready var player_name:LineEdit = %PlayerName


func _ready():
	setting_config = ConfigFile.new()
	setting_config.load_encrypted_pass(Config.setting_config_path,Config.setting_config_password)
	player_name.text = setting_config.get_value("other","player_name","")


func _on_single_play_pressed():
	(get_tree().current_scene as GM).um.get_ui("SelectArchive")
	queue_free()


func _on_multi_play_pressed():
	(get_tree().current_scene as GM).um.get_ui("MultiPlay")
	queue_free()


func _on_setting_pressed():
	(get_tree().current_scene as GM).um.get_ui("Setting")
	queue_free()


func _on_quit_pressed():
	get_tree().quit()


func _on_player_name_text_submitted(new_text):
	setting_config.set_value("other","player_name",new_text)
	setting_config.save_encrypted_pass(Config.setting_config_path,Config.setting_config_password)
	player_name.release_focus()
