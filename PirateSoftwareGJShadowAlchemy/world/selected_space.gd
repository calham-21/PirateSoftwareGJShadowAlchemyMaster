extends CharacterBody2D
@onready var selected_space_sprite: Sprite2D = $SelectedSpaceSprite
@onready var boundary_ray: RayCast2D = $BoundaryRay
@onready var selected_space_area: Area2D = $SelectedSpaceArea
@onready var move_ray: RayCast2D = $MoveRay

var grid_size = 32
var can_move : bool = true
signal selected_space_enter
signal selected_space_exit
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	for body in selected_space_area.get_overlapping_bodies():
		if body.is_in_group("Box"):
			selected_space_enter.emit(body)
	move_and_slide()
	
func move(vel: Vector2) ->bool:
	var vel_norm = vel.normalized()
	var new_pos = vel_norm * grid_size
	move_ray.target_position = new_pos
	move_ray.force_raycast_update()
	if !move_ray.is_colliding() and can_move:
		can_move = false
		var tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
		tween.tween_property(self, "global_position", global_position + new_pos, 0.05)
		#wait for tween to finish, then disable some stuff.
		await(tween.finished)
		can_move = true
		return true
	else:
		
		return false
	return false
	


func _on_selected_space_area_body_entered(body: Node2D) -> void:
	selected_space_enter.emit(body)


func _on_selected_space_area_body_exited(body: Node2D) -> void:
	selected_space_exit.emit()
