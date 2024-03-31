class_name ItemModelColne
extends ItemModel

func apply(drop_item:DropItem):
	var clone_node = drop_item.duplicate()
	clone_node.name = str(Time.get_ticks_usec())
	drop_item.get_parent().add_child(clone_node)
