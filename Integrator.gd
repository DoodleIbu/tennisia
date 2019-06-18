# Returns the new position and velocity based on the semi-implicit Euler method.
static func semi_implicit_euler(position, velocity, acceleration, delta):
    var new_velocity = velocity + acceleration * delta
    var new_position = position + new_velocity * delta

    return [new_position, new_velocity]

# Returns the new position and velocity based on the midpoint method.
static func midpoint(position, velocity, acceleration, delta):
    var new_velocity = velocity + acceleration * delta
    var midpoint_velocity = (velocity + new_velocity) / 2
    var new_position = position + midpoint_velocity * delta

    return [new_position, new_velocity, midpoint_velocity]
