extends AnimationPlayer

func _ready():
    set_animation_process_mode(AnimationPlayer.ANIMATION_PROCESS_PHYSICS)

func play(value = "", custom_blend = -1, custom_speed = 1.0, unused = false):
    .play(value, custom_blend, custom_speed, unused)
    advance(0) # Force update to new animation. TODO: Is there a better way to do this?
