extends Label

func _physics_process(delta: float) -> void:
	text = str(GlobalRunTimer.speedrun_time)
