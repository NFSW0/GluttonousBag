extends Resource
class_name SettingData

# 图像数据
var full_screen: bool # 全屏
var resolution: int # 分辨率
var v_sync: int # 垂直同步
var max_fps: int # 最大帧率
var screen_vibration: bool # 屏幕震动

# 声音数据
var master_volume: int # 主音量
var bgm_volume: int # 音乐音量
var sfx_volume: int # 音效音量

# 控制数据

# 其他数据
var language: String # 语言

# 序列化
func serialize() -> Dictionary:
	var data: Dictionary = {
		"full_screen": full_screen,
		"resolution": resolution,
		"v_sync": v_sync,
		"max_fps": max_fps,
		"screen_vibration": screen_vibration,
		"master_volume": master_volume,
		"bgm_volume": bgm_volume,
		"sfx_volume": sfx_volume,
		"language": language
	}
	return data

# 反序列化
func deserialize(data: Dictionary):
	full_screen = data.get("full_screen", false)
	resolution = data.get("resolution", 0)
	v_sync = data.get("v_sync", 1)
	max_fps = data.get("max_fps", 60)
	screen_vibration = data.get("screen_vibration",true)
	master_volume = data.get("master_volume", 0)
	bgm_volume = data.get("bgm_volume",0)
	sfx_volume = data.get("sfx_volume", 0)
	language = data.get("language","zh")
