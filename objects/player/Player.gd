extends Node2D

signal ball_hit(max_power, max_spin, goal)
signal ball_served(max_power, max_spin, goal)
signal ball_tossed(ball_position, ball_y_velocity)
signal ball_held()
signal meter_updated(player_id, meter)

const Action = preload("res://common/Enum.gd").Action
const Direction = preload("res://common/Enum.gd").Direction
const Shot = preload("res://common/Enum.gd").Shot
const Renderer = preload("res://common/Renderer.gd")
const TimeStep = preload("res://common/TimeStep.gd")

const ShotCalculator = preload("ShotCalculator.gd")

export var id : int = 1
export var team : int = 1

# Paths exposed to children; can be accessed via owner.get_node(owner.<x>)
# I'm not a huge fan of the syntax, but it is what it is.
# These are paths instead of nodes since they can be defined before _ready() is called.
# Children nodes will call _ready() first, so defining onready nodes means children nodes will get null.
export (NodePath) var ball_path : NodePath = NodePath()
var input_handler_path = "InputHandler"
var shot_selector_path = "ShotSelector"
var shot_calculator_path = "ShotCalculator"
var parameters_path = "Parameters"
var status_path = "Status"
var animation_player_path = "AnimationPlayer"
var hitbox_manager_path = "HitboxManager"

onready var _input_handler = get_node(input_handler_path)
onready var _status = get_node(status_path)
onready var _state_machine = get_node("StateMachine")

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
    _status.can_hit_ball = (team_to_hit == team)

func _on_Main_point_started(serving_team, serving_side):
    var x
    var z

    if team == serving_team:
        if serving_side == Direction.LEFT:
            x = 140
        else:
            x = 220
    else:
        if serving_side == Direction.LEFT:
            x = 220
        else:
            x = 140

    if team == 1:
        z = 800
    else:
        z = -20

    _status.position = Vector3(x, 0, z)
    _status.velocity = Vector3()
    _status.can_hit_ball = (team == serving_team)
    _status.serving_side = serving_side
    _status.meter_gain_next_hit = true

    if _status.meter < 25:
        _status.meter = 25

    if team == serving_team:
        _state_machine.set_state("ServeNeutral")
    else:
        _state_machine.set_state("Neutral")

func _on_Main_point_ended(scoring_team):
    if team == scoring_team:
        _state_machine.set_state("Win")
    else:
        _state_machine.set_state("Lose")

# Internal signals
func _on_Status_meter_updated(meter):
    emit_signal("meter_updated", id, meter)

func _on_Status_position_updated(status_position):
    position = Renderer.get_render_position(status_position)

func _on_ball_hit(shot, max_power, max_spin, goal, meter_gain):
    emit_signal("ball_hit", max_power, max_spin, goal)

func _on_ServeHit_ball_served(max_power, max_spin, goal):
    emit_signal("ball_served", max_power, max_spin, goal)

func _on_ServeToss_ball_tossed(ball_position, ball_y_velocity):
    emit_signal("ball_tossed", ball_position, ball_y_velocity)

func _on_ServeNeutral_ball_held():
    emit_signal("ball_held")
