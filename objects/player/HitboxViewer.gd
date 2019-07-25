extends ColorRect

func view(hitbox):
    if DebugOptions.is_hitbox_display_enabled():
        var result = hitbox.get_render_position()
        set_global_position(result["position"])
        set_size(result["size"])
        set_visible(true)

func clear():
    set_visible(false)
