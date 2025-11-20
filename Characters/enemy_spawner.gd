extends Node
@export var enemies: Array[PackedScene]
@export var spawners: Array[Marker2D]
@onready var timer: Timer = %Timer
@onready var game_timer: Timer = %GameTimer
@onready var intro_cutscene: Node = %IntroCutscene

# Configuration for spawn rate scaling
@export var min_spawn_time: float = 0.5  # Fastest spawn rate
@export var max_spawn_time: float = 2.0  # Slowest spawn rate

func _ready() -> void:
	intro_cutscene.cutscene_started.connect(_on_cutscene_started)
	intro_cutscene.cutscene_ended.connect(_on_cutscene_ended)

func get_current_spawn_time() -> float:
	# Calculate spawn time based on game timer progress
	# As time_left decreases, spawn_time decreases (spawns get faster)
	var time_ratio = game_timer.time_left / game_timer.wait_time
	return lerp(min_spawn_time, max_spawn_time, time_ratio)

func _on_cutscene_started() -> void:
	timer.set_wait_time(0.0)

func _on_cutscene_ended() -> void:
	timer.set_wait_time(max_spawn_time)
	timer.start()

func _on_timer_timeout() -> void:
	if game_timer.is_stopped():
		return
	
	# Spawn enemy
	var rand_enemy = randi_range(0, enemies.size() - 1)
	var new_enemy = enemies[rand_enemy].instantiate()
	var rand_spawner = randi_range(0, spawners.size() - 1)
	spawners[rand_spawner].add_child(new_enemy)
	new_enemy.global_position = spawners[rand_spawner].global_position
	
	# Update timer with new spawn time based on remaining game time
	var spawn_time = get_current_spawn_time()
	timer.set_wait_time(spawn_time)
	timer.start()
