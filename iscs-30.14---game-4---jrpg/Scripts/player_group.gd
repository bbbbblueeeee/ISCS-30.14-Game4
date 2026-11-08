extends Node2D

@onready var BattleScene = $".."
@onready var AttackOp1 = $"../CanvasLayer/Attack Options/op1"
@onready var AttackOp2 = $"../CanvasLayer/Attack Options/op2"
@onready var AttackOp3 = $"../CanvasLayer/Attack Options/op3"

var players: Array = []

signal players_dead(status: bool)

# Called when the node enters the scene tree for the first time.
# get_children() populates the array with this node's child nodes
# The for loop just instantiates the enemy sprites + positions
func _ready() -> void:
	players = get_children()
	players[0].focus()


func unfocus_all():
	for player in players:
		player.unfocus()


func switch_focus(new, old):
	players[new].focus()
	players[old].unfocus()


func choose_attack(player: int):
	if player == 0:
		AttackOp1.text = "Grand Slash"
		AttackOp2.text = "Sweeping Sword"
		AttackOp3.text = "Battle Cry"
	elif player == 1:
		AttackOp1.text = "Calculated Strike"
		AttackOp2.text = "Quick Throw"
		AttackOp3.text = "Swift Step"
		
func set_atk_stats(p: int, atk: int) -> void:
	if p == 0:
		if atk == 1:
			players[p].update_attack(30)
		elif atk == 3:
			players[p].update_defense(2)
			players[1].update_defense(2)
	elif p == 1:
		if atk == 1:
			players[p].update_attack(20)
			players[p].update_critrate(0.5)
		elif atk == 3:
			players[p].update_speed(1)
			players[0].update_speed(1)

func on_just_died() -> void:
	pass

func _on_character_damage_blocked(text: String) -> void:
	BattleScene.queue_text(text)


func _on_character_2_damage_blocked(text: String) -> void:
	BattleScene.queue_text(text)


func _on_character_2_damage_taken(text: String) -> void:
	BattleScene.queue_text(text)


func _on_character_damage_taken(text: String) -> void:
	BattleScene.queue_text(text)


func _on_just_died() -> void:
	for player in players:
		if player.is_alive:
			print("player is alive")
			break
		print("players all dead")
		players_dead.emit()
		
