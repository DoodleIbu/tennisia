extends Node2D
export (PackedScene) var Bounce

signal point_ended(scoring_team)
signal point_started(serving_team, direction)

const Renderer = preload("res://utils/Renderer.gd")
const Direction = preload("res://enums/Common.gd").Direction

const _BASE_Z_INDEX = 100
const _POINT_ENDED_FRAMES = 180

var _win_game_count = 0
var _tiebreaker_point_count = 7
var _game_point_count = 4

var _team_1_games = 0
var _team_2_games = 0
var _team_1_points = 0
var _team_2_points = 0
var _point_ended = false
var _point_ended_frame = 0

func _ready():
    _start_point()

# Handle z-index rendering of ball, player and net.
func _process(_unused):
    var z_sortables = [get_node("Player 1"), get_node("Player 2"), $Ball, $Net]
    z_sortables.sort_custom(self, "_z_sortables_comparison")

    for i in range(0, z_sortables.size()):
        z_sortables[i].set_z_index(_BASE_Z_INDEX + i)

func _z_sortables_comparison(a, b):
    return a.get_position().z < b.get_position().z

func _physics_process(_unused):
    if _point_ended:
        _point_ended_frame += 1

        if _point_ended_frame >= _POINT_ENDED_FRAMES:
            _start_point()
            _point_ended = false

func _start_point():
    var serving_team
    var serving_side

    if _is_tiebreaker():
        serving_team = (_team_1_points + _team_2_points + 1) / 2 % 2 + 1
        var serving_side_mod = (_team_1_points + _team_2_points) % 2

        # Even
        if serving_side_mod == 0:
            if serving_team == 1:
                serving_side = Direction.RIGHT
            else:
                serving_side = Direction.LEFT
        else:
            if serving_team == 1:
                serving_side = Direction.LEFT
            else:
                serving_side = Direction.RIGHT
    else:
        serving_team = (_team_1_games + _team_2_games) % 2 + 1
        var serving_side_mod = (_team_1_points + _team_2_points) % 2

        # Even
        if serving_side_mod == 0:
            if serving_team == 1:
                serving_side = Direction.RIGHT
            else:
                serving_side = Direction.LEFT
        # Odd
        else:
            if serving_team == 1:
                serving_side = Direction.LEFT
            else:
                serving_side = Direction.RIGHT

    emit_signal("point_started", serving_team, serving_side)

func _end_point():
    var scoring_team
    var team_to_hit = $Ball.get_team_to_hit()

    if team_to_hit == 1:
        scoring_team = 2
    elif team_to_hit == 2:
        scoring_team = 1

    _add_point(scoring_team)
    _point_ended = true
    _point_ended_frame = 0
    emit_signal("point_ended", scoring_team)

# We don't actually need a parameter for this function, but it makes it easier.
func _add_game(scoring_team):
    if scoring_team == 1:
        _team_1_games += 1
    elif scoring_team == 2:
        _team_2_games += 1

    _team_1_points = 0
    _team_2_points = 0

func _add_point(scoring_team):
    if scoring_team == 1:
        _team_1_points += 1
    elif scoring_team == 2:
        _team_2_points += 1

    if _is_tiebreaker():
        if _team_1_points >= _tiebreaker_point_count and _team_1_points >= _team_2_points + 2:
            _add_game(1)
        elif _team_2_points >= _tiebreaker_point_count and _team_2_points >= _team_1_points + 2:
            _add_game(2)
    else:
        if _team_1_points >= _game_point_count and _team_1_points >= _team_2_points + 2:
            _add_game(1)
        elif _team_2_points >= _game_point_count and _team_2_points >= _team_1_points + 2:
            _add_game(2)

    Logger.info("Team 1 Games: %d, Team 2 Games: %d" % [_team_1_games, _team_2_games])
    Logger.info("Team 1 Points: %d, Team 2 Points: %d" % [_team_1_points, _team_2_points])

func _is_tiebreaker():
    return _team_1_games >= _win_game_count and _team_2_games >= _win_game_count

func _render_ball_bounce(bounce_position, bounce_velocity):
    if bounce_velocity.y < -100:
        var bounce = Bounce.instance()
        bounce.position = Renderer.get_render_position(bounce_position)
        add_child(bounce)

func _on_Ball_bounced(bounce_position, bounce_velocity):
    _render_ball_bounce(bounce_position, bounce_velocity)
    if not _point_ended and $Ball.get_bounce_count() >= 2:
        _end_point()

func _on_Player_hit_ball(_unused, _unused, _unused):
    if not _point_ended and $Ball.is_serve() and $Ball.get_bounce_count() == 0:
        _end_point()
