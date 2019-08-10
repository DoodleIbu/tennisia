extends ColorRect

func _physics_process(_unused):
    if DebugOptions.is_hitbox_display_enabled():
        display()
    else:
        clear()

func display():
    var render_position = owner.get_render_position()
    set_global_position(render_position["position"])
    set_size(render_position["size"])
    set_visible(true)

func clear():
    set_visible(false)
