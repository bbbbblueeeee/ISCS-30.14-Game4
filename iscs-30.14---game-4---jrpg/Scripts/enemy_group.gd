extends Node2D

@onready var choice: VBoxContainer = $"../CanvasLayer/Choice"
@onready var BattleScene = $".."

var enemies: Array = [] 
var action_queue: Array = []
var is_battling: bool = false
var is_attacking: bool = false
var index: int = 0
var is_all_dead: bool = false

signal enemies_dead(status: bool)

# Called when the node enters the scene tree for the first time.
# get_children() populates the array with this node's child nodes
# The for loop just instantiates the enemy sprites + positions
func _ready() -> void:
	enemies = get_children()

# Used to control the switching of the focus
func switch_focus(new, old):
	enemies[new].focus()
	enemies[old].unfocus()

func unfocus_all():
	for enemy in enemies:
		enemy.unfocus()


func start_choosing():
	unfocus_all()
	if not is_all_dead:
		index = 0
		while not enemies[index].is_alive:
			index += 1
		enemies[index].focus()
		print("DEBUG: begin choosing enemy")


func reset_block():
	for enemy in enemies:
		enemy.stats.block = 0


func _on_character_damage_blocked(text: String) -> void:
	BattleScene.queue_text(text)

func _on_character_2_damage_blocked(text: String) -> void:
	BattleScene.queue_text(text)

func _on_character_3_damage_blocked(text: String) -> void:
	BattleScene.queue_text(text)

func _on_character_3_damage_taken(text: String) -> void:
	BattleScene.queue_text(text)

func _on_character_2_damage_taken(text: String) -> void:
	BattleScene.queue_text(text)

func _on_character_damage_taken(text: String) -> void:
	BattleScene.queue_text(text)

func _on_just_died() -> void:
	var game_over: bool = true
	for enemy in enemies:
		if enemy.is_alive:
			print("enemy is alive")
			game_over = false
	enemies_dead.emit(game_over)
