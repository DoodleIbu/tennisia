# State when the player has tossed the ball during serve.
extends State

const Action = preload("res://enums/Common.gd").Action
const Direction = preload("res://enums/Common.gd").Direction

var _ball

func enter():
    var x_offset

    if owner.get_team() == 1:
        x_offset = 10
    else:
        x_offset = -10

    owner.emit_signal("serve_ball_tossed", owner.get_position() + Vector3(x_offset, 40, 0), 200)

    if owner.get_team() == 1:
        owner.play_animation("serve_toss_right_up")
    elif owner.get_team() == 2:
        owner.play_animation("serve_toss_left_down")

func exit():
    pass

func get_state_transition():
    if _ball.get_position().y < 40 and _ball.get_velocity().y < 0:
        return "ServeNeutral"
    if owner.is_shot_action_just_pressed():
        return "ServeHit"

func process(delta):
    pass

func physics_process(delta):
    pass
