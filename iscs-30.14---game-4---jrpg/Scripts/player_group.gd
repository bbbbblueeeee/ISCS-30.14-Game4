extends Node2D

var players: Array = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	players = get_children()
	for i in players.size():
		players[i].position = Vector2(100, i*180 + 110)
	players[0].focus()


func unfocus_all():
	for player in players:
		player.unfocus()


func switch_focus(new, old):
	players[new].focus()
	players[old].unfocus()
