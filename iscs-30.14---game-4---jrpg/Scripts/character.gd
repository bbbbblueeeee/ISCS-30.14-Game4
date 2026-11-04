extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _focus: AnimatedSprite2D = $focus
@onready var hp_bar: ProgressBar = $ProgressBar
@onready var anim_player: AnimationPlayer = $AnimationPlayer

@export var MAX_HEALTH: int = 200

var health: int = 200:
	set(value):
		health = value
		_update_hp_bar()
		_play_animation_hurt()

func _update_hp_bar():
	hp_bar.value = (health/MAX_HEALTH)*100

func _play_animation_hurt():
	anim_player.play("hurt")
	
func focus():
	_focus.show()

func unfocus():
	_focus.hide()

func flip_sprite():
	sprite.flip_h = true
