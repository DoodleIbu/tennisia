extends PlayerState

signal ball_hit(shot, max_power, max_spin, goal, meter_gain)

onready var _ball = owner.get_node(owner.ball_path)
onready var _input_handler = owner.get_node(owner.input_handler_path)
onready var _shot_calculator = owner.get_node(owner.shot_calculator_path)
onready var _parameters = owner.get_node(owner.parameters_path)
onready var _animation_player = owner.get_node(owner.animation_player_path)

const Action = preload("res://common/Enum.gd").Action
const Direction = preload("res://common/Enum.gd").Direction
const Shot = preload("res://common/Enum.gd").Shot

var _ball_hit

func _enter():
    var _HITBOXES = [
        Hitbox.new(Vector3(), _parameters.HIT_SIDE_REACH, 0, 5)
    ]
    _hitbox_manager.set_data(_HITBOXES, [])
    _ball_hit = false

    if _status.facing == Direction.LEFT:
        _animation_player.play("lunge_left")
    elif _status.facing == Direction.RIGHT:
        _animation_player.play("lunge_right")

func _exit():
    _status.velocity = Vector3(0, 0, 0)

func handle_input():
    pass

func process(delta):
    pass

func physics_process(delta):
    _status.velocity = _get_velocity()
    _status.position += _status.velocity * delta
    _hitbox_manager.set_position(_status.position)
    _hitbox_manager.set_facing(_status.facing)
    if _hitbox_manager.intersects_hitbox(_ball.get_previous_position(), _ball.get_position()) and not _ball_hit:
        _fire()
        _ball_hit = true

    if not _animation_player.is_playing():
        _state_machine.set_state("Neutral")

func _get_velocity():
    if _animation_player.get_current_animation_position() <= 0.4:
        if _status.facing == Direction.LEFT:
            return Vector3(-200, 0, 0)
        elif _status.facing == Direction.RIGHT:
            return Vector3(200, 0, 0)
    else:
        return Vector3(0, 0, 0)

func _fire():
    var result = _shot_calculator.calculate(Shot.LUNGE)
    emit_signal("ball_hit", Shot.LUNGE, result["power"], result["spin"], result["goal"], result["meter_gain"])
