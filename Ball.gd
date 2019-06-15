extends Node2D

const Renderer = preload("res://Renderer.gd")

var actual_position = Vector3(100, -80, 400)

func _ready():
    position = Vector2(0, 0)

func _process(delta):
    $Ball.position = Renderer.get_render_position(actual_position)
    $"Ball Shadow".position = Renderer.get_render_position(Vector3(actual_position.x, 0, actual_position.z))
