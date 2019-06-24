extends Node2D

const NET_POSITION_Z = 390

# Handle z-index rendering of ball, player and net.
# TODO: There should be a cleaner way to do this. Smells bad, especially with all the z-indices set everywhere.
func _process(delta):
    if $Player.actual_position.y >= NET_POSITION_Z:
        $Player.set_z_index(150)
    else:
        $Player.set_z_index(50)

    if $Ball.actual_position.z >= NET_POSITION_Z:
        if $Ball.actual_position.z >= $Player.actual_position.y:
            $Ball.set_z_index(155)
        else:
            $Ball.set_z_index(145)
    else:
        if $Ball.actual_position.z >= $Player.actual_position.y:
            $Ball.set_z_index(55)
        else:
            $Ball.set_z_index(45)

