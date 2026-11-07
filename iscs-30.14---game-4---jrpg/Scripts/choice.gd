extends VBoxContainer

@onready var attack: Button = $Attack


func set_initial_focus():
	attack.grab_focus()
