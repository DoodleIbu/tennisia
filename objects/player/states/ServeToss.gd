# State when the player has tossed the ball during serve.
extends State

const Action = preload("res://enums/Common.gd").Action
const Direction = preload("res://enums/Common.gd").Direction

func enter(message = {}):
    var x_offset

    if owner.TEAM == 1:
        x_offset = 10
    else:
        x_offset = -10

    owner.emit_signal("serve_ball_tossed", owner.status.position + Vector3(x_offset, 40, 0), 200)

    if owner.TEAM == 1:
        owner.animation_player.play("serve_toss_right_up")
    elif owner.TEAM == 2:
        owner.animation_player.play("serve_toss_left_down")

func exit():
    pass

func get_state_transition():
    if owner.ball.get_position().y < 40 and owner.ball.get_velocity().y < 0:
        return "ServeNeutral"
    if owner.input_handler.is_shot_action_just_pressed():
        return "ServeHit"

func process(delta):
    pass

func physics_process(delta):
    pass
