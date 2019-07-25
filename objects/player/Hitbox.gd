class_name Hitbox

const Renderer = preload("res://utils/Renderer.gd")
const Direction = preload("res://enums/Common.gd").Direction

var _aabb

func _init(position, reach, stretch, direction):
    var aabb_start

    if direction == Direction.LEFT:
        aabb_start = position - Vector3(reach.x, 0, reach.z) + Vector3(0, stretch.y, 0)
    else:
        aabb_start = position + stretch

    _aabb = AABB(aabb_start, reach - stretch)

func intersects_ball(ball):
    return _aabb.intersects_segment(ball.get_previous_position(), ball.get_position())

func get_render_position():
    var top_left = Renderer.get_render_position(_aabb.position + Vector3(0, _aabb.size.y, _aabb.size.z / 2))
    var bottom_right = Renderer.get_render_position(_aabb.position + Vector3(_aabb.size.x, 0, _aabb.size.z / 2))

    return {
        "position": top_left,
        "size": bottom_right - top_left
    }
