extends Control


func _on_back_pressed():
	(get_tree().current_scene as GM).um.get_ui("TitleScreen")
	queue_free()


func _on_en_pressed():
	TranslationServer.set_locale("en")
	var setting_config = ConfigFile.new()
	setting_config.load_encrypted_pass(Config.setting_config_path,Config.setting_config_password)
	setting_config.set_value("other","language","en")
	setting_config.save_encrypted_pass(Config.setting_config_path,Config.setting_config_password)


func _on_zh_pressed():
	TranslationServer.set_locale("zh")
	var setting_config = ConfigFile.new()
	setting_config.load_encrypted_pass(Config.setting_config_path,Config.setting_config_password)
	setting_config.set_value("other","language","zh")
	setting_config.save_encrypted_pass(Config.setting_config_path,Config.setting_config_password)
