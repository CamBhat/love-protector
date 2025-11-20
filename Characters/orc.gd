extends CharacterBody2D

@export var speed: float = 30.0
@export var max_health: float = 10.0

@onready var player = get_node("/root/Game/Player")
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var timer: Timer = %Timer
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var death_timer: Timer = %DeathTimer
@onready var hitbox: CollisionShape2D = %Hitbox
@onready var hurtbox: CollisionShape2D = %Hurtbox
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var hitbox_area: Area2D = $Hitbox
@onready var hurt: AudioStreamPlayer2D = %Hurt
@onready var death: AudioStreamPlayer2D = %Death
@onready var axe_swish: AudioStreamPlayer2D = %AxeSwish

var current_health: float
var damageable: bool = false
var damage: float = 1.0

enum State { PURSUING, ATTACKING, DEAD, HURT }
var current_state = State.PURSUING

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
			axe_swish.play()
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

	if direction.x < 0:
		hurtbox.position.x = hurtbox.position.x * -1
		animated_sprite_2d.flip_h = true
	else:
		hurtbox.position.x = hurtbox.position.x * -1
		animated_sprite_2d.flip_h = false
	
	
	move_and_slide()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		current_state = State.ATTACKING
		timer.start()
		damageable = true

func _on_hurtbox_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		damageable = false

func _on_animated_sprite_2d_animation_finished() -> void:
	if current_state == State.ATTACKING:
		current_state = State.PURSUING
	if current_state == State.HURT:
		current_state = State.PURSUING


func _on_timer_timeout() -> void:
	if damageable:
		player.damage(damage)

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
	call_deferred("hurtbox.disabled", true)
	call_deferred("collision_shape_2d.disabled", true)
	hitbox_area.set_collision_layer(0)
	hitbox_area.set_collision_mask(0)
	set_collision_layer(0)
	set_collision_mask(0)
	death_timer.start()


func _on_death_timer_timeout() -> void:
	queue_free()
