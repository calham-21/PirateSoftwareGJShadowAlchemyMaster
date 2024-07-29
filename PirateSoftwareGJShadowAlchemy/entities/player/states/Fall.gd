extends PlayerState
var can_play : bool = true
func enter(_msg := {}) -> void:
	can_play = true
	player.current_state = &"Fall"
func update(_delta: float) -> void:
	pass
func physics_update(_delta: float) -> void:
	if player.on_ladder == true:
		state_machine.transition_to("OnLadder")
	
	if player.is_on_floor():
		if can_play == true:
			can_play = false
			player.land_audio.play()
		var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tween.set_parallel(true)
		tween.set_ease(tween.EASE_IN)
		tween.tween_property(self, "player:player_sprite:scale:y",  0.854, 0.065)
		tween.tween_property(self, "player:player_sprite:position:y", 3.5, 0.065)
		await(tween.finished)
		player.current_state = &"Land"
		await(get_tree().create_timer(0.15).timeout)
		if player.on_ladder == true:
			state_machine.transition_to("OnLadder")
		else:
			pass
		if player.velocity.x == 0:
			state_machine.transition_to("Idle")
		else:
			state_machine.transition_to("Run")
			


func exit() -> void:
	pass
