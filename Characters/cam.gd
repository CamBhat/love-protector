extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

func idle_right() -> void:
	animated_sprite_2d.play("idle_right")

func idle_down() -> void:
	animated_sprite_2d.play("idle_down")

func run_right() -> void:
	animated_sprite_2d.play("run_right")

func walk_right() -> void:
	animated_sprite_2d.play("walk_right")

func interact() -> void:
	animated_sprite_2d.play("interact")

func pickup_down() -> void:
	animated_sprite_2d.play("pickup_down")
