extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func flip_sprite():
	sprite.flip_h = true
