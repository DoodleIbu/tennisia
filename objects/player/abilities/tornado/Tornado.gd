extends Node2D

const Direction = preload("res://common/Enum.gd").Direction
const Shot = preload("res://common/Enum.gd").Shot
const Renderer = preload("res://common/Renderer.gd")

enum State { STARTUP, ACTIVE }

const _STARTUP_FRAMES : int = 60
const _ACTIVE_FRAMES : int = 300
const _REACH : Vector3 = Vector3(50, 80, 20)
const _STRETCH : Vector3 = Vector3(-50, 0, -20)

var _ball : Node
var _position : Vector3
var _current_frame : int
var _state : int

func set_ball(value):
    _ball = value

func set_position(value):
    _position = value

func _ready():
    _current_frame = 0
    _state = State.STARTUP

func _process(_unused):
    if _state == State.STARTUP:
        $AnimationPlayer.play("inactive")
    elif _state == State.ACTIVE:
        $AnimationPlayer.play("active")

    position = Renderer.get_render_position(_position)

func _physics_process(_unused):
    _current_frame += 1
    _handle_state_transition()
    _handle_hitbox()

func _handle_state_transition():
    if _current_frame > _STARTUP_FRAMES + _ACTIVE_FRAMES:
        queue_free()
    elif _current_frame > _STARTUP_FRAMES:
        _state = State.ACTIVE
    else:
        _state = State.STARTUP

# TODO: Modify hitbox properties...
func _handle_hitbox():
    pass
#    var hitbox = Hitbox.new(_position, _REACH, _STRETCH, Direction.RIGHT)
#    if hitbox.intersects_ball(_ball):
#        Logger.info("tornado intersects ball")
        # emit_signal("hit_ball", Shot.SLICE, 1000, 80)
