extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var shape: CollisionShape2D = $Shape
@onready var death_particles: CPUParticles2D = $DeathParticles
@onready var face_fire_particles: CPUParticles2D = $FaceFireParticles

@onready var death_area: Area2D = $DeathArea
@onready var death_shape: CollisionShape2D = $DeathArea/DeathShape
@onready var box_raycast: RayCast2D = $BoxRaycast

@onready var crush_ray: RayCast2D = $CrushRay
@onready var crush_ray2: RayCast2D = $CrushRay2

@export var is_facing_left : bool = false
var is_dead : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_facing_left == true:
		face_fire_particles.gravity.x = -55
	else:
		face_fire_particles.gravity.x = 55
	sprite.play("Idle")
	
	if crush_ray.is_colliding() and crush_ray2.is_colliding():
		is_dead = true
	
	if box_raycast.is_colliding():
		death_shape.set_deferred("disabled", true)
		face_fire_particles.z_index = -1
		face_fire_particles.lifetime = 1.25
		
	else:
		death_shape.set_deferred("disabled", false)
		face_fire_particles.z_index = 5
		face_fire_particles.lifetime = 1.5
		
	if is_dead == true:
		death_particles.emitting = true
		face_fire_particles.emitting = false
		sprite.hide()
		shape.set_deferred("disabled", true)
		death_shape.set_deferred("disabled", true)
		if death_particles.emitting == false:
			queue_free()
	
			
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += 20
	move_and_slide()


func _on_death_area_body_entered(body: Node2D) -> void:
	body.is_dead = true
