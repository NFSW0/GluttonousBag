extends Node


func save_file():
	pass


func load_file():
	pass


## 保存JSON文件(Dictionary)
func save_json(path: String,data: Dictionary) -> bool:
	if data.is_empty():
		printerr("JSON存储时遇到空数据:"+path)
		return false
	if !path.ends_with(".json"):
		printerr("JSON存储时遇到无效的文件扩展名:"+path)
		return false
	var json_data = JSON.stringify(data)
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(json_data)
	file.close()
	return true


## 读取JSON文件(Dictionary)
func load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path) or not path.ends_with(".json"):
		#printerr("JSON读取时遇到无效的文件扩展名或路径:"+path)
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	var json_data = file.get_as_text()
	file.close()
	return JSON.parse_string(json_data)
