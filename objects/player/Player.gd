extends Node2D

signal hit_ball(max_power, max_spin, goal)
signal serve_ball(max_power, max_spin, goal)
signal serve_ball_tossed(ball_position, ball_y_velocity)
signal serve_ball_held()
signal meter_updated(player_id, meter)

const Renderer = preload("res://utils/Renderer.gd")
const Action = preload("res://enums/Common.gd").Action
const Direction = preload("res://enums/Common.gd").Direction
const Shot = preload("res://enums/Common.gd").Shot

const InputMapper = preload("InputMapper.gd")
const ShotBuffer = preload("ShotBuffer.gd")
const ShotCalculator = preload("ShotCalculator.gd")

export var ID : int = 1
export var TEAM : int = 1

# TODO: Implement ball node within player to store relevant information about the ball.
export (NodePath) var _ball_path
onready var ball = get_node(_ball_path)

onready var state_machine = $StateMachine
onready var parameters = $Parameters
onready var status = $Status

onready var animation_player = $AnimationPlayer
onready var hitbox_viewer = $HitboxViewer

var _input_mapper
var _shot_buffer
var _shot_calculator

func get_position():
    return status.position

# Common helper methods called from states. There should be a better way to implement these... will refactor when the time comes.
# It makes sense to me for the player to own the input buffer, charge amount, etc.
# Example: Should the input buffer be passed by reference into each state instead of defining these methods?
func is_action_pressed(action):
    return _input_mapper.is_action_pressed(action)

func is_action_just_pressed(action):
    return _input_mapper.is_action_just_pressed(action)

func is_shot_action_just_pressed():
    return _input_mapper.is_action_just_pressed(Action.TOP) or \
           _input_mapper.is_action_just_pressed(Action.SLICE) or \
           _input_mapper.is_action_just_pressed(Action.FLAT)

func process_shot_input():
    var shot_actions = [Action.TOP, Action.SLICE, Action.FLAT]
    for shot_action in shot_actions:
        if _input_mapper.is_action_just_pressed(shot_action):
            _shot_buffer.input(shot_action)

func clear_shot_buffer():
    _shot_buffer.clear()

# TODO: There should be a better way to implement these.
func _fire(shot):
    var direction
    if _input_mapper.is_action_pressed(Action.LEFT):
        direction = Direction.LEFT
    elif _input_mapper.is_action_pressed(Action.RIGHT):
        direction = Direction.RIGHT
    else:
        direction = Direction.NONE

    var result = _shot_calculator.calculate(shot, ball, status.charge, direction)
    emit_signal("hit_ball", result["power"], result["spin"], result["goal"])
    status.can_hit_ball = false

func fire():
    _fire(_shot_buffer.get_shot())
    status.meter += 10

func lunge():
    _fire(Shot.LUNGE)

func update_position(delta):
    var new_position = status.position + status.velocity * delta
    if TEAM == 1:
        new_position.z = max(new_position.z, 410)
    elif TEAM == 2:
        new_position.z = min(new_position.z, 370)
    status.position = new_position

func update_render_position():
    position = Renderer.get_render_position(status.position)



func _ready():
    _input_mapper = InputMapper.new(ID)
    _shot_buffer = ShotBuffer.new()
    _shot_calculator = ShotCalculator.new(parameters.SHOT_PARAMETERS, TEAM)

# TODO: How should we handle inputs and state transitions?
func _physics_process(delta):
    _input_mapper.handle_inputs()

# Signals
func _on_Ball_fired(team_to_hit):
    status.can_hit_ball = (team_to_hit == TEAM)

func _on_Main_point_started(serving_team, serving_side):
    var x
    var z

    if TEAM == serving_team:
        if serving_side == Direction.LEFT:
            x = 140
        else:
            x = 220
    else:
        if serving_side == Direction.LEFT:
            x = 220
        else:
            x = 140

    if TEAM == 1:
        z = 800
    else:
        z = -20

    status.position = Vector3(x, 0, z)
    status.velocity = Vector3()
    status.can_hit_ball = (TEAM == serving_team)
    status.serving_side = serving_side

    if status.meter < 25:
        status.meter = 25

    if TEAM == serving_team:
        state_machine.set_state("ServeNeutral")
    else:
        state_machine.set_state("Neutral")

    Logger.info("Current animation: %s" % $AnimationPlayer.get_current_animation())

func _on_Main_point_ended(scoring_team):
    if TEAM == scoring_team:
        state_machine.set_state("Win")
    else:
        state_machine.set_state("Lose")
