extends State

export (NodePath) var _player_path = NodePath()
onready var _player = get_node(_player_path)

export (NodePath) var _parameters_path = NodePath()
onready var _parameters = get_node(_parameters_path)

export (NodePath) var _status_path = NodePath()
onready var _status = get_node(_status_path)

export (NodePath) var _animation_player_path = NodePath()
onready var _animation_player = get_node(_animation_player_path)

export (NodePath) var _hitbox_viewer_path = NodePath()
onready var _hitbox_viewer = get_node(_hitbox_viewer_path)

const Hitbox = preload("res://objects/player/Hitbox.gd")
const Direction = preload("res://enums/Common.gd").Direction

var _ball_hit
var _hitbox

func enter(message = {}):
    _ball_hit = false
    _hitbox = Hitbox.new(_status.position,
                         _parameters.HIT_SIDE_REACH,
                         _parameters.HIT_SIDE_STRETCH,
                         _status.facing)

    if _player.TEAM == 1:
        if _status.facing == Direction.LEFT:
            _animation_player.play("hit_side_left_long")
        elif _status.facing == Direction.RIGHT:
            _animation_player.play("hit_side_right_long")
    elif _player.TEAM == 2:
        if _status.facing == Direction.LEFT:
            _animation_player.play("hit_side_left_long_down")
        elif _status.facing == Direction.RIGHT:
            _animation_player.play("hit_side_right_long_down")

func exit():
    _hitbox_viewer.clear()

func get_state_transition():
    if not _animation_player.is_playing():
        return "Neutral"

func process(delta):
    if _animation_player.get_current_animation_position() < 0.1:
        _hitbox_viewer.view(_hitbox)
    else:
        _hitbox_viewer.clear()

func physics_process(delta):
    if _animation_player.get_current_animation_position() < 0.1 and \
       _hitbox.intersects_ball(owner.ball) and not _ball_hit:
        owner.fire()
        _ball_hit = true
