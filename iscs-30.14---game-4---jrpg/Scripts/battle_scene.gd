extends Node2D

@onready var enemy_group: Node2D = $EnemyGroup
@onready var player_group: Node2D = $PlayerGroup
@onready var choice: VBoxContainer = $CanvasLayer/Choice
@onready var dialogue_text: RichTextLabel = $textBox/ColorRect/VBoxContainer/RichTextLabel
@onready var atk_opts: VBoxContainer = $"CanvasLayer/Attack Options"
@onready var defend: Button = $CanvasLayer/Choice/Defend

@export var character_delay: float = 0.02
@export var line_delay: float = 0.05

var player_index: int = 0
var enemy_index: int = 0
var action_queue: Array = []
	# Inputs a 6-element array:
	# 0 = Is the player acting
	# 1 = index of the actor,
	# 2 = action number (1=attack,2=defend(if player) or special move (if enemy)
	# 3 = recepient index
	# 4 = is it a multi-target attack
	# 5 = is there a special effect (increase stat, heal, etc.)
var is_attacking: bool = false
var is_battling: bool = false
var has_special_effect: bool = false
var tween: Tween
var line_queue: Array[String] = []
var is_printing: bool = false
var enable_space: bool = false
var win_state: bool = false
var lose_state: bool = false

var is_picking_item: bool = false
var bacon_available: bool = true
var hourglass_available: bool = true
var hourglass_active: bool = false
var novel_available: bool = true
var novel_used: bool = false
var meditate_available: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	begin_choosing_action()
	atk_opts.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_attacking:
		if Input.is_action_just_pressed("ui_up"):
			if enemy_index > 0:
				enemy_index = check_if_focus_is_alive(enemy_index,-1)
				print("UP SELECTED: " + str(enemy_index))
				# enemy_group.switch_focus(enemy_index, enemy_index+1)
		elif Input.is_action_just_pressed("ui_down"):
			if enemy_index < enemy_group.enemies.size() - 1:
				enemy_index = check_if_focus_is_alive(enemy_index,1)
				print("DOWN SELECTED: " + str(enemy_index))
				# enemy_group.switch_focus(enemy_index, enemy_index-1)
		elif Input.is_action_just_pressed("ui_accept"): # ui_accept = either Enter or Space
			action_queue.append([true,player_index,1,enemy_index,false,has_special_effect])
			# true signifies the player is taking action
			# 1 signifies the action is an attack
			enemy_group.unfocus_all()
			is_attacking=false
			has_special_effect = false
			confirm_move()

func check_if_focus_is_alive(copied_index, increment_value):
	copied_index += increment_value
	print(copied_index)
	while (copied_index >= 0 and copied_index <= enemy_group.enemies.size() - 1):
		print(enemy_group.enemies[copied_index].is_alive)
		if enemy_group.enemies[copied_index].is_alive:
			enemy_group.switch_focus(copied_index, enemy_index)
			return copied_index
		copied_index += increment_value
	print("Broke out of while loop")
	return enemy_index

func confirm_move() -> void:
	if player_index < player_group.players.size() - 1 and player_group.players[1].is_alive:
		print(player_index)
		player_index += 1
		player_group.switch_focus(player_index, player_index-1)
		begin_choosing_action()
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
			if player_group.players[player_number].is_alive:
				action_queue.append([false,enemy_number,action_number,player_number,false,false])
			else:
				action_queue.append([false,enemy_number,action_number,1-player_number,false,false])
				
		enemy_number += 1

# uses quicksort to sort all the actions based on speed
func sort_actions(arr: Array):
	if arr.size() <= 1:
		return arr
	
	var pivot = arr[arr.size() - 1]
	var pivot_speed
	if pivot[0]:
		pivot_speed = player_group.players[pivot[1]].stats.speed
	else:
		pivot_speed = enemy_group.enemies[pivot[1]].stats.speed
	var left_array = []
	var right_array = []
	
	for i in range(arr.size()-1):
		var action = arr[i]
		var actor_speed
		if action[0]:
			actor_speed = player_group.players[action[1]].stats.speed
		else:
			actor_speed = enemy_group.enemies[action[1]].stats.speed
		if actor_speed > pivot_speed:
			left_array.append(action)
		else:
			right_array.append(action)
	
	var returned_arr = []
	returned_arr.append_array(sort_actions(left_array))
	returned_arr.append(pivot)
	returned_arr.append_array(sort_actions(right_array))
	return[returned_arr][0]
	

func resolve_actions():
	action_queue = sort_actions(action_queue)
	for i in action_queue:
		var is_player_acting: bool = i[0]
		var is_multitarget: bool = i[4]
		var has_effect: bool = i[5]
		var actor
		var active_stats
		var recipient
		# sets active_stats variable based on who's acting
		if is_player_acting:
			actor = player_group.players[i[1]]
			active_stats = player_group.players[i[1]].stats
			if enemy_group.enemies[i[3]].is_alive:
				recipient = enemy_group.enemies[i[3]]
			else:
				var reselect_enemy = 0
				while (reselect_enemy <= 1 and not enemy_group.enemies[reselect_enemy].is_alive):
					reselect_enemy += 1
				recipient = enemy_group.enemies[reselect_enemy]
		else:
			actor = enemy_group.enemies[i[1]]
			active_stats = enemy_group.enemies[i[1]].stats
			if player_group.players[i[3]].is_alive:
				recipient = player_group.players[i[3]]
			else:
				if i[3] == 0:
					recipient = player_group.players[1]
				else:
					recipient = player_group.players[0]
		if actor.is_alive and !win_state and !lose_state:
			# if the action is an attack
			if i[2]==1:
				if is_player_acting or !hourglass_active:
					var final_dmg
					var is_crit: bool = false
					if randf()<active_stats.crit_rate:
						final_dmg = active_stats.attack*active_stats.crit_damage
						is_crit = true
					else:
						final_dmg = active_stats.attack
					if is_multitarget:
						queue_text(actor.title+" ATTACKS all enemies for "+str(final_dmg)+" DAMAGE.")
						for enemy in enemy_group.enemies:
							enemy.take_damage(final_dmg)
					else:
						queue_text(actor.title+" ATTACKS "+recipient.title+" for "+str(final_dmg)+" DAMAGE.")
						recipient.take_damage(final_dmg)
					if is_crit:
						queue_text("It's a CRITICAL HIT!")
					if has_effect:
						if i[1]==0:
							queue_text("All players' DEFENSE increased by 2.")
						else:
							queue_text("All players' SPEED increased by 1.")
					actor.play_animation_attack()
				else:
					queue_text(actor.title+" is STUNNED by the HOURGLASS.")
			elif i[2]==2:
				if is_player_acting:
					if meditate_available:
						queue_text(actor.title+" RESTORES "+str(min(active_stats.defense,active_stats.max_health-active_stats.current_health))+" HEALTH.")
						actor.heal(active_stats.defense)
					else:
						active_stats.block = active_stats.defense
						queue_text(actor.title+" DEFENDS themself.")
				elif !hourglass_active:
					
					if i[1]==0:
						queue_text(actor.title+" ATTACKS "+recipient.title+" for 10 DAMAGE.")
						queue_text(actor.title+" RESTORES 5 HEALTH.")
						actor.play_animation_attack()
						recipient.take_damage(10)
						actor.heal(5)
					elif i[1]==1:
						active_stats.block = active_stats.defense
						queue_text(actor.title+" DEFENDS themself.")
					else:
						recipient = enemy_group.enemies[i[3]]
						if !recipient.is_alive:
							recipient = enemy_group.enemies[1-i[3]]
							if !recipient.is_alive:
								queue_text(actor.title+" has no allies to heal.")
							else:
								queue_text(actor.title+" RESTORES 25 HEALTH to "+recipient.title)
								recipient.heal(25)
						else:
							queue_text(actor.title+" RESTORES 25 HEALTH to "+recipient.title)
							recipient.heal(25)
				else:
					queue_text(actor.title+" is STUNNED by the HOURGLASS.")
					
			elif i[2]==3:
				if i[3]==0:
					queue_text(actor.title+" used LONG BACON.")
					queue_text("All players gain 50 BLOCK.")
				elif i[3]==1:
					hourglass_active = true
					queue_text(actor.title+" used HOURGLASS.")
					queue_text("Enemies will no longer take actions this round.")
				else:
					novel_used = true
					queue_text(actor.title+" used TURNING NOVEL.")
					queue_text("Players replaced DEFEND with MEDITATE.")
			await get_tree().create_timer(1).timeout
	action_queue.clear()
	hourglass_active = false
	if novel_used:
		meditate_available = true
		defend.text="Meditate"
	is_battling = false
	if !win_state and !lose_state:
		for player in player_group.players:
			player.reset_stats()
		for enemy in enemy_group.enemies:
			enemy.reset_stats()
		if player_group.players[0].is_alive:
			player_group.players[0].focus()
		else:
			player_group.players[1].focus()
			player_index = 1
		enable_space = true
		queue_text("PRESS SPACE TO CHOOSE NEXT ACTION.")
	elif win_state:
		queue_text("YOU WIN hooray")
	elif lose_state:
		queue_text("YOU LOSE aw man")
	
	
func _unhandled_input(event: InputEvent) -> void:
	start_next_action(event)
	
	
func start_next_action(event: InputEvent) -> void:
	if is_battling:
		return
	if enable_space and event.is_action_pressed("choose_next_action"):
		get_viewport().set_input_as_handled()
		begin_choosing_action()
		enable_space = false

func begin_choosing_action():
	choice.show()
	choice.set_initial_focus()
	dialogue_text.hide()
	if tween and tween.is_running():
		tween.kill()
	line_queue.clear()
	dialogue_text.text = ""
	dialogue_text.visible_characters = 0
	is_printing = false

func _on_attack_pressed() -> void:
	choice.hide()
	player_group.choose_attack(player_index)
	atk_opts.show()
	atk_opts.set_initial_focus()
	

func _on_defend_pressed() -> void:
	choice.hide()
	dialogue_text.show()
	action_queue.append([true,player_index,2,0,false,false])
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
	is_picking_item = true
	player_group.set_items(bacon_available,hourglass_available,novel_available)
	atk_opts.show()
	atk_opts.set_initial_focus()
	

func queue_text(new_text: String) -> void:
	line_queue.append(new_text)
	if not is_printing:
		_update_queue()

func _update_queue() -> void:
	if line_queue.is_empty():
		is_printing = false
		return
		
	is_printing = true
	var next_line = line_queue.pop_front()
	
	print_to_dialogue(next_line)
		
func print_to_dialogue(text: String) -> void:
	if dialogue_text.text != "":
		dialogue_text.text += "\n" + text
	else:
		dialogue_text.text = text
	
	var start_characters = dialogue_text.visible_characters	
	var total_characters = dialogue_text.get_total_character_count()
	var duration = text.length() * character_delay
	
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(dialogue_text, "visible_characters", total_characters, duration).from(start_characters)
	tween.finished.connect(_on_line_finished)
	
func _on_line_finished() -> void:
	await get_tree().create_timer(line_delay).timeout
	_update_queue()

func atk_skill_confirmed():
	atk_opts.hide()
	dialogue_text.show()
	enemy_group.start_choosing()
	enemy_index = enemy_group.index
	is_attacking=true

func _on_op_1_pressed() -> void:
	if is_picking_item:
		for player in player_group.players:
			player.stats.block = 50
		atk_opts.hide()
		dialogue_text.show()
		is_picking_item = false
		bacon_available = false
		action_queue.append([true,player_index,3,0,false,false])
		confirm_move()
	else:
		player_group.set_atk_stats(player_index, 1)		
		atk_skill_confirmed()

func _on_op_2_pressed() -> void:
	if is_picking_item:
		atk_opts.hide()
		dialogue_text.show()
		is_picking_item = false
		hourglass_available = false
		action_queue.append([true,player_index,3,1,false,false])
		confirm_move()
	else:
		player_group.set_atk_stats(player_index, 2)
		atk_opts.hide()
		dialogue_text.show()
		action_queue.append([true,player_index,1,0,true,false])
		confirm_move()

func _on_op_3_pressed() -> void:
	if is_picking_item:
		atk_opts.hide()
		dialogue_text.show()
		is_picking_item = false
		novel_available = false
		action_queue.append([true,player_index,3,2,false,false])
		confirm_move()
	else:
		player_group.set_atk_stats(player_index, 3)
		has_special_effect = true
		atk_skill_confirmed()

func _on_player_just_died(game_over: bool) -> void:
	if game_over:
		lose_state = true

func _on_enemy_just_died(game_over: bool) -> void:
	if game_over:
		win_state = true
