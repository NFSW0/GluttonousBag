# 改变游玩存档
extends Control


@onready var archive_list:VBoxContainer = %ArchiveList


#TODO 优化为检索目录而不是全文件
# 加载存档列表
func _ready():
	# 创建目录
	if not DirAccess.dir_exists_absolute(Config.archive_config_path):
		DirAccess.make_dir_recursive_absolute(Config.archive_config_path)
	# 查询目录
	var dir = DirAccess.open(Config.archive_config_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("发现存档：" + file_name)
				var archive = Button.new()
				archive.text = file_name
				archive.pressed.connect(func():(get_tree().current_scene as GM).archive_path = Config.archive_config_path+file_name+"/")
				archive.pressed.connect(func():(get_tree().current_scene as GM).complete_archive_selection())
				archive.pressed.connect(func():queue_free())
				archive_list.add_child(archive)
			file_name = dir.get_next()
	else:
		print("尝试访问路径时出错:",Config.archive_config_path)



# 新建存档
func _on_new_archive_pressed():
	(get_tree().current_scene as GM).um.get_ui("NewArchive")
	queue_free()


# 返回
func _on_back_pressed():
	(get_tree().current_scene as GM).um.get_ui("TitleScreen")
	queue_free()
