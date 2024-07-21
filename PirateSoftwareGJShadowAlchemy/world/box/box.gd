extends CharacterBody2D


@onready var sprite: Sprite2D = $Sprite
@onready var raycast: RayCast2D = $RayCast
@onready var transmute_raycast: RayCast2D = $TransmuteRaycast
@onready var bb_raycast: RayCast2D = $BoxBelowRayCast
@onready var terrain_raycast: RayCast2D = $TerrainRaycast
@onready var push_particles: CPUParticles2D = $PushParticles


@export var grid_size : int = 32

var box_type_array : Array = ["Dirt", "Stone", "Copper", "Sodium", "Lead", "Gold"]
@export var box_type_index : int 
var box_type : String



@export var sliding_time : float = 0.5
@export var is_sliding : bool
@export var gravity : float
@export var strong_gravity : float


# Called when the node enters the scene tree for the first time.



func _ready() -> void:
	print(box_type)
	

func _process(delta: float) -> void:
	box_type = box_type_array[box_type_index]
	sprite.frame = box_type_index
	
	

func push(vel: Vector2) -> bool:
	#print(global_position)
	var vel_norm = vel.normalized()
	var new_pos = vel_norm * grid_size
	raycast.target_position = new_pos
	raycast.force_raycast_update()
	if box_type != "Stone":
		if !raycast.is_colliding() and is_sliding == false and is_on_floor():
			push_particles.emitting = true
			#position += new_pos
			#print(position, new_pos)
			is_sliding = true
			var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			tween.tween_property(self, "position:x", position.x + new_pos.x, sliding_time)
			await(tween.finished)
			push_particles.emitting = false
			is_sliding = false
		#	print(position.x, new_pos.x)
			return true
	else:
		if !raycast.is_colliding() and is_sliding == false:
			push_particles.emitting = true
			#position += new_pos
			#print(position, new_pos)
			is_sliding = true
			var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			tween.tween_property(self, "position:x", position.x + new_pos.x, sliding_time)
			await(tween.finished)
			push_particles.emitting = false
			is_sliding = false
		#	print(position.x, new_pos.x)
			return true
	return false

	

func _physics_process(delta: float) -> void:
	if box_type == "Dirt" or box_type == "Copper" or box_type == "Sodium" or box_type == "Gold":
		velocity.y += gravity
	elif box_type == "Lead":
		velocity.y += strong_gravity
	else:
		velocity.y = 0
	
	if box_type == "Dirt":
		sliding_time = 0.25
	elif box_type == "Stone":
		sliding_time = 0.25
	elif box_type == "Cooper":
		sliding_time = 0.25
		copper_logic()
	elif box_type == "Sodium":
		sliding_time = 0.25
		sodium_logic()
	elif box_type == "Lead":
		sliding_time = 0.25
	elif box_type == "Gold":
		sliding_time = 0.25
		
	move_and_slide()

func copper_logic():
	pass


func sodium_logic():
	if terrain_raycast.is_colliding():
		print("explode")
		queue_free()
