extends Control


# 不可preload以防止循环加载
var play_scene_path = "res://MainScene/PlayScene/play_scene.tscn"


# 用于页面切换
@onready var tab = $TitleScene


# 公共-返回
func _on_back_pressed():
	tab.current_tab = 0


# 首页-单人游戏
func _on_single_play_pressed():
	get_tree().change_scene_to_file(play_scene_path)


# 首页-多人游戏
func _on_multi_play_pressed():
	tab.current_tab = 1


# 首页-设置
func _on_setting_pressed():
	UiManager.get_ui("SettingOption").open_setting(self)


# 首页-语言
func _on_language_pressed():
	tab.current_tab = 2


# 首页-退出
func _on_quit_pressed():
	get_tree().quit()


# 多人-主持游戏
func _on_host_game_pressed():
	tab.current_tab = 3


# 多人-加入游戏
func _on_join_game_pressed():
	tab.current_tab = 4


# 语言-英语
func _on_english_pressed():
	TranslationServer.set_locale("en")
	var setting_config = ConfigFile.new()
	setting_config.load_encrypted_pass(GameManager.setting_config_path,GameManager.data_password)
	setting_config.set_value("other","language","en")
	setting_config.save_encrypted_pass(GameManager.setting_config_path,GameManager.data_password)


# 语言-中文
func _on_chinese_pressed():
	TranslationServer.set_locale("zh")
	var setting_config = ConfigFile.new()
	setting_config.load_encrypted_pass(GameManager.setting_config_path,GameManager.data_password)
	setting_config.set_value("other","language","zh")
	setting_config.save_encrypted_pass(GameManager.setting_config_path,GameManager.data_password)

# 多人-公共-返回
func _on_back_to_multi_pressed():
	tab.current_tab = 1


# 多人-主持-确认创建
func _on_create_pressed():
	var port = $TitleScene/MultiPage_Host/PortText.text.to_int()
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, $TitleScene/MultiPage_Host/MaxClientText.text.to_int())
	if error:
		GameManager.rpc("send_message","服务器创建失败，请尝试更换端口(默认为12766)")
		return
	multiplayer.multiplayer_peer = peer
	
	print("<多人-创建游戏>")
	GameManager.rpc("send_message","游戏已在端口%d上开启" % port)
	GameManager.rpc("send_message","可用IP:")
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168."):
			GameManager.rpc("send_message",ip)
	get_tree().change_scene_to_file(play_scene_path)


# 多人-加入-确认加入
#TODO 如果传入错误IP依然可转变场景的问题未解决，解决方式上可尝试转变场景进入彩蛋地图，并提示玩家IP错误
#TODO 设置peer后RPC不可用的问题
func _on_join_pressed():
	var ip = $TitleScene/MultiPage_Join/IPText.text
	if ip.is_empty():
		GameManager.rpc("send_message","IP地址不可为空")
		return
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(ip, $TitleScene/MultiPage_Join/PortText.text.to_int())
	if error:
		return
	multiplayer.multiplayer_peer = peer
	
	print("<多人-加入游戏>")
	get_tree().change_scene_to_file(play_scene_path)
