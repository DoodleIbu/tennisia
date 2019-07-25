extends State

const Renderer = preload("res://utils/Renderer.gd")
const Direction = preload("res://enums/Common.gd").Direction
const Hitbox = preload("res://objects/player/Hitbox.gd")

var _ball
var _ball_hit
var _hitbox

func enter(message = {}):
    _ball_hit = false

    if owner.status.facing == Direction.LEFT:
        owner.status.velocity = Vector3(-200, 0, 0)
        owner.animation_player.play("lunge_left")
    elif owner.status.facing == Direction.RIGHT:
        owner.status.velocity = Vector3(200, 0, 0)
        owner.animation_player.play("lunge_right")

func exit():
    owner.status.velocity = Vector3(0, 0, 0)
    owner.hitbox_viewer.clear()

func get_state_transition():
    if not owner.animation_player.is_playing():
        return "Neutral"

func process(delta):
    owner.update_render_position()
    if owner.animation_player.get_current_animation_position() < 0.2:
        owner.hitbox_viewer.view(_hitbox)
    else:
        owner.hitbox_viewer.clear()

func physics_process(delta):
    _update_velocity(delta)
    owner.status.position += owner.status.velocity * delta

    # TODO: There should be a better way to determine when the hitbox is active on the animation.
    #       This is fine for now, but loop back to this and create a class that ties hitboxes to animation.
    _hitbox = Hitbox.new(owner.status.position, owner.parameters.LUNGE_REACH, owner.parameters.LUNGE_STRETCH, owner.status.facing)
    if owner.animation_player.get_current_animation_position() < 0.2 and _hitbox.intersects_ball(owner.ball) and not _ball_hit:
        owner.lunge()
        _ball_hit = true

func _update_velocity(delta):
    if owner.animation_player.get_current_animation_position() >= 0.4:
        owner.status.velocity = Vector3(0, 0, 0)
