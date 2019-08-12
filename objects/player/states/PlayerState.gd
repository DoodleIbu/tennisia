"""
To be extended by player states.

Contains
"""
extends State

class_name PlayerState

onready var _hitbox_manager = owner.get_node(owner.hitbox_manager_path)
onready var _status = owner.get_node(owner.status)

func enter(message = {}):
    _hitbox_manager.set_position(_status.position)
    _hitbox_manager.set_facing(_status.facing)
    _hitbox_manager.start()
    _enter()

func exit():
    _hitbox_manager.clear_data()
    _exit()

# To be overridden by the class extending PlayerState.
func _enter():
    assert(false)

func _exit():
    assert(false)
