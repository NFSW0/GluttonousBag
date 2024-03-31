# 主动功能:合成物品 TODO 产生新物品 TODO 简易合成的主次判断
# 被动功能:使用物品
class_name DropItem
extends RigidBody2D


@export var item_id:int # 物品编号
var item:Item # 物品数据
var last_owner:Node2D # 最新持有者
var action_object:Node2D # 作用对象
var using:bool = false # 用于更新掉落物位置
var collide_count:int = 0 #用于简易合成中判断主次 拾起后重置
@onready var item_area:Area2D = $ItemArea # 检测触碰事件
@onready var sprite:Sprite2D = $Sprite2D # 用于显示


# 掉落物初始化
func _ready():
	if item == null:
		item = get_tree().current_scene.items[item_id]
		if item.icon != null:
			sprite.texture = item.icon


# 更新掉落物位置
func _process(_delta):
	if using:
		position = last_owner.position + Vector2(0,-20)


# 拾起掉落物
@rpc("any_peer","call_local","reliable")
func interaction(player_name:String):
	if not freeze:
		freeze = true
		item_area.monitorable = false
		var players = get_tree().get_nodes_in_group("player")
		for player in players:
			if player.name == player_name:
				last_owner = player
		using = true
		collide_count = 0
		if item.on_item_pick_up != null:
			item.on_item_pick_up.apply(self)


# 使用掉落物
@rpc("any_peer","call_local","reliable")
func use():
	print(last_owner.name,"使用物品:",item.item_name)
	if item.on_item_use != null:
		item.on_item_use.apply(self)


# 丢弃掉落物
@rpc("any_peer","call_local","reliable")
func cancel_or_discard():
	if freeze:
		freeze = false
		item_area.monitorable = true
		using = false
		if item.on_item_drop_down != null:
			item.on_item_drop_down.apply(self)


# 触碰掉落物
func _on_item_area_area_entered(area):
	if area.owner != null:
		action_object = area.owner
	else:
		action_object = area
	print(action_object.name,"触碰物品:",item.item_name)
	if item.on_item_touch != null:
		item.on_item_touch.apply(self)


# 掉落物碰撞(两个物品之间的简易合成)
func _on_body_entered(body):
	if multiplayer.is_server():
		collide_count += 1
		if body is DropItem:
			if collide_count < body.collide_count:
				print(item.item_name,"触发物品合成:",body.item.item_name)
				var body_position = body.position
				body.queue_free()
				set_axis_velocity(200*(position-body_position))
