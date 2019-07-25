"""
Node storing all of the changeable values for the player.
"""

extends Node

# Position of player on the court without transformations.
# (0, 0, 0) = top left corner of court and (360, 0, 780) = bottom right corner of court
var position : Vector3
var velocity : Vector3
var meter : int setget set_meter
var charge : int
var facing : int # Direction
var serving_side : int # Direction
var can_hit_ball : bool

func set_meter(value):
    meter = clamp(value, 0, 100)
    owner.emit_signal("meter_updated", owner.ID, meter)