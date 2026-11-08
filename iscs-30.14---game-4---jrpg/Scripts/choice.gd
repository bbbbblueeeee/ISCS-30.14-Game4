extends VBoxContainer

@onready var attack: Button = $Attack
@onready var desc: RichTextLabel = $"../../textBox/ColorRect/Action Desc"

func set_initial_focus():
	attack.grab_focus()
	desc.show()
	desc.text = "Select a skill and deal certain amounts of attack damage to an enemy of your choice."
	
