extends PlayerState
func enter(_msg := {}) -> void:
	player.current_state = &"Push"
func update(_delta: float) -> void:
	pass
func physics_update(_delta: float) -> void:
	if not player.is_on_wall():
		state_machine.transition_to("Run")
		
func exit() -> void:
	pass

