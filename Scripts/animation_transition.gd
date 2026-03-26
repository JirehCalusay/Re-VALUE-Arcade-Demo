extends Node

@export var animated_sprite_2D: AnimatedSprite2D
var current_transition: String = ""
@export var transition_animations: Dictionary = {
	"jump2fall": "fall",
	"run2turn": "run"
}

func _ready():
	# Connect the signal once=
	if not animated_sprite_2D.animation_finished.is_connected(Callable(self, "_on_animation_finished")):
		animated_sprite_2D.animation_finished.connect(Callable(self, "_on_animation_finished"))

func play_transition(anim_name: String):
	if anim_name in transition_animations:
		current_transition = anim_name
	else:
		current_transition = ""
	animated_sprite_2D.play(anim_name)

func _on_animation_finished(anim_name: String):
	if anim_name == current_transition:
		var loop_anim = transition_animations.get(anim_name, "")
		if loop_anim != "":
			animated_sprite_2D.play(loop_anim)
			current_transition = ""
		
