extends State

export (NodePath) var _parameters_path = NodePath()
onready var _parameters = get_node(_parameters_path)

export (NodePath) var _status_path = NodePath()
onready var _status = get_node(_status_path)

export (NodePath) var _animation_player_path = NodePath()
onready var _animation_player = get_node(_animation_player_path)

export (NodePath) var _hitbox_viewer_path = NodePath()
onready var _hitbox_viewer = get_node(_hitbox_viewer_path)

const Renderer = preload("res://utils/Renderer.gd")
const Direction = preload("res://enums/Common.gd").Direction
const Hitbox = preload("res://objects/player/Hitbox.gd")

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
    if _animation_player.get_current_animation_position() < 0.2 and _hitbox.intersects_ball(owner.ball) and not _ball_hit:
        owner.lunge()
        _ball_hit = true

func _get_velocity():
    if _animation_player.get_current_animation_position() <= 0.4:
        if _status.facing == Direction.LEFT:
            return Vector3(-200, 0, 0)
        elif _status.facing == Direction.RIGHT:
            return Vector3(200, 0, 0)
    else:
        return Vector3(0, 0, 0)
