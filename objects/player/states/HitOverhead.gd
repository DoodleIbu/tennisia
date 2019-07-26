extends State

export (NodePath) var _player_path = NodePath()
onready var _player = get_node(_player_path)

export (NodePath) var _input_handler_path = NodePath()
onready var _input_handler = get_node(_input_handler_path)

export (NodePath) var _shot_selector_path = NodePath()
onready var _shot_selector = get_node(_shot_selector_path)

export (NodePath) var _shot_calculator_path = NodePath()
onready var _shot_calculator = get_node(_shot_calculator_path)

export (NodePath) var _parameters_path = NodePath()
onready var _parameters = get_node(_parameters_path)

export (NodePath) var _status_path = NodePath()
onready var _status = get_node(_status_path)

export (NodePath) var _animation_player_path = NodePath()
onready var _animation_player = get_node(_animation_player_path)

export (NodePath) var _hitbox_viewer_path = NodePath()
onready var _hitbox_viewer = get_node(_hitbox_viewer_path)

const Action = preload("res://enums/Common.gd").Action
const Direction = preload("res://enums/Common.gd").Direction
const Hitbox = preload("res://objects/player/Hitbox.gd")

var _ball_hit
var _hitbox

func enter(message = {}):
    _ball_hit = false
    _hitbox = Hitbox.new(_status.position,
                         _parameters.HIT_OVERHEAD_REACH,
                         _parameters.HIT_OVERHEAD_STRETCH,
                         _status.facing)

    if _player.TEAM == 1:
        if _status.facing == Direction.LEFT:
            _animation_player.play("hit_overhead_left_long")
        elif _status.facing == Direction.RIGHT:
            _animation_player.play("hit_overhead_right_long")
    elif _player.TEAM == 2:
        if _status.facing == Direction.LEFT:
            _animation_player.play("hit_overhead_left_long_down")
        elif _status.facing == Direction.RIGHT:
            _animation_player.play("hit_overhead_right_long_down")

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
    if _animation_player.get_current_animation_position() < 0.1 and _hitbox.intersects_ball(owner.ball) and not _ball_hit:
        _fire()
        _ball_hit = true

# TODO: Look into implementing a common class...
func _fire():
    var direction
    if _input_handler.is_action_pressed(Action.LEFT):
        direction = Direction.LEFT
    elif _input_handler.is_action_pressed(Action.RIGHT):
        direction = Direction.RIGHT
    else:
        direction = Direction.NONE

    var result = _shot_calculator.calculate(_shot_selector.get_shot(), owner.ball, _status.charge, direction)
    owner.emit_signal("hit_ball", result["power"], result["spin"], result["goal"])
    _status.can_hit_ball = false
