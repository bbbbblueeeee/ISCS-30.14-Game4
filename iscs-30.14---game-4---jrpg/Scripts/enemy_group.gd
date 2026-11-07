extends Node2D

@onready var choice: VBoxContainer = $"../CanvasLayer/Choice"

var enemies: Array = [] 
var action_queue: Array = []
var is_battling: bool = false
var is_attacking: bool = false
var index: int = 0

signal next_player
signal battle_status_changed(battle_ongoing)

# Called when the node enters the scene tree for the first time.
# get_children() populates the array with this node's child nodes
# The for loop just instantiates the enemy sprites + positions
func _ready() -> void:
	enemies = get_children()
	for i in enemies.size():
		enemies[i].flip_sprite()
		enemies[i].position = Vector2(650, i*150 + 80)
		
	show_choice()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# These conditionals basically check for player input
	# up and down control the focus, then ui_accept selects an action
	if is_attacking:
		if Input.is_action_just_pressed("ui_up"):
			if index > 0:
				index -= 1
				switch_focus(index, index+1)
		elif Input.is_action_just_pressed("ui_down"):
			if index < enemies.size() - 1:
				index += 1
				switch_focus(index, index-1)
		elif Input.is_action_just_pressed("ui_accept"): # ui_accept = either Enter or Space
			action_queue.push_back(index)
			_reset_focus()
			is_attacking=false
			show_choice()
			emit_signal("next_player")
	
	# Basically if both player characters have selected actions, then
	# this carries out the execution of those actions. However, this
	# currently only supports attacking actions (view _action function)
	if action_queue.size() == 2 and not is_battling:
		is_battling = true
		emit_signal("battle_status_changed", is_battling)
		choice.hide()
		_reset_focus()
		_action(action_queue)

# Used to control the switching of the focus
func switch_focus(new, old):
	enemies[new].focus()
	enemies[old].unfocus()

# Executes the actions in the action queue, though currently, the only
# possible action is an attack.
func _action(stack):
	for i in stack:
		enemies[i].take_damage(1)
		await get_tree().create_timer(1).timeout
	action_queue.clear()
	is_battling = false
	emit_signal("battle_status_changed", is_battling)
	show_choice()

# Shows the UI for the action options at the bottom of the screen
func show_choice():
	choice.show()
	choice.find_child("Attack").grab_focus()

# Removes the focus from all enemies and sets index to 0
func _reset_focus():
	index = 0
	for enemy in enemies:
		enemy.unfocus()

# Resets the focus then puts the focus on the first enemy.
func _start_choosing():
	_reset_focus()
	enemies[0].focus()

# Code for when attack button is selected
# Idk why the video made it coded in here...
# The is_attacking bool might be a problem if we decide to select other options
func _on_attack_pressed() -> void:
	choice.hide()
	is_attacking=true
	_start_choosing()

# Code for when defend button is selected
func _on_defend_pressed() -> void:
	choice.hide()
	print("put defend code here lol idk how")

# Code for when item button is selected
func _on_item_pressed() -> void:
	choice.hide()
	print("put item code here lol idk how")
