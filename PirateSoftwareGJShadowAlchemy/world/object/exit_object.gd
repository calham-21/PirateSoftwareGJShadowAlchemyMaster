extends Node2D
signal can_win_signal
signal has_won_signal
@export var can_win : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_exit_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Box"):
		if body.box_type == "Gold":
			can_win_signal.emit()
			body.queue_free()
	if can_win == true:
		if body.is_in_group("Player"):
			has_won_signal.emit()
			body.hide()
