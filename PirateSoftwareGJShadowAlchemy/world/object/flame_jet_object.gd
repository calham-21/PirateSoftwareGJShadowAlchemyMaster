extends Node2D

@onready var flame_jet_sprite: Sprite2D = $FlameJetSprite
@onready var detection_raycasts: Node2D = $DetectionRaycasts
@onready var flame_particles: CPUParticles2D = $FlameParticles
@onready var death_area: Area2D = $DeathArea
@onready var death_area_shape: CollisionShape2D = $DeathArea/Shape


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	death_area_shape.set_deferred("disabled", false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for ray in detection_raycasts.get_children():
		if ray.is_colliding():
			var col = ray.get_collider()
			if col.is_conducting == true:
				flame_particles.emitting = true
				death_area_shape.set_deferred("disabled", false)
			else:
				flame_particles.emitting = false
				death_area_shape.set_deferred("disabled", true)
				
				


func _on_death_area_body_entered(body: Node2D) -> void:
	body.is_dead = true
