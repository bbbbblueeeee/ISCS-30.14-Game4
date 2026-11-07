class_name StatsComponent
extends Node

@export var max_health: float = 100
@export var attack: int = 10
@export var defense: int = 5
@export var speed: int = 10
@export var crit_rate: float = 0.05
@export var crit_damage: float = 1.25

var current_health: float = max_health:
	set(value):
		current_health = value
		health_changed.emit()
		if current_health==0:
			no_health.emit()

var block: int = 0

signal health_changed
signal no_health

func reset_base_stats():
	max_health = 100
	attack = 10
	defense = 5
	speed = 10
	crit_rate = 0.05
	crit_damage = 1.25
