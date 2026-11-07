extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _focus: AnimatedSprite2D = $focus
@onready var hp_bar: ProgressBar = $ProgressBar
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var stats_component: StatsComponent = $StatsComponent

func _ready() -> void:
	pass

func update_hp_bar():
	hp_bar.value = (stats_component.current_health/stats_component.max_health)*100

func play_animation_hurt():
	anim_player.play("hurt")
	
func focus():
	_focus.show()

func unfocus():
	_focus.hide()

func take_damage(value):
	stats_component.current_health -= value
	update_hp_bar()
	play_animation_hurt()
	
func flip_sprite():
	sprite.flip_h = true
