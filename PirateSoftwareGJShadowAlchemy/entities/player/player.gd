extends CharacterBody2D
class_name Player


@export var reset_count : int = 0

@export var current_state : StringName
#Sprites stuff
@onready var sprite_base: Node2D = $SpriteBase
@onready var player_sprite: AnimatedSprite2D = $SpriteBase/PlayerSprite
@onready var staff_sprite: Sprite2D = $SpriteBase/StaffSprite
@onready var area_sprite: Sprite2D = $MaxTransmuteArea/AreaSprite

#Collisions
@onready var stand_shape: CollisionShape2D = $CollisionShape

#Camera stuff
@onready var camera: Camera2D = $Camera

#Raycast
@onready var push_ray_cast: RayCast2D = $PushRayCast
@onready var hat_ray_cast: RayCast2D = $HatRayCast
@onready var ladder_ray_up: RayCast2D = $LadderRaycasts/LadderRayUp
@onready var ladder_ray_down: RayCast2D = $LadderRaycasts/LadderRayDown
@onready var drop_through_raycast: RayCast2D = $DropThroughRaycast

#Areas
@onready var max_transmute_area: Area2D = $MaxTransmuteArea

#Particles
@onready var death_particles: CPUParticles2D = $DeathParticles


#Statemachine
@onready var msm: StateMachine = $MovementStateMachine

#Audio
@onready var footstep_audio: AudioStreamPlayer = $FootstepAudio
@onready var death_audio: AudioStreamPlayer = $DeathAudio
@onready var land_audio: AudioStreamPlayer = $LandAudio


signal can_transmute
signal cannot_transmute
signal death_audio_signal

#Player movement variables
@export var has_staff : bool = true
@export var can_ladder : bool = false
@export var on_ladder : bool = false

@export var move_speed : float = 130
@export var accel : float = 65
@export_range(0.0, 1.0) var deaccel : float = 0.5
@export var gravity : float = 20

@export var is_dead : bool = false
var can_play : bool = true
var can_push : bool = true
var direction : Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	reset_count = 0
	SceneTransition.transition_out()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	max_transmute_area.global_position = Vector2i(snappedi(global_position.x, 16), snappedi(global_position.y,16))
	check_push()
	if Input.is_action_pressed("reset"):
		print(reset_count)
		reset_count += 1
	else:
		reset_count = 0
		
	if reset_count >= 50:
		reset_count = 0
		SceneTransition.transition_in()
		#await(get_tree().create_timer(1).timeout)
		get_tree().reload_current_scene()

	
func _physics_process(delta: float) -> void:
	if is_dead == false:
		movement()
		handle_ladder()
		move_and_slide()
		if msm.state != get_node("MovementStateMachine/OnLadder"):
			apply_gravity()
	else:
		if not death_audio.is_playing() and can_play == true:
			can_play = false
			death_audio.play()
		death_particles.emitting = true
		sprite_base.hide()
		stand_shape.set_deferred("disabled", true)
		await(get_tree().create_timer(1).timeout)
		get_tree().reload_current_scene()
	
	if not hat_ray_cast.is_colliding():
		player_sprite.play(current_state)
	else:
		player_sprite.play(current_state+&"Under")
	if current_state == &"Fall":
		pass
		
func movement():
	if msm.state != get_node("MovementStateMachine/OnLadder"):
		if Input.is_action_pressed("right"):
			direction = Vector2.RIGHT
			player_sprite.flip_h = false
			staff_sprite.flip_h = false
			push_ray_cast.scale = Vector2.ONE
			staff_sprite.position.x = 7
			velocity.x = min(velocity.x + accel, move_speed)
		elif Input.is_action_pressed("left"):
			direction = Vector2.LEFT
			player_sprite.flip_h = true
			staff_sprite.flip_h = true
			push_ray_cast.scale = -Vector2.ONE
			staff_sprite.position.x = -7
			velocity.x = max(velocity.x - accel, -move_speed)
		else:
			velocity.x = lerpf(velocity.x, 0, deaccel)
	else:
		velocity.x = 0
		if Input.is_action_pressed("down"):
			velocity.y = min(velocity.y + accel, move_speed)
		elif Input.is_action_pressed("up"):
			velocity.y = max(velocity.y - accel, -move_speed)
		else:
			velocity.y = lerpf(velocity.y, 0, deaccel)
func apply_gravity():
	if not is_on_floor():
		velocity.y += gravity

func check_push():
		if push_ray_cast.is_colliding() and msm.state == get_node("MovementStateMachine/Push"):
			var box = push_ray_cast.get_collider()
			#await(get_tree().create_timer(1).timeout)
			if box != null:
				if Input.is_action_pressed("push"):
					box.push(direction)
		elif not push_ray_cast.is_colliding() and msm.state == get_node("MovementStateMachine/Push"):
			if Input.is_action_pressed("push"):
				pass
				

func handle_ladder():
	if ladder_ray_down.is_colliding() or ladder_ray_up.is_colliding():
		can_ladder = true
	else:
		can_ladder = false
		
	if can_ladder == true:
		if Input.is_action_pressed("up"):
			on_ladder = true
		if Input.is_action_pressed("down"):
			if drop_through_raycast.is_colliding() and velocity.y > 0:
				global_position.y += 16
				on_ladder = true
			else:
				on_ladder = true
				
	
func play_death_audio():
	print("play")
	death_audio.play()

func _on_max_transmute_area_area_entered(area: Area2D) -> void:
	can_transmute.emit()


func _on_max_transmute_area_area_exited(area: Area2D) -> void:
	cannot_transmute.emit()


func _on_death_area_body_entered(body: Node2D) -> void:
	is_dead = true


func _on_death_area_area_entered(area: Area2D) -> void:
	is_dead = true
