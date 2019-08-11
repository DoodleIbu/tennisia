extends State

signal ball_hit(shot, max_power, max_spin, goal, meter_gain)

onready var _player = owner
onready var _ball = owner.get_node(owner.ball_path)
onready var _input_handler = owner.get_node(owner.input_handler_path)
onready var _shot_selector = owner.get_node(owner.shot_selector_path)
onready var _shot_calculator = owner.get_node(owner.shot_calculator_path)
onready var _parameters = owner.get_node(owner.parameters_path)
onready var _status = owner.get_node(owner.status_path)
onready var _animation_player = owner.get_node(owner.animation_player_path)
onready var _hitbox_manager = owner.get_node(owner.hitbox_manager_path)

const Action = preload("res://common/Enum.gd").Action
const Direction = preload("res://common/Enum.gd").Direction

var _ball_hit

func enter(message = {}):
    var _HITBOXES = [
        Hitbox.new(_parameters.HIT_SIDE_STRETCH, _parameters.HIT_SIDE_REACH - _parameters.HIT_SIDE_STRETCH, 0, 5)
    ]
    _hitbox_manager.set_data(_HITBOXES, [])
    _ball_hit = false

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
    _hitbox_manager.clear_data()

func handle_input():
    pass

func process(delta):
    pass

func physics_process(delta):
    _hitbox_manager.set_position(_status.position)
    _hitbox_manager.set_facing(_status.facing)
    if _hitbox_manager.intersects_hitbox(_ball.get_previous_position(), _ball.get_position()) and not _ball_hit:
        _fire()
        _ball_hit = true

    if not _animation_player.is_playing():
        _state_machine.set_state("Neutral")

func _fire():
    var result = _shot_calculator.calculate(_shot_selector.get_shot())
    emit_signal("ball_hit", _shot_selector.get_shot(), result["power"], result["spin"], result["goal"], result["meter_gain"])
