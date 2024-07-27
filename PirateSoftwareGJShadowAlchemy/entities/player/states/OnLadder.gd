extends PlayerState
func enter(_msg := {}) -> void:
	player.staff_sprite.frame = 0
	player.staff_sprite.z_index = 4
	#player.staff_sprite.hide()
	player.current_state = &"OnLadderIdle"
	#player.global_position.x = player.ladder_ray_down.get_collision_point().x + 16
	#player.global_position.y -= 2
	
	var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_parallel(true)
	tween.set_ease(tween.EASE_OUT)
	tween.tween_property(self, "player:player_sprite:scale:y",  1, 0.09)
	tween.tween_property(self, "player:player_sprite:position:y",  0, 0.09)
	
func update(_delta: float) -> void:
	player.staff_sprite.frame = 0
	if Input.is_action_pressed("up") or Input.is_action_pressed("down"):
		player.current_state = &"OnLadder"
	else:
		player.current_state = &"OnLadderIdle"
		
	if not player.ladder_ray_down.is_colliding() and not player.ladder_ray_up.is_colliding():
		state_machine.transition_to("Idle")
		
	if player.is_on_floor() and Input.is_action_pressed("down") and not player.drop_through_raycast.is_colliding():
		state_machine.transition_to("Idle")
func physics_update(_delta: float) -> void:
	pass
	
func exit() -> void:
	player.on_ladder = false
	player.staff_sprite.frame = 1
	player.staff_sprite.z_index = -1
