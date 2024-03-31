extends Control


@onready var archive_name:LineEdit = %ArchiveName


# 完成存档创建
func _on_complete_pressed():
	var dir = DirAccess.open(Config.archive_config_path)
	if dir:
		dir.make_dir(archive_name.text)
	(get_tree().current_scene as GM).um.get_ui("SelectArchive")
	queue_free()


# 取消存档创建
func _on_back_pressed():
	(get_tree().current_scene as GM).um.get_ui("SelectArchive")
	queue_free()
