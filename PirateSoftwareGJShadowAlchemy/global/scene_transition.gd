extends CanvasLayer

@onready var transition: ColorRect = $Transition


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#transition_in()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func transition_in():
	transition.material["shader_parameter/progress"] = 1.0
	transition.material["shader_parameter/angle"] = 45
	
	var tween = create_tween()
	tween.tween_property(transition.material, "shader_parameter/progress", 1.0, 1).from(0.0).set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	
	
	#tween.interpolate_value(material, "shader_param/progress", 0, 1, 1.5, Tween.TRANS_CUBIC, Tween.EASE_OUT) 

func transition_out():
	transition.material["shader_parameter/progress"] = 0
	transition.material["shader_parameter/angle"] = 225
	var tween = create_tween()
	tween.tween_property(transition.material, "shader_parameter/progress", 0, 1).from(1.0).set_trans(Tween.TRANS_SINE)
