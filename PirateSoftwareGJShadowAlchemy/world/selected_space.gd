extends Area2D

signal selected_space_enter
signal selected_space_exit
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("Box"):
			selected_space_enter.emit(body)

func _on_body_entered(body: Node2D) -> void:
	selected_space_enter.emit(body)


func _on_body_exited(body: Node2D) -> void:
	selected_space_exit.emit()
