extends Node2D

@onready var player: Player = $Player
@onready var tile_map: TileMap = $TileMap

@export var can_win : bool = false


@export var grid_size : int = 32
const BOX = preload("res://world/box/box.tscn")

@export var selected_box : Node
@export var temp_box : Node
@onready var selected_space: Sprite2D = $SelectedSpace
@onready var selected_space_area: Area2D = $SelectedSpace/SelectedSpaceArea
@onready var collision_shape: CollisionShape2D = $SelectedSpace/SelectedSpaceArea/CollisionShape

var can_select: bool = true

func _process(delta: float) -> void:
	#if can_select:
		#can_select = false
		#selected_space.frame = 3 
	#else:
		#can_select = true
		#selected_space.frame = 1
		
	if temp_box != null:
		if Input.is_action_just_pressed("interact"):
			selected_space.frame = 0
			selected_box = temp_box
			temp_box = null
			
	if selected_box != null:
		if Input.is_action_just_pressed("cancel"):
			selected_space.frame = 1
			selected_box = null
			
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
	var new_pos = vel_norm * grid_size
	selected_box.transmute_raycast.target_position = new_pos
	selected_box.transmute_raycast.force_raycast_update()
	if selected_box.box_type != "Stone":
		#NOT STONE SPECIFIC
		#SPLIT INTO TWO
		if !selected_box.transmute_raycast.is_colliding() and selected_box.is_sliding == false:
			if selected_box.is_on_floor() or selected_box.bb_raycast.is_colliding():
				if selected_box.box_type != "Dirt":
					var new_box = BOX.instantiate()
					new_box.box_type_index = selected_box.box_type_index - 1
					new_box.position = selected_box.position + new_pos
					selected_box.box_type_index = selected_box.box_type_index - 1
					selected_space.global_position = new_box.position
					add_child(new_box)
					selected_box = new_box
		else:
			selected_space.frame = 3
					
		#COMBINE INTO ONE
		if selected_box.transmute_raycast.is_colliding() and selected_box.is_sliding == false:
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
						selected_box = new_box

				else:
					print("different")
		else:
			pass
	else:
		#STONE
		#SPLIT INTO TWO
		if !selected_box.transmute_raycast.is_colliding() and selected_box.is_sliding == false:
			if selected_box.box_type != "Dirt":
				print("Nop")
				var new_box = BOX.instantiate()
				new_box.box_type_index = selected_box.box_type_index - 1
				new_box.position = selected_box.position + new_pos
				selected_box.box_type_index = selected_box.box_type_index - 1
				selected_space.global_position = new_box.position
				add_child(new_box)
				selected_box = new_box
		else:
			selected_space.frame = 3
		#COMBINE INTO ONE
		if selected_box.transmute_raycast.is_colliding() and selected_box.is_sliding == false:
			if selected_box.transmute_raycast.get_collider().is_in_group("Box"):
				var other_box = selected_box.transmute_raycast.get_collider()
				if selected_box.box_type == other_box.box_type and other_box.is_sliding == false: 
					print("Yep")
					var new_box = BOX.instantiate()
					new_box.box_type_index = selected_box.box_type_index + 1
					new_box.position = other_box.position
					selected_space.global_position = new_box.position
					add_child(new_box)
					other_box.queue_free()
					selected_box.queue_free()
					selected_box = new_box
				else:
					print("different2")
		else:
			pass


func _on_selected_space_area_body_entered(body: Node2D) -> void:
	selected_space.frame = 2
	temp_box = body


func _on_selected_space_area_body_exited(body: Node2D) -> void:
	selected_space.frame = 1
	temp_box = null
	selected_box = null


func _on_exit_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Box"):
		if body.box_type == "Gold":
			can_win = true
			body.queue_free()
	if can_win == true:
		if body.is_in_group("Player"):
			print("win!")
			body.queue_free()


