# State when the player is serving with ball in hand.
extends State

const Action = preload("res://enums/Common.gd").Action
const Direction = preload("res://enums/Common.gd").Direction

func enter(message = {}):
    owner.emit_signal("serve_ball_held")

    if owner.TEAM == 1:
        owner.animation_player.play("serve_neutral_right_up")
    else:
        owner.animation_player.play("serve_neutral_left_down")

func exit():
    owner.status.velocity = Vector3()

func get_state_transition():
    if owner.input_handler.is_shot_action_just_pressed():
        return "ServeToss"

func process(delta):
    owner.update_render_position()

func physics_process(delta):
    owner.status.velocity = _get_desired_velocity()
    _set_player_position(delta)

func _get_desired_velocity():
    var desired_velocity = Vector3()

    if owner.input_handler.is_action_pressed(Action.RIGHT):
        desired_velocity.x += 1
    if owner.input_handler.is_action_pressed(Action.LEFT):
        desired_velocity.x -= 1

    return desired_velocity.normalized() * owner.parameters.SERVE_NEUTRAL_SPEED

func _set_player_position(delta):
    var new_position = owner.status.position + owner.status.velocity * delta

    if owner.status.serving_side == Direction.LEFT:
        if new_position.x < 65:
            new_position.x = 65
        elif new_position.x > 160:
            new_position.x = 160
    else:
        if new_position.x < 200:
            new_position.x = 200
        elif new_position.x > 295:
            new_position.x = 295

    owner.status.position = new_position
