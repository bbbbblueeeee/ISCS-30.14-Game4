extends Node2D

var enemies: Array = []
var index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemies = get_children()
	for i in enemies.size():
		enemies[i].flip_sprite()
		enemies[i].position = Vector2(650, i*150 + 80)
		
	enemies[0].focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_up"):
		if index > 0:
			index -= 1
			switch_focus(index, index+1)
	elif Input.is_action_just_pressed("ui_down"):
		if index < enemies.size() - 1:
			index += 1
			switch_focus(index, index-1)

func switch_focus(new, old):
	enemies[new].focus()
	enemies[old].unfocus()
