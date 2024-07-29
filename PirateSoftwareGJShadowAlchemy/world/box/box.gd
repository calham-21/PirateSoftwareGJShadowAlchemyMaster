extends CharacterBody2D


@onready var sprite: Sprite2D = $Sprite
@onready var raycast: RayCast2D = $RayCast
@onready var collision_shape: CollisionShape2D = $CollisionShape

@onready var transmute_raycast: RayCast2D = $TransmuteRaycast
@onready var extra_transmute_rays: Node2D = $ExtraTransmuteRays
@onready var tr_bl: RayCast2D = $ExtraTransmuteRays/TransmuteRaycastBL
@onready var tr_br: RayCast2D = $ExtraTransmuteRays/TransmuteRaycastBR
@onready var tr_tl: RayCast2D = $ExtraTransmuteRays/TransmuteRaycastTL
@onready var tr_tr: RayCast2D = $ExtraTransmuteRays/TransmuteRaycastTR


@onready var crush_area: Area2D = $CrushArea
@onready var crush_area_shape: CollisionShape2D = $CrushArea/Shape


@onready var bb_raycast: RayCast2D = $BoxBelowRayCast
@onready var terrain_raycast: RayCast2D = $TerrainRaycast
@onready var push_particles: CPUParticles2D = $PushParticles
@onready var player_raycast: RayCast2D = $PlayerRaycast
@onready var enemy_raycast: RayCast2D = $EnemyRaycast
@onready var falling_raycast: RayCast2D = $FallingRaycast


@onready var copper_ray: Node2D = $CopperRaycasts
@onready var cr_up: RayCast2D = $CopperRaycasts/ConductRaycastUp
@onready var cr_down: RayCast2D = $CopperRaycasts/ConductRaycastDown
@onready var cr_left: RayCast2D = $CopperRaycasts/ConductRaycastLeft
@onready var cr_right: RayCast2D = $CopperRaycasts/ConductRaycastRight


@onready var explosion_particles: CPUParticles2D = $ExplosionParticles
@onready var explosion_particles2: CPUParticles2D = $ExplosionParticles2
@onready var explosion_particles3: CPUParticles2D = $ExplosionParticles3
@onready var explosion_area: Area2D = $ExplosionArea
@onready var explosion_shape: CollisionShape2D = $ExplosionArea/ExplosionShape


@onready var push_audio: AudioStreamPlayer = $PushAudio
@onready var explosion_audio: AudioStreamPlayer2D = $ExplosionAudio
@onready var cant_push_audio: AudioStreamPlayer = $CantPushAudio
@onready var land_weak_audio: AudioStreamPlayer = $LandWeakAudio
@onready var land_strong_audio: AudioStreamPlayer = $LandStrongAudio


@export var grid_size : int = 32

var box_type_array : Array = ["Dirt", "Stone", "Copper", "Sodium", "Lead", "Gold"]
@export var box_type_index : int 
var box_type : String

#@export var can_conduct : bool = false
@export var is_conducting : bool = true
@export var touching_battery : bool = false

@export var sliding_time : float = 0.5
@export var is_sliding : bool
@export var gravity : float
@export var strong_gravity : float

var can_explode : bool = false
# Called when the node enters the scene tree for the first time.



func _ready() -> void:
	crush_area_shape.call_deferred("set_disabled", true)
	

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
			push_audio.play()
			#Tween to push to new direction. First tween I have done. Pretty cool.
			var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			tween.tween_property(self, "position:x", position.x + new_pos.x, sliding_time)
			#wait for tween to finish, then disable some stuff.
			await(tween.finished)
			push_particles.emitting = false
			is_sliding = false
			return true
		else:
			cant_push_audio.play()
			
	#STONE LOGIC.
	else:
		if !raycast.is_colliding() and is_sliding == false:
			push_particles.emitting = true
			is_sliding = true
			push_audio.play()
			var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			tween.tween_property(self, "position:x", position.x + new_pos.x, sliding_time)
			await(tween.finished)
			push_particles.emitting = false
			is_sliding = false
			return true
		else:
			cant_push_audio.play()
	return false

	

func _physics_process(delta: float) -> void:
	var is_landed : bool = false
	#If box is not stone, fall.
	if velocity.y > 0:
		crush_area.set_disable_mode(CollisionObject2D.DISABLE_MODE_REMOVE)
		crush_area_shape.call_deferred("set_disabled", false)
	else:
		
		crush_area.set_disable_mode(CollisionObject2D.DISABLE_MODE_KEEP_ACTIVE)
		crush_area_shape.call_deferred("set_disabled", true)
		
	if not is_on_floor():
		if falling_raycast.is_colliding():
			if is_landed == false:
				if not land_strong_audio.is_playing() or not land_weak_audio.is_playing():
					is_landed = true
					if box_type != "Lead" and box_type != "Stone":
						land_weak_audio.play()
					elif box_type == "Lead":
						land_strong_audio.play()
					#await(get_tree().create_timer(0.8).timeout)
					is_landed = false
		
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
		touching_battery = false
	elif box_type == "Stone":
		sliding_time = 0.25
		is_conducting = false
		touching_battery = false
	elif box_type == "Copper":
		#is_conducting = false
		sliding_time = 0.25
		copper_logic()
	elif box_type == "Sodium":
		is_conducting = false
		touching_battery = false
		sliding_time = 0.25
		sodium_logic()
		is_conducting = false
	elif box_type == "Lead":
		sliding_time = 0.25
		touching_battery = false
		is_conducting = false
	elif box_type == "Gold":
		sliding_time = 0.25
		touching_battery = false
		is_conducting = false
		
	if box_type != "Stone":
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
					return
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
				else:
					is_conducting = false
					
#---------------------------------------------------------------------------------------------------
	##BOX
	elif cr_down.is_colliding():
		var col = cr_down.get_collider()
		if col != null and col.is_in_group("Box"):
			if col.box_type == "Copper":
				if col.is_conducting == true:
					is_conducting = true
					return
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
				else:
					is_conducting = false
#---------------------------------------------------------------------------------------------------
	##BOX
	if cr_left.is_colliding():
		var col = cr_left.get_collider()
		if col != null and col.is_in_group("Box"):
			if col.box_type == "Copper":
				if col.is_conducting == true:
					is_conducting = true
					return
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
				else:
					is_conducting = false
#---------------------------------------------------------------------------------------------------
	##BOX
	elif cr_right.is_colliding():
		var col = cr_right.get_collider()
		if col != null and col.is_in_group("Box"):
			if col.box_type == "Copper":
				if col.is_conducting == true:
					is_conducting = true
					return
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
			else:
				is_conducting = false
	#----------------------------------------------------------------------------------------------------
func sodium_logic():
	if terrain_raycast.is_colliding() or can_explode == true:
		falling_raycast.enabled = false
		explosion_particles.emitting = true
		explosion_particles2.emitting = true
		explosion_particles3.emitting = true
		collision_shape.set_deferred("disabled", true)
		sprite.hide()
		for over_lap in explosion_area.get_overlapping_bodies():
			if over_lap != null:
				if over_lap.is_in_group("Box"):
					if over_lap.box_type == "Lead" and over_lap != self:
						pass
					elif over_lap.box_type == "Sodium" and over_lap != self:
						await(get_tree().create_timer(0.05).timeout)
						over_lap.can_explode = true
					else:
						if over_lap != self:
							over_lap.queue_free()
						
				elif over_lap.is_in_group("Player") or over_lap.is_in_group("Enemy"):
					over_lap.is_dead = true
		if explosion_particles2.emitting == false:
			queue_free()

func _on_crush_area_body_entered(body: Node2D) -> void:
	body.is_dead = true
