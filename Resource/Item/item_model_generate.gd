#TODO 多人生成器的自定义生成
class_name ItemModelGenerate
extends ItemModel


@export var generate_scene:PackedScene


func apply(_drop_item:DropItem):
	if generate_scene != null:
		generate_scene.instantiate()
