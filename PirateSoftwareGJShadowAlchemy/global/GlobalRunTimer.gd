extends Node2D

var speedrun_time : float
var formatted_time : String
var stop_time : bool = false
func _physics_process(delta: float) -> void:
	if stop_time == false:
		speedrun_time = float(speedrun_time) + delta
		update_ui()
	
func update_ui():
	var formatted_time = str(speedrun_time)
	var decimal_index = formatted_time.find(".")
	
	if decimal_index > 0:
		formatted_time = formatted_time.left(decimal_index + 3)
	speedrun_time = float(formatted_time)
