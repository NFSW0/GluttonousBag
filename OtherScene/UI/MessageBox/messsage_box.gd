## UI主要功能:短暂显示广播内容
## UI加载条件:被GameManager通过UIManager调用以广播消息
## UI附加效果:添加的Label短暂显示后渐隐并销毁
## TODO 限制消息单次显示上限，避免消息炸屏
extends VBoxContainer


var message_id =1 ## 下一条消息编号
var message_duration =3 ## 消息持续时间
var message_fade_time =1 ## 消息淡出时间


func add_message(label_text):
	# 添加Label
	var new_label = Label.new()
	new_label.text = label_text
	new_label.name = str(message_id)
	add_child(new_label)
	# 淡出Label
	message_id = message_id +1
	var tween = new_label.create_tween()
	tween.tween_interval(message_duration)
	tween.tween_property(new_label, "self_modulate", Color.TRANSPARENT, message_fade_time)
	tween.tween_callback(new_label.queue_free)

