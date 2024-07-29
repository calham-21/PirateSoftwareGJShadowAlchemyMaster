extends PanelContainer

@onready var play_button: Button = $TitleMarginContainer/MarginContainer/VBoxContainer/PlayButton
@onready var credit_button: Button = $TitleMarginContainer/MarginContainer/VBoxContainer/CreditButton
@onready var exit_button: Button = $TitleMarginContainer/MarginContainer/VBoxContainer/ExitButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_play_button_mouse_entered() -> void:
	play_button.icon = preload("res://assets/ui/button2.png")

func _on_play_button_mouse_exited() -> void:
	play_button.icon = preload("res://assets/ui/button.png")


func _on_play_button_pressed() -> void:
	SceneTransition.transition_in()
	await(get_tree().create_timer(1).timeout)
	get_tree().change_scene_to_file("res://level/levels/Level1.tscn")


func _on_credit_button_mouse_entered() -> void:
	credit_button.icon = preload("res://assets/ui/button2.png")


func _on_credit_button_mouse_exited() -> void:
	credit_button.icon = preload("res://assets/ui/button.png")




func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _on_exit_button_mouse_entered() -> void:
	exit_button.icon = preload("res://assets/ui/button2.png")

func _on_exit_button_mouse_exited() -> void:
	exit_button.icon = preload("res://assets/ui/button.png")


