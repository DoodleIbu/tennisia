extends Node2D

func _ready():
    $AnimationPlayer.play("bounce")

func _process(_unused):
    yield(get_node("AnimationPlayer"), "animation_finished")
    queue_free()
