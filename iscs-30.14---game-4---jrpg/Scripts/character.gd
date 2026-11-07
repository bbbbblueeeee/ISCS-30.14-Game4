extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _focus: AnimatedSprite2D = $focus
@onready var hp_bar: ProgressBar = $ProgressBar
@onready var anim_player: AnimationPlayer = $AnimationPlayer

@export var MAX_HEALTH: float = 100.0

# Setter for health basically changes the hp bar and plays a
# hurt animation whenever the health value is changed.
# May need to edit this code if we want to also allow healing.
var health: float = 100.0:
	set(value):
		health = value
		_update_hp_bar()
		_play_animation_hurt()

# Updates the HP bar percent value.
func _update_hp_bar():
	hp_bar.value = (health/MAX_HEALTH)*100

# Plays the white flashing effect when a character is attacked.
func _play_animation_hurt():
	anim_player.play("hurt")

# Shows the Focus, AKA the arrow pointing to a character.
func focus():
	_focus.show()

# Hides the Focus, AKA the arrow pointing to a character.
func unfocus():
	_focus.hide()

# Deals damage via subtraction
func take_damage(value):
	health -= value

# Specifically made for enemies to face the player characters, since
# enemies are on the right.
func flip_sprite():
	sprite.flip_h = true
