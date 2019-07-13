const Renderer = preload("res://utils/Renderer.gd")
const Direction = preload("res://enums/Common.gd").Direction

var _aabb

func _init(position, size, direction):
    var aabb_start

    if direction == Direction.LEFT:
        aabb_start = position - Vector3(size.x, 0, size.z / 2)
    elif direction == Direction.RIGHT:
        aabb_start = position - Vector3(0, 0, size.z / 2)
    else:
        assert(false)

    _aabb = AABB(aabb_start, size)

func intersects_ball(ball):
    return _aabb.intersects_segment(ball.get_previous_position(), ball.get_position())

func get_render_position():
    var top_left = Renderer.get_render_position(_aabb.position + Vector3(0, _aabb.size.y, _aabb.size.z / 2))
    var bottom_right = Renderer.get_render_position(_aabb.position + Vector3(_aabb.size.x, 0, _aabb.size.z / 2))

    return {
        "position": top_left,
        "size": bottom_right - top_left
    }
