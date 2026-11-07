extends Node2D

@onready var enemy_group: Node2D = $EnemyGroup
@onready var player_group: Node2D = $PlayerGroup
@onready var choice: VBoxContainer = $CanvasLayer/Choice

var player_index: int = 0
var enemy_index: int = 0
var action_queue: Array = []
var is_attacking: bool = false
var is_battling: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	begin_choosing_action()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_attacking:
		if Input.is_action_just_pressed("ui_up"):
			if enemy_index > 0:
				enemy_index -= 1
				enemy_group.switch_focus(enemy_index, enemy_index+1)
		elif Input.is_action_just_pressed("ui_down"):
			if enemy_index < enemy_group.enemies.size() - 1:
				enemy_index += 1
				enemy_group.switch_focus(enemy_index, enemy_index-1)
		elif Input.is_action_just_pressed("ui_accept"): # ui_accept = either Enter or Space
			action_queue.append(enemy_index)
			# NOTE: WE HAVE TO FUCKING FIX THIS LOL
			# the action queue should be an array of arrays
			# each smaller array will hold the information of
			# the actor, the action, and any other impt things
			enemy_group.unfocus_all()
			is_attacking=false
			confirm_move()


func confirm_move() -> void:
	if player_index < player_group.players.size() - 1:
		player_index += 1
		player_group.switch_focus(player_index, player_index-1)
		begin_choosing_action()
		print("moved to player "+str(player_index))
	else:
		player_index = 0
		player_group.unfocus_all()
		is_battling = true
		choice.hide()
		enemy_group.unfocus_all()
		resolve_actions()


func resolve_actions():
	for i in action_queue:
		enemy_group.enemies[i].take_damage(10)
		# NOTE: FIX THIS
		# we need deal damage to enemy/enemies according to
		# the attacking character's attack + crit stats
		await get_tree().create_timer(1).timeout
	action_queue.clear()
	is_battling = false
	player_group.players[0].focus()
	begin_choosing_action()


func begin_choosing_action():
	print("Is Attacking: "+str(is_attacking))
	choice.show()
	choice.set_initial_focus()

func _on_attack_pressed() -> void:
	choice.hide()
	enemy_index = 0
	enemy_group.start_choosing()
	is_attacking=true


func _on_defend_pressed() -> void:
	choice.hide()
	print("put defend code here lol idk how")


func _on_item_pressed() -> void:
	choice.hide()
	print("put item code here lol idk how")
