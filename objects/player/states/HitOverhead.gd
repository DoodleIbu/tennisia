extends State

const Direction = preload("res://enums/Common.gd").Direction
const Hitbox = preload("res://objects/player/Hitbox.gd")

var _ball_hit
var _hitbox

func enter(message = {}):
    _ball_hit = false
    _hitbox = Hitbox.new(owner.status.position,
                         owner.parameters.HIT_OVERHEAD_REACH,
                         owner.parameters.HIT_OVERHEAD_STRETCH,
                         owner.status.facing)

    if owner.get_team() == 1:
        if owner.status.facing == Direction.LEFT:
            owner.play_animation("hit_overhead_left_long")
        elif owner.status.facing == Direction.RIGHT:
            owner.play_animation("hit_overhead_right_long")
    elif owner.get_team() == 2:
        if owner.status.facing == Direction.LEFT:
            owner.play_animation("hit_overhead_left_long_down")
        elif owner.status.facing == Direction.RIGHT:
            owner.play_animation("hit_overhead_right_long_down")

func exit():
    owner.clear_hitbox()

func get_state_transition():
    if not owner.is_animation_playing():
        return "Neutral"

func process(delta):
    owner.display_hitbox(_hitbox, 0, 0.1)

func physics_process(delta):
    if owner.get_current_animation_position() < 0.1 and _hitbox.intersects_ball(owner.ball) and not _ball_hit:
        owner.fire()
        _ball_hit = true
