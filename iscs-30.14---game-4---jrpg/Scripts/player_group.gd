extends Node2D

var players: Array = []
var index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	players = get_children()
	for i in players.size():
		players[i].position = Vector2(100, i*180 + 110)
	
	players[0].focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_enemy_group_next_player() -> void:
	if index < players.size() - 1:
		index += 1
		switch_focus(index, index-1)
	else:
		_reset_focus()

func _reset_focus():
	index = 0
	for player in players:
		player.unfocus()

func switch_focus(new, old):
	players[new].focus()
	players[old].unfocus()


func _on_enemy_group_battle_status_changed(battle_ongoing: Variant) -> void:
	if not battle_ongoing:
		players[0].focus()
