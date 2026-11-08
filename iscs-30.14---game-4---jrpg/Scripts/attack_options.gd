extends VBoxContainer

@onready var attack: Button = $op1
@onready var desc: RichTextLabel = $"../../textBox/ColorRect/Action Desc"

func set_initial_focus():
	attack.grab_focus()
