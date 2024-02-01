extends CharacterBody2D


var move_speed = 200.0 # 移动速度
var jump_velocity = -300.0 # 跳跃速度
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # 重力
var interactive_range = 5 # 交互范围


var interactive_objects = []
var target_interactive_object
var object_in_interact


@onready var interactive_area:Area2D = $InteractiveArea
@onready var wound_area:Area2D = $_WoundArea


func _enter_tree():
	# 根据节点名称设置多人权限
	set_multiplayer_authority(name.to_int())


func _process(_delta):
	update_target_interactive_object()
	handle_interactions()


func _physics_process(delta):
	if is_multiplayer_authority():
		# 模拟重力
		if not is_on_floor():
			velocity.y += gravity * delta
		# 处理跳跃
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = jump_velocity
		# 处理移动 
		var direction = Input.get_axis("move_left", "move_right")
		if direction:
			velocity.x = direction * move_speed
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
		# 平滑移动
		move_and_slide()


## 交互
# 处理交互行为
func handle_interactions():
	if Input.is_action_just_pressed("interact"):
		if target_interactive_object != null and target_interactive_object.has_method("interact"):
			target_interactive_object.interact(self)
# 更新距离最近的交互对象为交互目标
func update_target_interactive_object():
	if !interactive_objects.is_empty():
		for object in interactive_objects:
			if target_interactive_object == null or position.distance_to(object.position) < position.distance_to(target_interactive_object.position):
				target_interactive_object = object
	else:
		target_interactive_object = null
# 增加可加护对象
func _on_interactive_area_area_entered(area):
	interactive_objects.append(area.owner)
# 剔除不可交互对象
func _on_interactive_area_area_exited(area):
	interactive_objects.erase(area.owner)
