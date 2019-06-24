extends Node2D

const BASE_Z_INDEX = 100

# Handle z-index rendering of ball, player and net.
func _process(delta):
    var z_sortables = [$Player, $Ball, $Net]
    z_sortables.sort_custom(self, "z_sortables_comparison")

    for i in range(0, z_sortables.size()):
        z_sortables[i].set_z_index(BASE_Z_INDEX + i)

func z_sortables_comparison(a, b):
    return a.get_z_position() < b.get_z_position()