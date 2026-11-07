extends Node2D

@onready var BattleScene = $".."
@onready var AttackOp1 = $"../CanvasLayer/Attack Options/op1"
@onready var AttackOp2 = $"../CanvasLayer/Attack Options/op2"
@onready var AttackOp3 = $"../CanvasLayer/Attack Options/op3"

var players: Array = []

# Called when the node enters the scene tree for the first time.
# get_children() populates the array with this node's child nodes
# The for loop just instantiates the enemy sprites + positions
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


func reset_block():
	for player in players:
		player.stats.block = 0


func choose_attack(player: int):
	if player == 0:
		AttackOp1.text = "Grand Slash"
		AttackOp2.text = "Sweeping Sword"
		AttackOp3.text = "Battle Cry"
	elif player == 1:
		AttackOp1.text = "Quick Throw"
		AttackOp2.text = "Calculated Strike"
		AttackOp3.text = "Swift Step"
	else:
		print("No player chosen")
		
func set_atk_stats(p: int, atk: int) -> void:
	if p == 0:
		if atk == 1:
			players[p].update_attack(30)
		if atk == 2:
			players[p].update_attack(15)
		if atk == 3:
			players[p].update_critrate(0.25)
			players[1].update_critrate(0.25)
	elif p == 1:
		if atk == 1:
			players[p].update_attack(20)
		if atk == 2:
			players[p].update_attack(25)
			players[p].update_critrate(0.40)
			players[p].update_critdamage(1.5)
		if atk == 3:
			players[p].update_speed(10)
		

func _on_character_damage_blocked(text: String) -> void:
	BattleScene.queue_text(text)


func _on_character_2_damage_blocked(text: String) -> void:
	BattleScene.queue_text(text)


func _on_character_2_damage_taken(text: String) -> void:
	BattleScene.queue_text(text)


func _on_character_damage_taken(text: String) -> void:
	pass # Replace with function body.
