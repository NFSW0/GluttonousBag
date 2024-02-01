# 主要功能:加载UI
# 常见案例
# 玩家生成后加载角色UI
# 按下聊天按键后加载聊天UI
extends CanvasLayer


var directory = "res://OtherScene/UI"


func get_ui(ui_name: String) -> Node:
	# 检查UI是否已经加载
	for child_node in get_children():
		if child_node.name == ui_name:
			return child_node
	# 从目录加载UI
	var dir = DirAccess.open(directory)
	if dir:
		var _dirs = dir.get_directories()
		# 检查目录中是否存在UI文件夹
		var index = _dirs.find(ui_name)
		if index >= 0:
			var _dir = _dirs[index]
			# 切换到UI文件夹
			if not dir.change_dir(_dir):
				# 搜索UI文件夹中的“.tscn”文件
				for file_name in dir.get_files():
					if file_name.ends_with(".tscn"):
						var ui_scene_path = dir.get_current_dir() + "/" + file_name
						var ui_scene_instantiate = (load(ui_scene_path) as PackedScene).instantiate()
						ui_scene_instantiate.name = ui_name
						add_child(ui_scene_instantiate)
						return ui_scene_instantiate
				print("<UIManager> No '.tscn' files found in", ui_name, "directory.")
			else:
				print("<UIManager> Error changing to directory:", dir.get_current_dir())
		else:
			print("<UIManager> UI folder named", ui_name, "does not exist. Please create the UI folder or check the name.")
	else:
		print("<UIManager> Directory opening failed:", DirAccess.get_open_error())
	return null
