extends State

const Renderer = preload("res://utils/Renderer.gd")
const Direction = preload("res://enums/Common.gd").Direction
const Hitbox = preload("res://objects/player/Hitbox.gd")

var _ball
var _ball_hit
var _hitbox

func enter(message = {}):
    _ball_hit = false

    if owner.get_facing() == Direction.LEFT:
        owner.set_velocity(Vector3(-200, 0, 0))
        owner.play_animation("lunge_left")
    elif owner.get_facing() == Direction.RIGHT:
        owner.set_velocity(Vector3(200, 0, 0))
        owner.play_animation("lunge_right")

func exit():
    owner.set_velocity(Vector3(0, 0, 0))
    owner.clear_hitbox()

func get_state_transition():
    if not owner.is_animation_playing():
        return "Neutral"

func process(delta):
    owner.update_render_position()
    owner.display_hitbox(_hitbox, 0, 0.2)

func physics_process(delta):
    _update_velocity(delta)
    owner.update_position(delta)

    # TODO: There should be a better way to determine when the hitbox is active on the animation.
    #       This is fine for now, but loop back to this and create a class that ties hitboxes to animation.
    _hitbox = Hitbox.new(owner.get_position(), owner.get_lunge_reach(), owner.get_lunge_stretch(), owner.get_facing())
    if owner.get_current_animation_position() < 0.2 and _hitbox.intersects_ball(owner.ball) and not _ball_hit:
        owner.lunge()
        _ball_hit = true

func _update_velocity(delta):
    if owner.get_current_animation_position() >= 0.4:
        owner.set_velocity(Vector3(0, 0, 0))
