extends Node2D

class_name Player

signal ball_hit(max_power, max_spin, goal)
signal ball_served(max_power, max_spin, goal)
signal ball_tossed(ball_position, ball_y_velocity)
signal ball_held()
signal meter_updated(player_id, meter)

const Action = preload("res://enums/Common.gd").Action
const Direction = preload("res://enums/Common.gd").Direction
const Shot = preload("res://enums/Common.gd").Shot
const Renderer = preload("res://utils/Renderer.gd")
const TimeStep = preload("res://utils/TimeStep.gd")

const ShotCalculator = preload("ShotCalculator.gd")

export var ID : int = 1
export var TEAM : int = 1

export (NodePath) var _ball_path = NodePath()
onready var ball = get_node(_ball_path)

onready var _input_handler = $InputHandler
onready var _state_machine = $StateMachine
onready var _status = $Status

func get_position():
    return _status.position

# Processing
func _process(delta):
    _state_machine.process(delta)

func _physics_process(_unused):
    _input_handler.handle_inputs()
    _state_machine.physics_process(TimeStep.get_time_step())

# External signals
func _on_Ball_fired(team_to_hit):
    _status.can_hit_ball = (team_to_hit == TEAM)

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

    _status.position = Vector3(x, 0, z)
    _status.velocity = Vector3()
    _status.can_hit_ball = (TEAM == serving_team)
    _status.serving_side = serving_side

    if _status.meter < 25:
        _status.meter = 25

    if TEAM == serving_team:
        _state_machine.set_state("ServeNeutral")
    else:
        _state_machine.set_state("Neutral")

func _on_Main_point_ended(scoring_team):
    if TEAM == scoring_team:
        _state_machine.set_state("Win")
    else:
        _state_machine.set_state("Lose")

# Internal signals
func _on_Status_meter_updated(meter):
    emit_signal("meter_updated", ID, meter)

func _on_Status_position_updated(status_position):
    position = Renderer.get_render_position(status_position)

func _on_ball_hit(max_power, max_spin, goal):
    emit_signal("ball_hit", max_power, max_spin, goal)

func _on_ServeHit_ball_served(max_power, max_spin, goal):
    emit_signal("ball_served", max_power, max_spin, goal)

func _on_ServeToss_ball_tossed(ball_position, ball_y_velocity):
    emit_signal("ball_tossed", ball_position, ball_y_velocity)

func _on_ServeNeutral_ball_held():
    emit_signal("ball_held")
