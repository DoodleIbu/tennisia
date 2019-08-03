extends State

signal ball_hit(max_power, max_spin, goal)

onready var _player = owner
onready var _ball = owner.get_node(owner.ball_path)
onready var _input_handler = owner.get_node(owner.input_handler_path)
onready var _shot_selector = owner.get_node(owner.shot_selector_path)
onready var _shot_calculator = owner.get_node(owner.shot_calculator_path)
onready var _parameters = owner.get_node(owner.parameters_path)
onready var _status = owner.get_node(owner.status_path)
onready var _animation_player = owner.get_node(owner.animation_player_path)
onready var _hitbox_viewer = owner.get_node(owner.hitbox_viewer_path)

const Hitbox = preload("res://objects/player/Hitbox.gd")
const Action = preload("res://enums/Common.gd").Action
const Direction = preload("res://enums/Common.gd").Direction

var _ball_hit
var _hitbox

func enter(message = {}):
    _ball_hit = false
    _hitbox = Hitbox.new(_status.position,
                         _parameters.HIT_SIDE_REACH,
                         _parameters.HIT_SIDE_STRETCH,
                         _status.facing)

    if _player.team == 1:
        if _status.facing == Direction.LEFT:
            _animation_player.play("hit_side_left_long")
        elif _status.facing == Direction.RIGHT:
            _animation_player.play("hit_side_right_long")
    elif _player.team == 2:
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
       _hitbox.intersects_ball(_ball) and not _ball_hit:
        _fire()
        _ball_hit = true

# TODO: Look into implementing a common class...
func _fire():
    var result = _shot_calculator.calculate(_shot_selector.get_shot())
    emit_signal("ball_hit", result["power"], result["spin"], result["goal"])
    _status.meter += result["meter_gain"]
    _status.can_hit_ball = false
