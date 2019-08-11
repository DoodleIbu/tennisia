extends Node2D

const Direction = preload("res://common/Enum.gd").Direction

var _hitboxes = []
var _hurtboxes = []
var _position : Vector3 = Vector3()
var _facing : int = Direction.RIGHT
var _frame : int = 0

func set_data(hitboxes, hurtboxes):
    _hitboxes = hitboxes
    _hurtboxes = hurtboxes

func set_position(value):
    _position = value

func set_facing(value):
    _facing = value

func set_frame(value):
    _frame = value

func _render_rects():
    for hitbox in _hitboxes:
        if hitbox.is_active(_frame):
            Logger.info("yes")
            var render_position = hitbox.get_render_position(_position, _facing)
            var rect = ColorRect.new()
            rect.set_frame_color(Color(1, 0, 0, 0.3))
            rect.set_global_position(render_position["position"])
            rect.set_size(render_position["size"])
            add_child(rect)

    for hurtbox in _hurtboxes:
        if hurtbox.is_active(_frame):
            var render_position = hurtbox.get_render_position(_position, _facing)
            var rect = ColorRect.new()
            rect.set_frame_color(Color(0, 1, 0, 0.3))
            rect.set_global_position(render_position["position"])
            rect.set_size(render_position["size"])
            add_child(rect)

func _clear_rects():
    for child in get_children():
        remove_child(child)
        child.queue_free()

func _process(_unused):
    _clear_rects()
    _render_rects()
