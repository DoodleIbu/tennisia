extends State

signal ball_hit(max_power, max_spin, goal)

onready var _ball = owner.get_node(owner.ball_path)
onready var _input_handler = owner.get_node(owner.input_handler_path)
onready var _shot_calculator = owner.get_node(owner.shot_calculator_path)
onready var _parameters = owner.get_node(owner.parameters_path)
onready var _status = owner.get_node(owner.status_path)
onready var _animation_player = owner.get_node(owner.animation_player_path)
onready var _hitbox_viewer = owner.get_node(owner.hitbox_viewer_path)

const Action = preload("res://enums/Common.gd").Action
const Direction = preload("res://enums/Common.gd").Direction
const Shot = preload("res://enums/Common.gd").Shot
const Hitbox = preload("res://objects/player/Hitbox.gd")
const Renderer = preload("res://utils/Renderer.gd")

var _ball_hit
var _hitbox

func enter(message = {}):
    _ball_hit = false
    if _status.facing == Direction.LEFT:
        _animation_player.play("lunge_left")
    elif _status.facing == Direction.RIGHT:
        _animation_player.play("lunge_right")

func exit():
    _status.velocity = Vector3(0, 0, 0)
    _hitbox_viewer.clear()

func get_state_transition():
    if not _animation_player.is_playing():
        return "Neutral"

func process(delta):
    if _animation_player.get_current_animation_position() < 0.2:
        _hitbox_viewer.view(_hitbox)
    else:
        _hitbox_viewer.clear()

func physics_process(delta):
    _status.velocity = _get_velocity()
    _status.position += _status.velocity * delta

    # TODO: There should be a better way to determine when the hitbox is active on the animation.
    #       This is fine for now, but loop back to this and create a class that ties hitboxes to animation.
    _hitbox = Hitbox.new(_status.position, _parameters.LUNGE_REACH, _parameters.LUNGE_STRETCH, _status.facing)
    if _animation_player.get_current_animation_position() < 0.2 and _hitbox.intersects_ball(_ball) and not _ball_hit:
        _fire()
        _ball_hit = true

func _get_velocity():
    if _animation_player.get_current_animation_position() <= 0.4:
        if _status.facing == Direction.LEFT:
            return Vector3(-200, 0, 0)
        elif _status.facing == Direction.RIGHT:
            return Vector3(200, 0, 0)
    else:
        return Vector3(0, 0, 0)

# TODO: Look into implementing a common class...
func _fire():
    var direction
    if _input_handler.is_action_pressed(Action.LEFT):
        direction = Direction.LEFT
    elif _input_handler.is_action_pressed(Action.RIGHT):
        direction = Direction.RIGHT
    else:
        direction = Direction.NONE

    var result = _shot_calculator.calculate(Shot.LUNGE, _ball, _status.charge, direction)
    emit_signal("ball_hit", result["power"], result["spin"], result["goal"])
    _status.can_hit_ball = false
