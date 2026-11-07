extends Node2D

@onready var choice: VBoxContainer = $"../CanvasLayer/Choice"

var enemies: Array = []
var action_queue: Array = []
var is_battling: bool = false
var is_attacking: bool = false
var index: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemies = get_children()
	for i in enemies.size():
		enemies[i].flip_sprite()
		enemies[i].position = Vector2(650, i*150 + 80)

func switch_focus(new, old):
	enemies[new].focus()
	enemies[old].unfocus()

func unfocus_all():
	for enemy in enemies:
		enemy.unfocus()

func start_choosing():
	unfocus_all()
	enemies[0].focus()
	print("begin choosing enemy")
