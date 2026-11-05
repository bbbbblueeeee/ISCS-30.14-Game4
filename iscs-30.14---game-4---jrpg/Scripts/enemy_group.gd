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
func _ready() -> void:
	enemies = get_children()
	for i in enemies.size():
		enemies[i].flip_sprite()
		enemies[i].position = Vector2(650, i*150 + 80)
		
	show_choice()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
		
	if action_queue.size() == 2 and not is_battling:
		is_battling = true
		emit_signal("battle_status_changed", is_battling)
		choice.hide()
		_reset_focus()
		_action(action_queue)

func switch_focus(new, old):
	enemies[new].focus()
	enemies[old].unfocus()

func _action(stack):
	for i in stack:
		enemies[i].take_damage(1)
		await get_tree().create_timer(1).timeout
	action_queue.clear()
	is_battling = false
	emit_signal("battle_status_changed", is_battling)
	show_choice()

func show_choice():
	choice.show()
	choice.find_child("Attack").grab_focus()

func _reset_focus():
	index = 0
	for enemy in enemies:
		enemy.unfocus()

func _start_choosing():
	_reset_focus()
	enemies[0].focus()

func _on_attack_pressed() -> void:
	choice.hide()
	is_attacking=true
	_start_choosing()

func _on_defend_pressed() -> void:
	choice.hide()
	print("put defend code here lol idk how")

func _on_item_pressed() -> void:
	choice.hide()
	print("put item code here lol idk how")
