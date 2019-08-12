"""
Scene that manages the hitboxes and hurtboxes of an entity.
The entity will instantiate and then pass in the hitboxes and hurtboxes to the hitbox manager.
Includes a hitbox viewer.

AnimationPlayer time values will need to be in increments of 1/60. An FPS
mode has been added to Godot but isn't in Godot 3.1.
"""

extends Node2D

const Direction = preload("res://common/Enum.gd").Direction

var _hitboxes = []
var _hurtboxes = []
var _position : Vector3 = Vector3()
var _facing : int = Direction.RIGHT
var _frame : int = 0

func intersects_hitbox(ray_start, ray_end):
    # Compare against all active hitboxes
    for hitbox in _hitboxes:
        if hitbox.is_active(_frame) and hitbox.intersects(_position, _facing, ray_start, ray_end):
            return true

    return false

func intersects_hurtbox(ray_start, ray_end):
    # Compare against all active hurtboxes
    for hurtbox in _hurtboxes:
        if hurtbox.is_active(_frame) and hurtbox.intersects(_position, _facing, ray_start, ray_end):
            return true

    return false

func set_position(value):
    _position = value
    $HitboxViewer.set_position(value)

func set_facing(value):
    _facing = value
    $HitboxViewer.set_facing(value)

func set_data(hitboxes, hurtboxes):
    _hitboxes = hitboxes
    _hurtboxes = hurtboxes
    $HitboxViewer.set_data(hitboxes, hurtboxes)

func clear_data():
    _hitboxes = []
    _hurtboxes = []

func start():
    _frame = 0

func _physics_process(_unused):
    _frame += 1
    $HitboxViewer.set_frame(_frame)
