extends Node2D

@onready var can_transmute_audio: AudioStreamPlayer = $TransmuteAudio
@onready var cant_transmute_audio: AudioStreamPlayer = $CantTransmuteAudio

@onready var can_select_audio: AudioStreamPlayer = $CanSelectAudio
@onready var cant_select_audio: AudioStreamPlayer = $CantSelectAudio

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
