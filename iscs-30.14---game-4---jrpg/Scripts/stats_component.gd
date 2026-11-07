class_name StatsComponent
extends Node

@export var max_health: float = 100
@export var attack: int = 10
@export var defense: int = 5
@export var speed: int = 10
@export var crit_rate: float = 0.1
@export var crit_damage: float = 1.25

signal no_health

var current_health: float = max_health:
	set(value):
		current_health = value
		if current_health==0:
			no_health.emit()

var current_attack: int = attack
var current_crit_rate: float = crit_rate
var current_crit_damage: float = crit_damage
var block: int = 0


func reset_stats():
	current_attack = attack
	current_crit_rate = crit_rate
	current_crit_damage = crit_damage
	block = 0
	
