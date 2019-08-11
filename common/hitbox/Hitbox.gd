"""
Collision box.

For the sake of brevity, collision boxes are referred to as hitboxes, although they
encompass hurtboxes.
"""

class_name Hitbox

const Renderer = preload("res://common/Renderer.gd")
const Direction = preload("res://common/Enum.gd").Direction

var _offset : Vector3  # Offset from the entity position
var _size : Vector3    # Size of the hitbox
var _frame_start : int # Start frame inclusive
var _frame_end : int   # End frame inclusive; -1 if doesn't end

func _init(offset, size, frame_start, frame_end = -1):
    _offset = offset
    _size = size
    _frame_start = frame_start
    _frame_end = frame_end

func is_active(frame):
    if _frame_end == -1:
        return frame >= _frame_start
    else:
        return frame >= _frame_start and frame <= _frame_end

func intersects(entity_position, entity_facing, ray_start, ray_end):
    var aabb = _get_aabb(entity_position, entity_facing)
    Logger.info(aabb.position)
    return aabb.intersects_segment(ray_start, ray_end)

func get_render_position(entity_position, entity_facing):
    var aabb = _get_aabb(entity_position, entity_facing)
    var top_left = Renderer.get_render_position(aabb.position + Vector3(0, aabb.size.y, aabb.size.z / 2))
    var bottom_right = Renderer.get_render_position(aabb.position + Vector3(aabb.size.x, 0, aabb.size.z / 2))

    return {
        "position": top_left,
        "size": bottom_right - top_left
    }

func _get_aabb(entity_position, entity_facing):
    if entity_facing == Direction.LEFT:
        return AABB(entity_position - Vector3(_size.x, 0, 0), _size)
    elif entity_facing == Direction.RIGHT:
        return AABB(entity_position, _size)
    else:
        assert(false)
