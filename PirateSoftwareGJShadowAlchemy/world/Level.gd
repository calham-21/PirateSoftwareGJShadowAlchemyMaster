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
@onready var selected_space: CharacterBody2D = $SelectedSpace
@onready var selected_space_sprite: Sprite2D = $SelectedSpace/SelectedSpaceSprite
@onready var collision_shape: CollisionShape2D = $SelectedSpace/SelectedSpaceArea/CollisionShape
@onready var exit: Node2D = $Exit
var can_shake : bool = false

var can_select: bool = true
var can_transmute : bool = false

var reset_count : int = 0


@export var is_tutorial : bool = false
@onready var arrow_key_tutorial: Sprite2D = $ArrowKeyTutorial
@onready var wasd_key_tutorial: Sprite2D = $WASDKeyTutorial
@onready var e_key_tutorial: Sprite2D = $EKeyTutorial
@onready var space_key_tutorial: Sprite2D = $SpaceKeyTutorial

signal wasd_tut
signal arrow_tut
signal space_tut
signal e_tut


func can_win_handler():
	exit.can_win = true
	print("player can now win")
	
func win_handler():
	has_won = true
	SceneTransition.transition_in()
	await(get_tree().create_timer(1).timeout)
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


func tutorial_sequence():
	if Input.is_action_pressed("left") or Input.is_action_pressed("right")\
	or Input.is_action_pressed("up") or Input.is_action_pressed("down"):
		var tween = create_tween().set_parallel(false)
		tween.tween_property(wasd_key_tutorial, "modulate", Color(0, 0, 0, 0), 1.5).from_current()
	if player.has_staff:
		if selected_box == null:
			if Input.is_action_pressed("arrow_left") or Input.is_action_pressed("arrow_right")\
			or Input.is_action_pressed("arrow_up") or Input.is_action_pressed("arrow_down"):
				var tween = create_tween().set_parallel(false)
				tween.tween_property(arrow_key_tutorial, "modulate", Color(0, 0, 0, 0), 1.5).from_current()
		else:
			if Input.is_action_pressed("arrow_left") or Input.is_action_pressed("arrow_right")\
			or Input.is_action_pressed("arrow_up") or Input.is_action_pressed("arrow_down"):
				var tween = create_tween().set_parallel(false)
				tween.tween_property(e_key_tutorial, "modulate", Color(0, 0, 0, 0), 1.5).from_current()
			


func _process(delta: float) -> void:
	if is_tutorial == true:
		tutorial_sequence()
		
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
	if can_shake:
		selected_space_sprite.frame = 3
	else:
		pass
	if can_transmute and temp_box == null and can_shake == false:
		selected_space_sprite.frame = 0
		player.staff_sprite.frame = 1
	elif can_transmute and temp_box != null and can_shake == false:
		selected_space_sprite.frame = 1
		player.staff_sprite.frame = 2
	elif can_transmute == false and temp_box == null:
		selected_space_sprite.frame = 3
		player.staff_sprite.frame = 4
		selected_box = null
	elif can_transmute == false and temp_box != null:
		selected_space_sprite.frame = 3
		player.staff_sprite.frame = 4
		
	if temp_box != null and can_transmute:
			if Input.is_action_just_pressed("interact"):
				selected_space_sprite.frame = 0
				player.staff_sprite.frame = 1
				selected_box = temp_box
				temp_box = null
	elif temp_box == null and !can_transmute:
		if Input.is_action_just_pressed("interact") and can_shake == false:
			can_shake = true
			selected_space_sprite.frame = 3
			player.staff_sprite.frame = 4
			var current_pos = selected_space_sprite.position
			var tween = create_tween().set_parallel(false).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			tween.tween_property(selected_space_sprite, "position", selected_space_sprite.position - Vector2(5, 0),0.05).set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(selected_space_sprite, "position", selected_space_sprite.position + Vector2(5, 0),0.05).set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(selected_space_sprite, "position", current_pos, 0.1).set_trans(Tween.TRANS_BOUNCE)
			await(tween.finished)
			can_shake = false
	elif temp_box != null and !can_transmute:
		if Input.is_action_just_pressed("interact") and can_shake == false:
			can_shake = true
			selected_space_sprite.frame = 3
			player.staff_sprite.frame = 4
			var current_pos = selected_space_sprite.position
			var tween = create_tween().set_parallel(false).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			tween.tween_property(selected_space_sprite, "position", selected_space_sprite.position - Vector2(5, 0),0.05).set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(selected_space_sprite, "position", selected_space_sprite.position + Vector2(5, 0),0.05).set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(selected_space_sprite, "position", current_pos, 0.1).set_trans(Tween.TRANS_BOUNCE)
			await(tween.finished)
			can_shake = false
			
	if selected_box != null and can_shake == false:
		if Input.is_action_just_pressed("cancel"):
			selected_space_sprite.frame = 1
			player.staff_sprite.frame = 2
			selected_box = null
		if can_transmute:
			selected_space_sprite.frame = 2
			player.staff_sprite.frame = 3
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
			selected_space.move(Vector2.LEFT)
		if Input.is_action_just_pressed("arrow_right"):
			selected_space.move(Vector2.RIGHT)
		if Input.is_action_just_pressed("arrow_up"):
			selected_space.move(Vector2.UP)
		if Input.is_action_just_pressed("arrow_down"):
			selected_space.move(Vector2.DOWN)
			
	if selected_space == null and can_transmute == false:
		if Input.is_action_just_pressed("interact") and can_shake == false:
			can_shake = true
			selected_space_sprite.frame = 1
			player.staff_sprite.frame = 4
			var current_pos = selected_space_sprite.position
			var tween = create_tween().set_parallel(false).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			tween.tween_property(selected_space_sprite, "position", selected_space_sprite.position - Vector2(5, 0),0.05).set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(selected_space_sprite, "position", selected_space_sprite.position + Vector2(5, 0),0.05).set_trans(Tween.TRANS_BOUNCE)
			tween.tween_property(selected_space_sprite, "position", current_pos, 0.1).set_trans(Tween.TRANS_BOUNCE)
			await(tween.finished)
			can_shake = false


func transmute(vel: Vector2):
	var vel_norm = vel.normalized()
	print(vel_norm)
	var new_pos = vel_norm * grid_size
	selected_box.transmute_raycast.target_position = new_pos*1.48
	selected_box.transmute_raycast.force_raycast_update()
		
	#for t_ray in selected_box.extra_transmute_rays.get_children():
		#if t_ray.is_colliding():
			#return false
			
	if selected_box.tr_tr.is_colliding() or selected_box.tr_tl.is_colliding():
		if vel_norm == Vector2(0, -1):
			print("cant push up cause on top")
			if can_shake == false:
				can_shake = true
				selected_space_sprite.frame = 3
				player.staff_sprite.frame = 4
				#selected_box = null
				var current_pos = selected_space_sprite.position
				var tween = create_tween().set_parallel(false).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
				tween.tween_property(selected_space_sprite, "position", selected_space_sprite.position - Vector2(5, 0),0.05).set_trans(Tween.TRANS_BOUNCE)
				tween.tween_property(selected_space_sprite, "position", selected_space_sprite.position + Vector2(5, 0),0.05).set_trans(Tween.TRANS_BOUNCE)
				tween.tween_property(selected_space_sprite, "position", current_pos, 0.1).set_trans(Tween.TRANS_BOUNCE)
				await(tween.finished)
				can_shake = false
				return
	if selected_box.tr_br.is_colliding() or selected_box.tr_bl.is_colliding():
		if vel_norm == Vector2(0, 1):
			print("cant push down cause beneath")
			if can_shake == false:
				can_shake = true
				selected_space_sprite.frame = 3
				player.staff_sprite.frame = 4
				#selected_box = null
				var current_pos = selected_space_sprite.position
				var tween = create_tween().set_parallel(false).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
				tween.tween_property(selected_space_sprite, "position", selected_space_sprite.position - Vector2(5, 0),0.05).set_trans(Tween.TRANS_BOUNCE)
				tween.tween_property(selected_space_sprite, "position", selected_space_sprite.position + Vector2(5, 0),0.05).set_trans(Tween.TRANS_BOUNCE)
				tween.tween_property(selected_space_sprite, "position", current_pos, 0.1).set_trans(Tween.TRANS_BOUNCE)
				await(tween.finished)
				can_shake = false
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
					else:
						selected_space_sprite.frame = 3
						player.staff_sprite.frame = 4
						var current_pos = selected_space_sprite.position
						var tween = create_tween().set_parallel(false).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
						tween.tween_property(selected_space_sprite, "position", selected_space_sprite.position - Vector2(5, 0),0.05).set_trans(Tween.TRANS_BOUNCE)
						tween.tween_property(selected_space_sprite, "position", selected_space_sprite.position + Vector2(5, 0),0.05).set_trans(Tween.TRANS_BOUNCE)
						tween.tween_property(selected_space_sprite, "position", current_pos, 0.1).set_trans(Tween.TRANS_BOUNCE)
						await(tween.finished)
						
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
							if can_shake == false:
								can_shake = true
								selected_space_sprite.frame = 3
								player.staff_sprite.frame = 4
								#selected_box = null
								var current_pos = selected_space_sprite.position
								var tween = create_tween().set_parallel(false).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
								tween.tween_property(selected_space_sprite, "position", selected_space_sprite.position - Vector2(5, 0),0.05).set_trans(Tween.TRANS_BOUNCE)
								tween.tween_property(selected_space_sprite, "position", selected_space_sprite.position + Vector2(5, 0),0.05).set_trans(Tween.TRANS_BOUNCE)
								tween.tween_property(selected_space_sprite, "position", current_pos, 0.1).set_trans(Tween.TRANS_BOUNCE)
								await(tween.finished)
								can_shake = false
					else:
						if can_shake == false:
							can_shake = true
							selected_space_sprite.frame = 3
							player.staff_sprite.frame = 4
							selected_box = null
							var current_pos = selected_space_sprite.position
							var tween = create_tween().set_parallel(false).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
							tween.tween_property(selected_space_sprite, "position", selected_space_sprite.position - Vector2(5, 0),0.05).set_trans(Tween.TRANS_BOUNCE)
							tween.tween_property(selected_space_sprite, "position", selected_space_sprite.position + Vector2(5, 0),0.05).set_trans(Tween.TRANS_BOUNCE)
							tween.tween_property(selected_space_sprite, "position", current_pos, 0.1).set_trans(Tween.TRANS_BOUNCE)
							await(tween.finished)
							can_shake = false
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
						if can_shake == false:
							can_shake = true
							selected_space_sprite.frame = 3
							player.staff_sprite.frame = 4
							#selected_box = null
							var current_pos = selected_space_sprite.position
							var tween = create_tween().set_parallel(false).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
							tween.tween_property(selected_space_sprite, "position", selected_space_sprite.position - Vector2(5, 0),0.05).set_trans(Tween.TRANS_BOUNCE)
							tween.tween_property(selected_space_sprite, "position", selected_space_sprite.position + Vector2(5, 0),0.05).set_trans(Tween.TRANS_BOUNCE)
							tween.tween_property(selected_space_sprite, "position", current_pos, 0.1).set_trans(Tween.TRANS_BOUNCE)
							await(tween.finished)
							can_shake = false
				else: #Cant push
					if can_shake == false:
						can_shake = true
						selected_space_sprite.frame = 3
						player.staff_sprite.frame = 4
						#selected_box = null
						var current_pos = selected_space_sprite.position
						var tween = create_tween().set_parallel(false).set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
						tween.tween_property(selected_space_sprite, "position", selected_space_sprite.position - Vector2(5, 0),0.05).set_trans(Tween.TRANS_BOUNCE)
						tween.tween_property(selected_space_sprite, "position", selected_space_sprite.position + Vector2(5, 0),0.05).set_trans(Tween.TRANS_BOUNCE)
						tween.tween_property(selected_space_sprite, "position", current_pos, 0.1).set_trans(Tween.TRANS_BOUNCE)
						await(tween.finished)
						can_shake = false
	else:
		print("CANNOT PUSH EVER")









func _on_space_key_area_body_entered(body: Node2D) -> void:
	$SpaceKeyArea.set_disable_mode(CollisionObject2D.DISABLE_MODE_REMOVE)
	$SpaceKeyArea/Shape.call_deferred("set_disabled", true)
	var tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(space_key_tutorial, "modulate", Color(1, 1, 1, 1), 1.5).from_current()

func _on_space_key_area_2_body_entered(body: Node2D) -> void:
	$SpaceKeyArea2.set_disable_mode(CollisionObject2D.DISABLE_MODE_REMOVE)
	$SpaceKeyArea2/Shape.call_deferred("set_disabled", true)
	var tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(space_key_tutorial, "modulate", Color(0, 0, 0, 0), 1.5).from_current()

func _on_arrow_key_tut_body_entered(body: Node2D) -> void:
	$ArrowKeyArea.set_disable_mode(CollisionObject2D.DISABLE_MODE_REMOVE)
	$ArrowKeyArea/Shape.call_deferred("set_disabled", true)
	var tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(arrow_key_tutorial, "modulate", Color(1, 1, 1, 1), 1.5).from_current()

func _on_arrow_key_tut_2_area_entered(area: Area2D) -> void:
	$ArrowKeyArea2.set_disable_mode(CollisionObject2D.DISABLE_MODE_REMOVE)
	$ArrowKeyArea2/Shape.call_deferred("set_disabled", true)
	var tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_parallel(false)
	tween.tween_property(e_key_tutorial, "modulate", Color(1, 1, 1, 1), 1.5).from_current()
