# 主要功能:加载UI
# 常见案例:
# 玩家生成后加载角色UI
# 按下聊天按键后加载聊天UI
class_name UM
extends CanvasLayer


@export var ui_scenes:Dictionary


func get_ui(ui_name: String) -> Node:
	# 检查UI是否已经加载
	for child_node in get_children():
		if child_node.name == ui_name:
			return child_node
	# 从字典加载UI
	if ui_scenes.has(ui_name):
		if (ui_scenes[ui_name] as PackedScene).can_instantiate():
			var new_node = (ui_scenes[ui_name] as PackedScene).instantiate()
			add_child(new_node)
			return new_node
	return null
