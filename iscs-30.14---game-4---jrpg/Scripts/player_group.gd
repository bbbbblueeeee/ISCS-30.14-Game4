extends Node2D

var players: Array = []
var index: int = 0

# Called when the node enters the scene tree for the first time.
# get_children() populates the array with this node's child nodes
# The for loop just instantiates the enemy sprites + positions
func _ready() -> void:
	players = get_children()
	for i in players.size():
		players[i].position = Vector2(100, i*180 + 110)
	
	players[0].focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Called when it's the next character's turn.
# Puts the focus on whoever's turn it currently is.
func _on_enemy_group_next_player() -> void:
	if index < players.size() - 1:
		index += 1
		switch_focus(index, index-1)
	else:
		_reset_focus()

# Removes the focus from all player characters and sets index to 0
func _reset_focus():
	index = 0
	for player in players:
		player.unfocus()

# Used to control the switching of the focus
func switch_focus(new, old):
	players[new].focus()
	players[old].unfocus()

# I believe when all actions in a turn have been executed, this basically
# puts the focus back to the first character so that the first character
# can act.
func _on_enemy_group_battle_status_changed(battle_ongoing: Variant) -> void:
	if not battle_ongoing:
		players[0].focus()
