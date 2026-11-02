extends Node2D

var players: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	players = get_children()
	for i in players.size():
		players[i].position = Vector2(100, i*180 + 110)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
