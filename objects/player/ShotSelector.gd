"""
Stores and determines which shot to use via a simple state machine. This uses the MTA style of shot buffering.
TODO: Look into GUT for testing
"""
extends Node

const Action = preload("res://common/Enum.gd").Action
const Shot = preload("res://common/Enum.gd").Shot

var _shot = Shot.NONE

func clear():
    _shot = Shot.NONE

func input(input):
    match input:
        Action.TOP:
            _match_top()
        Action.SLICE:
            _match_slice()
        Action.FLAT:
            _match_flat()

func get_shot():
    return _shot

func _match_top():
    match _shot:
        Shot.S_TOP, Shot.D_TOP:
            _shot = Shot.D_TOP
        Shot.S_SLICE, Shot.D_SLICE:
            _shot = Shot.DROP
        _:
            _shot = Shot.S_TOP

func _match_slice():
    match _shot:
        Shot.S_SLICE, Shot.D_SLICE:
            _shot = Shot.D_SLICE
        Shot.S_TOP, Shot.D_TOP:
            _shot = Shot.LOB
        _:
            _shot = Shot.S_SLICE

func _match_flat():
    match _shot:
        Shot.S_FLAT, Shot.D_FLAT:
            _shot = Shot.D_FLAT
        _:
            _shot = Shot.S_FLAT