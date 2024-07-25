extends Node2D

@onready var flame_jet_sprite: Sprite2D = $FlameJetSprite
@onready var detection_raycasts: Node2D = $DetectionRaycasts
@onready var flame_particles: CPUParticles2D = $FlameParticles


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for ray in detection_raycasts.get_children():
		if ray.is_colliding():
			var col = ray.get_collider()
			if col.is_conducting == true:
				flame_particles.emitting = true
			else:
				flame_particles.emitting = false
