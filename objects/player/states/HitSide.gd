extends State

const Hitbox = preload("res://objects/player/Hitbox.gd")
const Direction = preload("res://enums/Common.gd").Direction

var _ball
var _ball_hit
var _hitbox

func enter(message = {}):
    _ball_hit = false
    _hitbox = Hitbox.new(owner.status.position,
                         owner.parameters.HIT_SIDE_REACH,
                         owner.parameters.HIT_SIDE_STRETCH,
                         owner.status.facing)

    if owner.TEAM == 1:
        if owner.status.facing == Direction.LEFT:
            owner.animation_player.play("hit_side_left_long")
        elif owner.status.facing == Direction.RIGHT:
            owner.animation_player.play("hit_side_right_long")
    elif owner.TEAM == 2:
        if owner.status.facing == Direction.LEFT:
            owner.animation_player.play("hit_side_left_long_down")
        elif owner.status.facing == Direction.RIGHT:
            owner.animation_player.play("hit_side_right_long_down")

func exit():
    owner.clear_hitbox()

func get_state_transition():
    if not owner.animation_player.is_playing():
        return "Neutral"

func process(delta):
    owner.display_hitbox(_hitbox, 0, 0.1)

func physics_process(delta):
    if owner.animation_player.get_current_animation_position() < 0.1 and _hitbox.intersects_ball(owner.ball) and not _ball_hit:
        owner.fire()
        _ball_hit = true
