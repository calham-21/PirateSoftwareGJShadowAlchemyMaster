extends Node2D

@export var init_level : String
@export var current_level : Node2D
@onready var level: Node2D = $Level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var initial_level = load(init_level)
	current_level = initial_level.instantiate()
	level.add_child(current_level)
	current_level.connect("change_level", change_scene)

func change_scene():
	var next_level = load(current_level.next_level_path)
	for child in level.get_children():
		child.queue_free()
	
	current_level = next_level.instantiate()
	level.add_child(current_level)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
