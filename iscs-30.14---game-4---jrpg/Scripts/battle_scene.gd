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
			action_queue.append([true,player_index,1,enemy_index])
			# true signifies the player is taking action
			# 1 signifies the action is an attack
			enemy_group.unfocus_all()
			is_attacking=false
			confirm_move()


func confirm_move() -> void:
	if player_index < player_group.players.size() - 1:
		player_index += 1
		player_group.switch_focus(player_index, player_index-1)
		begin_choosing_action()
		print("DEBUG: moved to player "+str(player_index))
	else:
		player_index = 0
		player_group.unfocus_all()
		is_battling = true
		choice.hide()
		enemy_group.unfocus_all()
		generate_enemy_actions()
		resolve_actions()


func generate_enemy_actions():
	var enemy_number: int = 0
	for enemy in enemy_group.enemies:
		if enemy.stats.current_health > 0:
			var action_number = randi_range(1,2)
			# used 1 and 2 for attack and defend
			# can add more numbers for special enemy moves
			var player_number = randi_range(0,1)
			action_queue.append([false,enemy_number,action_number,player_number])
			enemy_number += 1


func resolve_actions():
	for i in action_queue:
		var is_player_acting: bool = i[0]
		var actor
		var active_stats
		var recipient
		# sets active_stats varible based on who's acting
		if is_player_acting:
			actor = player_group.players[i[1]]
			active_stats = player_group.players[i[1]].stats
			recipient = enemy_group.enemies[i[3]]
		else:
			actor = enemy_group.enemies[i[1]]
			active_stats = enemy_group.enemies[i[1]].stats
			recipient = player_group.players[i[3]]
		# if the action is an attack
		if i[2]==1:
			var final_dmg
			var is_crit: bool = false
			if randf()<active_stats.crit_rate:
				final_dmg = active_stats.attack*active_stats.crit_damage
				is_crit = true
			else:
				final_dmg = active_stats.attack
			print(actor.title+" attacks "+recipient.title+" for "+str(final_dmg)+" damage.")
			if is_crit:
				print("It's a critical hit!")
			recipient.take_damage(final_dmg)
		elif i[2]==2:
			active_stats.block = active_stats.defense
			print(actor.title+" defends themself.")
		await get_tree().create_timer(1).timeout
	action_queue.clear()
	player_group.reset_block()
	enemy_group.reset_block()
	is_battling = false
	player_group.players[0].focus()
	begin_choosing_action()


func begin_choosing_action():
	print("DEBUG: Is Attacking- "+str(is_attacking))
	choice.show()
	choice.set_initial_focus()

func _on_attack_pressed() -> void:
	choice.hide()
	enemy_index = 0
	enemy_group.start_choosing()
	is_attacking=true


func _on_defend_pressed() -> void:
	choice.hide()
	action_queue.append([true,player_index,2,0])
	# 2 signifies the action is a defend
	# we don't care what the last value is, since it
	# determines the recipient but our recipient is always
	# the active character. this could change if we allow
	# for entities to defend other entities, but the
	# code in resolve_actions() for defend doesn't support
	# this yet. that can also be fixed somewhat easily
	confirm_move()


func _on_item_pressed() -> void:
	choice.hide()
	print("DEBUG: put item code here lol idk how")
