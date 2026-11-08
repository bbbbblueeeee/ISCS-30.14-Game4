extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _focus: AnimatedSprite2D = $focus
@onready var hp_bar: ProgressBar = $ProgressBar
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var stats: StatsComponent = $StatsComponent

@export var title: String

var is_alive: bool = true

signal damage_taken(text: String)
signal damage_blocked(text: String)
signal just_died

func _ready() -> void:
	pass

func update_hp_bar():
	hp_bar.value = (stats.current_health/stats.max_health)*100

func play_animation_hurt():
	sprite.play("hurt")
	anim_player.play("hurt")

func update_attack(dmg: int):
	stats.current_attack = dmg
	
func update_defense(def: int):
	stats.defense += def
	
func update_critrate(rt: float):
	stats.current_crit_rate += rt
	
func update_critdamage(dmg: float):
	stats.current_crit_damage += dmg

func update_speed(spd: int):
	stats.speed += spd

func reset_stats():
	stats.reset_stats()

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
	if is_alive:
		stats.current_health -= value - stats.block
		
		if value > stats.block:
			if stats.block != 0:
				damage_blocked.emit(title+" blocked "+str(stats.block)+" DAMAGE.")
			damage_taken.emit(title+" took "+str(clamp(value - stats.block,0,100))+" DAMAGE.")
			stats.block = 0
		else:
			damage_blocked.emit(title+" blocked "+str(value)+" DAMAGE.")
			damage_taken.emit(title+" took "+str(clamp(value - stats.block,0,100))+" DAMAGE.")
			stats.block -= value
		update_hp_bar()
		await get_tree().create_timer(0.5).timeout
		play_animation_hurt()

func heal(value):
	stats.current_health += value
	update_hp_bar()
	print("got healed for "+str(value))

# Specifically made for enemies to face the player characters, since
# enemies are on the right.
func flip_sprite():
	sprite.flip_h = true


func _on_animation_finished() -> void:
	if is_alive:
		sprite.play("idle")


func _on_no_health() -> void:
	sprite.play("death")
	sprite.modulate=Color.DIM_GRAY
	is_alive = false
	just_died.emit()
