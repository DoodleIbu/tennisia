extends "StateBase.gd"

const State = preload("States.gd").State

var _ball
var _ball_hit = false

func _init(player, ball).(player):
    _ball = ball

func enter():
    _ball_hit = false

    var animation_player = _player.get_node("AnimationPlayer")
    animation_player.play("run_right") # TODO: replace

func exit():
    pass

func get_state_transition():
    if Input.is_action_just_pressed("ui_cancel"):
        return State.NEUTRAL

    return null

func process(delta):
    pass

func physics_process(delta):
    if not _ball_hit:
        _player.fire(800, -200, Vector3(80, 0, 200))
        print("hit_ball")
    _ball_hit = true
