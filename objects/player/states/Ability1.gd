extends State

export (PackedScene) var Tornado

onready var _player = owner
onready var _ball = owner.get_node(owner.ball_path)
onready var _status = owner.get_node(owner.status_path)

func enter(message = {}):
    var tornado = Tornado.instance()
    tornado.set_ball(_ball)
    tornado.set_position(_status.position)
    add_child(tornado)

func exit():
    pass

func handle_input():
    pass

func process(delta):
    pass

func physics_process(delta):
    pass