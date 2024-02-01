# UI主要功能:发送信息(通过UIManager让TextBox添加Label)、保存消息记录(可翻看)
# UI加载条件:玩家按下指定按钮(如Enter)
extends LineEdit


func _on_text_submitted(new_text):
	GameManager.rpc("send_message",new_text)
