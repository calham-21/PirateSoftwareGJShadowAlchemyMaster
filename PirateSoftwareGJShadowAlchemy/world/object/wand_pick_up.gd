extends Node2D

@onready var pickup_audio: AudioStreamPlayer = $PickupAudio
@onready var wand_sprite: Sprite2D = $WandSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_wand_area_body_entered(body: Node2D) -> void:
	pickup_audio.play()
	if body.is_in_group("Player"):
		body.has_staff = true
		wand_sprite.hide()
		await(get_tree().create_timer(0.2).timeout)
		queue_free()
