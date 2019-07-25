# State when the player is hitting the ball.
extends State

const Action = preload("res://enums/Common.gd").Action
const Direction = preload("res://enums/Common.gd").Direction

var _ball_hit

func enter(message = {}):
    _ball_hit = false

    if owner.get_team() == 1:
        owner.play_animation("hit_overhead_right_long")
    elif owner.get_team() == 2:
        owner.play_animation("hit_overhead_left_long_down")

func exit():
    pass

func get_state_transition():
    if not owner.is_animation_playing():
        return "Neutral"

func process(delta):
    pass

func physics_process(delta):
    if not _ball_hit:
        var depth
        var side
        var spin = 0
        var control = 50

        if owner.get_team() == 1:
            depth = 210
        elif owner.get_team() == 2:
            depth = 570

        if owner.get_serving_side() == Direction.LEFT:
            side = 247.5
        elif owner.get_serving_side() == Direction.RIGHT:
            side = 112.5

        if owner.is_action_pressed(Action.LEFT):
            side -= control
        elif owner.is_action_pressed(Action.RIGHT):
            side += control

        if owner.is_action_pressed(Action.TOP):
            spin = -100
        elif owner.is_action_pressed(Action.SLICE):
            spin = 100

        var goal = Vector3(side, 0, depth)

        owner.emit_signal("serve_ball", 1200, spin, goal)
        owner.set_meter(owner.get_meter() + 10)
        owner.set_can_hit_ball(false)
        _ball_hit = true
