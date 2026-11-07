extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _focus: AnimatedSprite2D = $focus
@onready var hp_bar: ProgressBar = $ProgressBar
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var stats: StatsComponent = $StatsComponent

@export var title: String

func _ready() -> void:
	pass

func update_hp_bar():
	hp_bar.value = (stats.current_health/stats.max_health)*100

func play_animation_hurt():
	sprite.play("hurt")
	anim_player.play("hurt")

func play_animation_attack():
	sprite.play("attack")

# Shows the Focus, AKA the arrow pointing to a character.
func focus():
	_focus.show()

# Hides the Focus, AKA the arrow pointing to a character.
func unfocus():
	_focus.hide()

# Deals damage via subtraction
func take_damage(value):
	stats.current_health -= value - stats.block
	if stats.block != 0:
		print(title+" blocked "+str(stats.block)+" damage.")
	print(title+" took "+str(value - stats.block)+" damage.")
	
	if value > stats.block:
		stats.block = 0
	else:
		stats.block -= value
		
	update_hp_bar()
	await get_tree().create_timer(0.5).timeout
	play_animation_hurt()

# Specifically made for enemies to face the player characters, since
# enemies are on the right.
func flip_sprite():
	sprite.flip_h = true


func _on_animation_finished() -> void:
	sprite.play("idle")
