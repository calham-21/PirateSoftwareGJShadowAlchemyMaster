extends CharacterBody2D
#Sprites stuff
@onready var sprite_base: Node2D = $SpriteBase
@onready var player_sprite: AnimatedSprite2D = $SpriteBase/PlayerSprite
@onready var staff_sprite: AnimatedSprite2D = $SpriteBase/StaffSprite

#Collisions
@onready var stand_shape: CollisionShape2D = $CollisionShape

#Camera stuff
@onready var camera: Camera2D = $Camera

#Player movement variables
@export var move_speed : float = 0.0
@export var accel : float = 0.0
@export_range(0.0, 1.0) var deaccel : float = 0.0

@export var gravity : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	apply_gravity()
	movement()
	move_and_slide()
	
func movement():
	if Input.is_action_pressed("right"):
		player_sprite.flip_h = false
		velocity.x = min(velocity.x + accel, move_speed)
	elif Input.is_action_pressed("left"):
		player_sprite.flip_h = true
		velocity.x = max(velocity.x - accel, -move_speed)
	else:
		velocity.x = lerpf(velocity.x, 0, deaccel)
	
func apply_gravity():
	if not is_on_floor():
		velocity.y += gravity

func handle_animation():
	#Nothing fancy, just quick if checks
	if velocity == Vector2.ZERO:
		player_sprite.play("Idle")
		print("Idle")
		
	if velocity.x != 0 and velocity.y == 0:
		player_sprite.play("Run")
		print("Run")
		
	if  velocity.x == 0 or velocity.x != 0 and velocity.y != 0:
		player_sprite.play("Fall")
