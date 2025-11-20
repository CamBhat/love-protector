extends Node

signal cutscene_started
signal cutscene_ended

@export var cam: CharacterBody2D
@export var player: CharacterBody2D

@onready var dialogue_box: Label = %DialogueBox
@onready var work_position: Marker2D = $WorkPosition  # Where Cam works
@onready var speak_position: Marker2D = %SpeakPosition
@onready var text_typing: AudioStreamPlayer2D = %TextTyping
@onready var intro_bg: AudioStreamPlayer2D = %IntroBG

var cutscene_active: bool = false

func _ready() -> void:
	dialogue_box.hide()
	start_intro_cutscene()

func start_intro_cutscene() -> void:
	cutscene_active = true
	cutscene_started.emit()
	
	# Disable player movement
	player.set_physics_process(false)
	
	# Start the sequence
	intro_bg.play()
	
	await cam_runs_in()
	await show_dialogue("Hey Babu! I need your help while I work on something.")
	await show_dialogue("Use WASD to move and click to shoot! You can check my progress above me..")
	await show_dialogue("I love you sooo much!!")
	await cam_goes_to_work()
	
	intro_bg.stop()
	
	# End cutscene
	cutscene_active = false
	player.set_physics_process(true)
	cutscene_ended.emit()

func cam_runs_in() -> void:
	# Cam starts off-screen

	# Move to center over 2 seconds
	var tween = create_tween()
	tween.tween_property(cam, "global_position", speak_position.global_position, 2.0)
	cam.run_right()
	await tween.finished
	cam.idle_right()

func show_dialogue(text: String) -> void:
	dialogue_box.show()
	dialogue_box.text = ""
	
	var full_text = text
	
	# Start typing sound
	text_typing.play()
	
	# Typewriter effect - reveal one character at a time
	for i in range(full_text.length()):
		dialogue_box.text += full_text[i]
		await get_tree().create_timer(0.05).timeout  # Adjust speed here
	
	# Stop typing sound when done
	text_typing.stop()
	
	# Wait for player to press a key or wait 3 seconds
	await get_tree().create_timer(3.0).timeout
	dialogue_box.hide()

func cam_goes_to_work() -> void:
	# Move Cam to work position
	var tween = create_tween()
	tween.tween_property(cam, "global_position", work_position.global_position, 1.5)
	cam.walk_right()
	
	var audio_tween = create_tween()
	audio_tween.tween_property(intro_bg, "volume_db", -80, 5.0)
	
	await tween.finished
	cam.interact()
