extends CharacterBody2D


@onready var sprite: Sprite2D = $Sprite
@onready var raycast: RayCast2D = $RayCast
@onready var transmute_raycast: RayCast2D = $TransmuteRaycast
@onready var bb_raycast: RayCast2D = $BoxBelowRayCast
@onready var terrain_raycast: RayCast2D = $TerrainRaycast
@onready var push_particles: CPUParticles2D = $PushParticles
@onready var player_raycast: RayCast2D = $PlayerRaycast

@onready var cr_up: RayCast2D = $CopperRaycasts/ConductRaycastUp
@onready var cr_down: RayCast2D = $CopperRaycasts/ConductRaycastDown
@onready var cr_left: RayCast2D = $CopperRaycasts/ConductRaycastLeft
@onready var cr_right: RayCast2D = $CopperRaycasts/ConductRaycastRight



@export var grid_size : int = 32

var box_type_array : Array = ["Dirt", "Stone", "Copper", "Sodium", "Lead", "Gold"]
@export var box_type_index : int 
var box_type : String

#@export var can_conduct : bool = false
@export var is_conducting : bool = true

@export var sliding_time : float = 0.5
@export var is_sliding : bool
@export var gravity : float
@export var strong_gravity : float


# Called when the node enters the scene tree for the first time.



func _ready() -> void:
	print(box_type)
	

func _process(delta: float) -> void:
	box_type = box_type_array[box_type_index]
	if is_conducting == true:
		sprite.frame = 10
	else:
		sprite.frame = box_type_index
	
	

func push(vel: Vector2) -> bool:
	#Push logic. Gets velocity and normalises it to get direction.
	#Times that dir with grid size to find the new position the box will be pushed too.
	var vel_norm = vel.normalized()
	var new_pos = vel_norm * grid_size
	#Raycast that points at the new posiition.
	raycast.target_position = new_pos
	#Forces raycast to update to check if new pos is empty.
	raycast.force_raycast_update()
	
	#NON-STONE LOGIC
	if box_type != "Stone":
		#if that new pos is free, and the box is not sliding and is on the floor, it can be pushed.
		#Previous if check is to see if stone or not. Since stone floats, is_on_floor causes the stone
		#to be unpushable in air.
		if !raycast.is_colliding() and is_sliding == false and is_on_floor():
			push_particles.emitting = true
			is_sliding = true
			#Tween to push to new direction. First tween I have done. Pretty cool.
			var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			tween.tween_property(self, "position:x", position.x + new_pos.x, sliding_time)
			#wait for tween to finish, then disable some stuff.
			await(tween.finished)
			push_particles.emitting = false
			is_sliding = false
			return true
	#STONE LOGIC.
	else:
		if !raycast.is_colliding() and is_sliding == false:
			push_particles.emitting = true
			is_sliding = true
			var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			tween.tween_property(self, "position:x", position.x + new_pos.x, sliding_time)
			await(tween.finished)
			push_particles.emitting = false
			is_sliding = false
			return true
	return false

	

func _physics_process(delta: float) -> void:
	#If box is not stone, fall.
	if box_type == "Dirt" or box_type == "Copper" or box_type == "Sodium" or box_type == "Gold":
		velocity.y += gravity
	elif box_type == "Lead": #Fall stronger for lead
		velocity.y += strong_gravity
	else:
		velocity.y = 0
	
	#Check box type. Originally sliding time was different for
	#each box type. That sucked so keep the same.
	#Handles box logic based on box type
	if box_type == "Dirt":
		sliding_time = 0.25
		is_conducting = false
	elif box_type == "Stone":
		sliding_time = 0.25
		is_conducting = false
	elif box_type == "Copper":
		sliding_time = 0.25
		copper_logic()
	elif box_type == "Sodium":
		sliding_time = 0.25
		sodium_logic()
		is_conducting = false
	elif box_type == "Lead":
		sliding_time = 0.25
		is_conducting = false
	elif box_type == "Gold":
		sliding_time = 0.25
		is_conducting = false
		
	move_and_slide()

func copper_logic():
	#Evil code. Beware.
	##BOX
	if cr_up.is_colliding():
		var col = cr_up.get_collider()
		if col != null and col.is_in_group("Box"):
			if col.box_type == "Copper":
				if col.is_conducting == true:
					is_conducting = true
				else:
					is_conducting = false
			else:
				is_conducting = false
		##TILEMAP
		elif col != null and col.is_in_group("TileMap"):
			var tile =  col.get_cell_tile_data(0, col.local_to_map(cr_up.get_collision_point()))
			if tile:
				var conduct_data = tile.get_custom_data("is_conducting")
				if conduct_data == true:
					is_conducting = true
					
#---------------------------------------------------------------------------------------------------
	##BOX
	if cr_down.is_colliding():
		var col = cr_down.get_collider()
		if col != null and col.is_in_group("Box"):
			if col.box_type == "Copper":
				if col.is_conducting == true:
					is_conducting = true
				else:
					is_conducting = false
			else:
				is_conducting = false
		##TILEMAP
		elif col != null and col.is_in_group("TileMap"):
			var tile =  col.get_cell_tile_data(0, col.local_to_map(cr_down.get_collision_point()))
			if tile:
				var conduct_data = tile.get_custom_data("is_conducting")
				if conduct_data == true:
					is_conducting = true
#---------------------------------------------------------------------------------------------------
	##BOX
	if cr_left.is_colliding():
		var col = cr_left.get_collider()
		if col != null and col.is_in_group("Box"):
			if col.box_type == "Copper":
				if col.is_conducting == true:
					is_conducting = true
				else:
					is_conducting = false
			else:
				is_conducting = false
					
		##TILEMAP
		elif col != null and col.is_in_group("TileMap"):
			var tile =  col.get_cell_tile_data(0, col.local_to_map(cr_left.get_collision_point()))
			if tile:
				var conduct_data = tile.get_custom_data("is_conducting")
				if conduct_data == true:
					is_conducting = true
			
#---------------------------------------------------------------------------------------------------
	##BOX
	if cr_right.is_colliding():
		var col = cr_right.get_collider()
		if col != null and col.is_in_group("Box"):
			if col.box_type == "Copper":
				if col.is_conducting == true:
					is_conducting = true
				else:
					is_conducting = false
			else:
				is_conducting = false
		##TILEMAP
		elif col != null and col.is_in_group("TileMap"):
			var tile = col.get_cell_tile_data(0, col.local_to_map(cr_right.get_collision_point()))
			if tile:
				var conduct_data = tile.get_custom_data("is_conducting")
				if conduct_data == true:
					is_conducting = true

#---------------------------------------------------------------------------------------------------
func sodium_logic():
	if terrain_raycast.is_colliding():
		print("explode")
		queue_free()
