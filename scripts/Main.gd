extends Node2D
export (PackedScene) var Bounce
const Renderer = preload("res://scripts/utils/Renderer.gd")

const BASE_Z_INDEX = 100

# Handle z-index rendering of ball, player and net.
func _process(delta):
    var z_sortables = [$Player, $Ball, $Net]
    z_sortables.sort_custom(self, "_z_sortables_comparison")

    for i in range(0, z_sortables.size()):
        z_sortables[i].set_z_index(BASE_Z_INDEX + i)

func _z_sortables_comparison(a, b):
    return a.get_position().z < b.get_position().z

func _on_Ball_bounced(bounce_position):
    var bounce = Bounce.instance()
    bounce.position = Renderer.get_render_position(bounce_position)
    add_child(bounce)
