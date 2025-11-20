extends Node
signal cutscene_started
signal cutscene_ended
@export var cam: CharacterBody2D
@export var player: CharacterBody2D
@onready var dialogue_box: Label = %DialogueBox
@onready var heart: Sprite2D = %Heart
@onready var fade_overlay: ColorRect = %FadeOverlay  # ADD THIS - you'll need to create this node
@onready var text_typing: AudioStreamPlayer2D = %TextTyping

var cutscene_active: bool = false

func start_ending_cutscene() -> void:
	cutscene_active = true
	cutscene_started.emit()
	
	# Disable player movement
	player.set_physics_process(false)
	
	cam.idle_down()
	
	await show_dialogue("It's finally finished!")
	await show_dialogue("I've created something so perfect.")
	await show_dialogue("(Not as perfect as you of course)")
	await show_dialogue("I've created a way to show you how much I love you.")
	await present_love()
	await fade_to_black()
	
	# End cutscene
	cutscene_active = false
	player.set_physics_process(true)
	cutscene_ended.emit()

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

func present_love() -> void:
	cam.pickup_down()
	await get_tree().create_timer(0.5).timeout
	heart.show()
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(heart, "scale", Vector2(1.0, 1.0), 1.0)
	tween.tween_property(heart, "global_position", heart.global_position + Vector2(0, -20), 1.0)
	await tween.finished
	await get_tree().create_timer(2).timeout

func fade_to_black() -> void:
	var tween = create_tween()
	tween.tween_property(fade_overlay, "color:a", 1.0, 2.0)
	await tween.finished
