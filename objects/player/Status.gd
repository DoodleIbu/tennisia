"""
Node storing all of the changeable values for the player.
"""
extends Node

signal position_updated(position)
signal meter_updated(meter)

onready var _player = owner

# Position of player on the court without transformations.
# (0, 0, 0) = top left corner of court and (360, 0, 780) = bottom right corner of court
var position : Vector3 setget set_position
var velocity : Vector3
var meter : int setget set_meter
var meter_gain_next_hit : bool
var charge : int
var facing : int # Direction
var serving_side : int # Direction
var can_hit_ball : bool

func set_meter(value):
    meter = clamp(value, 0, 100)
    emit_signal("meter_updated", meter)

func use_meter(value):
    set_meter(meter - value)
    meter_gain_next_hit = false

func set_position(value):
    position = value
    if _player.team == 1:
        position.z = max(position.z, 410)
    elif _player.team == 2:
        position.z = min(position.z, 370)
    emit_signal("position_updated", position)

func _on_ball_hit(shot, max_power, max_spin, goal, meter_gain):
    if meter_gain_next_hit:
        self.meter += meter_gain
    meter_gain_next_hit = true
