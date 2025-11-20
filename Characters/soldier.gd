extends CharacterBody2D

@export var speed: float = 30.0
@export var max_health: float = 10.0
@export var attack_radius: float = 100.0
@export var arrow: PackedScene

@onready var player = get_node("/root/Game/Player")
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var timer: Timer = %Timer
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var death_timer: Timer = %DeathTimer
@onready var hitbox: CollisionShape2D = %Hitbox
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var hitbox_area: Area2D = $Hitbox
@onready var marker_2d: Marker2D = %Marker2D
@onready var hurt: AudioStreamPlayer2D = %Hurt
@onready var death: AudioStreamPlayer2D = %Death
@onready var arrow_shot: AudioStreamPlayer2D = %ArrowShot

var current_health: float
var damageable: bool = false
var damage: float = 1.0

enum State { PURSUING, ATTACKING, DEAD, HURT }
var current_state = State.PURSUING
var facing_direction: String = "right"

func _ready() -> void:
	set_health(max_health)
	progress_bar.max_value = max_health
	

func _physics_process(delta: float) -> void:
	if player == null:
		return
	
	if not player.is_in_group("player"):
		animated_sprite_2d.play("idle")
		return
	
	if current_state == State.ATTACKING:
		velocity = Vector2.ZERO
		# Only start attack animation if not already playing
		if animated_sprite_2d.animation != "attack":
			animated_sprite_2d.play("attack")
		move_and_slide()
		return  # stop pursuing
	
	if current_state == State.HURT:
		return
	
	# PURSUING state
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	
	if velocity.length() > 0.1:
		animated_sprite_2d.play("walk")
	else:
		animated_sprite_2d.play("idle")
	
	if direction.x > 0 and facing_direction == "left":
		marker_2d.position.x = marker_2d.position.x * -1
		animated_sprite_2d.flip_h = false
		facing_direction = "right"
	elif direction.x < 0 and facing_direction == "right":
		marker_2d.position.x = marker_2d.position.x * -1
		animated_sprite_2d.flip_h = true
		facing_direction = "left"
		
	var distance_to_player = global_position.distance_to(player.global_position)
	if distance_to_player <= attack_radius:
		attack()
	
	move_and_slide()

func _on_animated_sprite_2d_animation_finished() -> void:
	if current_state == State.ATTACKING:
		current_state = State.PURSUING
	if current_state == State.HURT:
		current_state = State.PURSUING


func _on_timer_timeout() -> void:
	if damageable:
		player.damage(damage)

func attack() -> void:
	animated_sprite_2d.play("attack")
	current_state = State.ATTACKING

func spawn_arrow() -> void:
	var new_arrow = arrow.instantiate()
	add_child(new_arrow)
	new_arrow.global_position = marker_2d.global_position
	# Points at center of player (About 5 px from origin)
	new_arrow.rotation = marker_2d.global_position.angle_to_point(player.global_position + Vector2(0, -5))
	arrow_shot.play()

func take_damage(dmg: float) -> void:
	if current_state == State.DEAD:
		return  # Ignore damage when already dead
	animated_sprite_2d.play("hurt")
	hurt.play()
	current_state = State.HURT
	set_health(current_health - dmg)

func set_health(new_health: float) -> void:
	current_health = new_health
	progress_bar.value = current_health
	if current_health <= 0:
		die()

func die() -> void:
	current_state = State.DEAD
	animated_sprite_2d.play("death")
	death.play()
	set_physics_process(false)
	progress_bar.visible = false
	call_deferred("hitbox.disabled", true)
	call_deferred("collision_shape_2d.disabled", true)
	hitbox_area.set_collision_layer(0)
	hitbox_area.set_collision_mask(0)
	set_collision_layer(0)
	set_collision_mask(0)
	death_timer.start()


func _on_death_timer_timeout() -> void:
	queue_free()


func _on_animated_sprite_2d_frame_changed() -> void:
	if current_state == State.ATTACKING and animated_sprite_2d.frame == 7:
		spawn_arrow()
