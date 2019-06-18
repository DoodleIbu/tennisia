# Given a Vector3, returns a Vector2 denoting where to render the object.
static func get_render_position(court_position):

    # TODO: Should programmatically derive and cache these so it's easier to change court dimensions on a whim.
    var d = 67067.0 / 30.0
    var l = 89713.0 / 30.0
    var y = 2250.0
    var k = 1675.0 / 2.0

    # Transform court position for mapping in one-point perspective.
    var court_coordinates = Vector3()
    court_coordinates.x = court_position.x - 180
    court_coordinates.y = court_position.y + y
    court_coordinates.z = court_position.z * -1 + 780

    var transformed_coordinates = Vector2()
    transformed_coordinates.x = d * court_coordinates.x / (d + l + court_coordinates.z) + 128 # Offset to center of court
    transformed_coordinates.y = d * court_coordinates.y / (d + l + court_coordinates.z) - k + 70 # Offset to top left corner of court

    return transformed_coordinates
