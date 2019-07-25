# State when the player is serving with ball in hand.
extends State

const Action = preload("res://enums/Common.gd").Action
const Direction = preload("res://enums/Common.gd").Direction

func enter(message = {}):
    owner.emit_signal("serve_ball_held")

    if owner.get_team() == 1:
        owner.play_animation("serve_neutral_right_up")
    elif owner.get_team() == 2:
        owner.play_animation("serve_neutral_left_down")

func exit():
    owner.set_velocity(Vector3())

func get_state_transition():
    if owner.is_shot_action_just_pressed():
        return "ServeToss"

func process(delta):
    owner.update_render_position()

func physics_process(delta):
    owner.set_velocity(_get_desired_velocity())
    _set_player_position(delta)

func _get_desired_velocity():
    var desired_velocity = Vector3()

    if owner.is_action_pressed(Action.RIGHT):
        desired_velocity.x += 1
    if owner.is_action_pressed(Action.LEFT):
        desired_velocity.x -= 1

    return desired_velocity.normalized() * owner.get_serve_neutral_speed()

func _set_player_position(delta):
    var new_position = owner.get_position() + owner.get_velocity() * delta

    if owner.get_serving_side() == Direction.LEFT:
        if new_position.x < 65:
            new_position.x = 65
        elif new_position.x > 160:
            new_position.x = 160
    elif owner.get_serving_side() == Direction.RIGHT:
        if new_position.x < 200:
            new_position.x = 200
        elif new_position.x > 295:
            new_position.x = 295

    owner.set_position(new_position)
