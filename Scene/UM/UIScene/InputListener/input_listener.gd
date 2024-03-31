class_name InputListener
extends Control


signal end(event)


func _input(event):
	if not event is InputEventMouseMotion:
		if event.is_released():
			end.emit(event)
			queue_free()
