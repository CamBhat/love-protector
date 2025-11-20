extends Control
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var game_timer: Timer = %GameTimer
@onready var intro_cutscene: Node = %IntroCutscene
@onready var ending_cutscene: Node = %EndingCutscene
@onready var combat_bg: AudioStreamPlayer2D = %CombatBG

var intro_complete: bool = false
var combat_started: bool = false
var ending_started: bool = false
var game_time: float = 20.0
var timer_started: bool = false  # Track if timer has started

func _ready() -> void:
	intro_cutscene.cutscene_started.connect(_on_cutscene_started)
	intro_cutscene.cutscene_ended.connect(_on_cutscene_ended)
	
	progress_bar.max_value = game_time
	progress_bar.value = 0.0
	
	game_timer.one_shot = true
	game_timer.set_wait_time(game_time)

func _process(delta: float) -> void:
	if timer_started and game_timer.time_left > 0:
		progress_bar.value = game_time - game_timer.time_left
	elif timer_started and game_timer.time_left <= 0:
		progress_bar.value = game_time
	
	if game_timer.time_left == 0.0 and get_tree().get_node_count_in_group("enemy") == 0 and intro_complete and not ending_started:
		ending_started = true
		ending_cutscene.start_ending_cutscene()
	
	if combat_started and combat_bg.playing == false:
		combat_bg.play()

func _on_cutscene_started() -> void:
	game_timer.paused = true

func _on_cutscene_ended() -> void:
	game_timer.paused = false
	if game_timer.is_stopped():
		game_timer.start()
		timer_started = true  # Mark timer as started
	intro_complete = true
	combat_started = true

# When this ends, end game
func _on_game_timer_timeout() -> void:
	progress_bar.value = game_time
	print("Game Over!")
