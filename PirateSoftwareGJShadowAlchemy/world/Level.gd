extends Node2D

@onready var player: Player = $Player
@onready var tile_map: TileMap = $TileMap

@export var can_win : bool = false
@export var has_won : bool = false
signal change_level 
@export var next_level_path : String

@export var grid_size : int = 32
const BOX = preload("res://world/box/box.tscn")

@export var selected_box : Node
@export var temp_box : Node
@onready var selected_space: Area2D = $SelectedSpace
@onready var selected_space_sprite: Sprite2D = $SelectedSpace/SelectedSpaceSprite
@onready var collision_shape: CollisionShape2D = $SelectedSpace/SelectedSpaceArea/CollisionShape
@onready var exit: Node2D = $Exit

var can_select: bool = true
var can_transmute : bool = false

func can_win_handler():
	exit.can_win = true
	print("player can now win")
	
func win_handler():
	has_won = true
	#change_level.emit()
	get_tree().change_scene_to_file(next_level_path)
	print("player has won")

func _ready() -> void:
	can_win = false
	has_won = false
	player.connect("can_transmute", can_transmute_handler)
	player.connect("cannot_transmute", cannot_transmute_handler)
	selected_space.connect("selected_space_enter", selected_space_enter_handler)
	selected_space.connect("selected_space_exit", selected_space_exit_handler)
	exit.connect("can_win_signal", can_win_handler)
	exit.connect("has_won_signal", win_handler)
	
	
func selected_space_enter_handler(body):
	#selected_space.frame = 2
	temp_box = body
	
func selected_space_exit_handler():
	temp_box = null
	selected_box = null

func can_transmute_handler():
	if selected_box != null:
		selected_box == null
	can_transmute = true
	
func cannot_transmute_handler():
	print("leave")
	can_transmute = false


func _process(delta: float) -> void:
	if has_won != true:
		if player.has_staff == true:
			player.area_sprite.show()
			player.staff_sprite.show()
			selected_space_sprite.show()
			selected_space_movement()
		else:
			player.area_sprite.hide()
			player.staff_sprite.hide()
			selected_space_sprite.hide()
			pass
	
func selected_space_movement():
	#if can_transmute == false:
		#selected_box = null
	if can_transmute and selected_box == null:
		selected_space_sprite.frame = 1
	elif can_transmute and temp_box != null:
		selected_space_sprite.frame = 2
	elif can_transmute == false and temp_box == null:
		selected_space_sprite.frame = 3
		selected_box = null
	elif can_transmute == false and temp_box != null:
		selected_space_sprite.frame = 3
		
	if temp_box != null:
		if can_transmute:
			if Input.is_action_just_pressed("interact"):
				selected_space_sprite.frame = 0
				selected_box = temp_box
				temp_box = null
			
	if selected_box != null:
		if Input.is_action_just_pressed("cancel"):
			selected_space_sprite.frame = 1
			selected_box = null
		if can_transmute:
			if Input.is_action_just_pressed("arrow_left"):
				transmute(Vector2.LEFT)
			if Input.is_action_just_pressed("arrow_right"):
				transmute(Vector2.RIGHT)
			if Input.is_action_just_pressed("arrow_up"):
				transmute(Vector2.UP)
			if Input.is_action_just_pressed("arrow_down"):
				transmute(Vector2.DOWN)
	else:
		if Input.is_action_just_pressed("arrow_left"):
			selected_space.global_position.x -= 32
		if Input.is_action_just_pressed("arrow_right"):
			selected_space.global_position.x += 32
		if Input.is_action_just_pressed("arrow_up"):
			selected_space.global_position.y -= 32
		if Input.is_action_just_pressed("arrow_down"):
			selected_space.global_position.y += 32


func transmute(vel: Vector2):
	var vel_norm = vel.normalized()
	print(vel_norm)
	var new_pos = vel_norm * grid_size
	selected_box.transmute_raycast.target_position = new_pos*1.45
	selected_box.transmute_raycast.force_raycast_update()
		
	#for t_ray in selected_box.extra_transmute_rays.get_children():
		#if t_ray.is_colliding():
			#return false
			
	if selected_box.tr_tr.is_colliding() or selected_box.tr_tl.is_colliding():
		if vel_norm == Vector2(0, -1):
			print("cant push up cause on top")
			return
			
	if selected_box.tr_br.is_colliding() or selected_box.tr_bl.is_colliding():
		if vel_norm == Vector2(0, 1):
			print("cant push down cause beneath")
			return
			
	if selected_box != null:
		if selected_box.box_type != "Stone":
			#NOT STONE SPECIFIC
			#SPLIT INTO TWO
			if !selected_box.transmute_raycast.is_colliding() and selected_box.is_sliding == false:
				print("Yep")
				if selected_box.is_on_floor() or selected_box.bb_raycast.is_colliding():
					if selected_box.box_type != "Dirt":
						var new_box = BOX.instantiate()
						new_box.box_type_index = selected_box.box_type_index - 1
						new_box.position = selected_box.position + new_pos
						selected_box.box_type_index = selected_box.box_type_index - 1
						selected_space.global_position = new_box.position
						add_child(new_box)
						
			#COMBINE INTO ONE
			elif selected_box.transmute_raycast.is_colliding() and selected_box.is_sliding == false:
				print("Yep2")
				if selected_box.is_on_floor() or selected_box.bb_raycast.is_colliding():
					if selected_box.transmute_raycast.get_collider().is_in_group("Box"):
						var other_box = selected_box.transmute_raycast.get_collider()
						if selected_box.box_type == other_box.box_type and other_box.is_sliding == false: 
							var new_box = BOX.instantiate()
							new_box.box_type_index = selected_box.box_type_index + 1
							new_box.position = other_box.position
							print(new_box.box_type_index)
							selected_space.global_position = new_box.position
							add_child(new_box)
							other_box.queue_free()
							selected_box.queue_free()
							#selected_box = new_box
						else:
							print("different1")	
							selected_box = null
					else:
						print("cant push1")
						selected_box = null
		else:
			#STONE
			#SPLIT INTO TWO
			if !selected_box.transmute_raycast.is_colliding() and selected_box.is_sliding == false:
				print("Yep3")
				if selected_box.box_type != "Dirt":
					var new_box = BOX.instantiate()
					new_box.box_type_index = selected_box.box_type_index - 1
					new_box.position = selected_box.position + new_pos
					selected_box.box_type_index = selected_box.box_type_index - 1
					selected_space.global_position = new_box.position
					add_child(new_box)
					#selected_box = new_box
			#COMBINE INTO ONE
			elif selected_box.transmute_raycast.is_colliding() and selected_box.is_sliding == false:
				print("Yep4")
				if selected_box.transmute_raycast.get_collider().is_in_group("Box"):
					var other_box = selected_box.transmute_raycast.get_collider()
					if selected_box.box_type == other_box.box_type and other_box.is_sliding == false: 
						var new_box = BOX.instantiate()
						new_box.box_type_index = selected_box.box_type_index + 1
						new_box.position = other_box.position
						selected_space.global_position = new_box.position
						add_child(new_box)
						other_box.queue_free()
						selected_box.queue_free()
						#selected_box = new_box
					else:
						print("different2")
						selected_box = null
				else:
					print("cant push2")
					selected_box = null
	else:
		print("CANNOT PUSH EVER")







