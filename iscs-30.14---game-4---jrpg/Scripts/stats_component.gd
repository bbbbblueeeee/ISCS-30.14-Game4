class_name StatsComponent
extends Node

@export var max_health: float = 100
@export var attack: int = 10
@export var defense: int = 5
@export var speed: int = 10
@export var crit_rate: float = 0.25
@export var crit_damage: float = 1.50


var current_health: float = max_health:
	set(value):
		current_health = value
		health_changed.emit()
		if current_health==0:
			no_health.emit()

signal health_changed
signal no_health
