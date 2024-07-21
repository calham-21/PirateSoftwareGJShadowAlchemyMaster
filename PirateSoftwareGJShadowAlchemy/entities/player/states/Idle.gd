extends PlayerState
func enter(_msg := {}) -> void:
	player.current_state = &"Idle"
	var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_parallel(true)
	tween.set_ease(tween.EASE_OUT)
	tween.tween_property(self, "player:player_sprite:scale:y",  1, 0.09)
	tween.tween_property(self, "player:player_sprite:position:y",  0, 0.09)
	
func update(_delta: float) -> void:
	pass
func physics_update(_delta: float) -> void:
	if player.velocity.y > 0:
		state_machine.transition_to("Fall")
		
	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		state_machine.transition_to("Run")
		
	if player.on_ladder == true:
		state_machine.transition_to("OnLadder")
	
	if player.is_on_wall():
		state_machine.transition_to("Push")
		
func exit() -> void:
	pass
