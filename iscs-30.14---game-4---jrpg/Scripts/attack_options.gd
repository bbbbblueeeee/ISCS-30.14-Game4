extends VBoxContainer

@onready var attack: Button = $op1


func set_initial_focus():
	attack.grab_focus()
