extends CharacterBody2D
@export var walk_speed: float = 25.0
@export var run_speed: float = 100.0
@export var max_health: float = 10.0
@export var projectile_scene: PackedScene
var has_shot_this_cycle: bool = false
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var progress_bar: ProgressBar = %ProgressBar
var current_health: float
var is_attacking: bool = false
var attack_frame_reached: bool = false
enum facing_direction { RIGHT, LEFT, UP, DOWN }
var last_direction = facing_direction.DOWN
@onready var shoot: AudioStreamPlayer2D = $Shoot

func _ready() -> void:
	set_health(max_health)
	progress_bar.max_value = max_health
	animated_sprite_2d.frame_changed.connect(_on_frame_changed)

func _physics_process(delta: float) -> void:
	var direction: Vector2
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_up", "move_down")
	if direction.length() > 1.0:
		direction = direction.normalized()
	velocity = direction * run_speed
	
	if direction.x != 0:
		animated_sprite_2d.flip_h = direction.x < 0
	
	if Input.is_action_pressed("shoot") and not is_attacking:
		start_attack()
	
	if is_attacking:
		# Calculate direction to mouse
		var mouse_pos = get_global_mouse_position()
		var direction_to_mouse = global_position.direction_to(mouse_pos)
		
		# Flip sprite based on horizontal direction
		animated_sprite_2d.flip_h = direction_to_mouse.x < 0
		
		# Determine which animation based on which direction is stronger
		var target_animation = ""
		if abs(direction_to_mouse.x) > abs(direction_to_mouse.y):
			# Horizontal is stronger
			target_animation = "attack_right"
		else:
			# Vertical is stronger
			if direction_to_mouse.y > 0:
				target_animation = "attack_down"
			else:
				target_animation = "attack_up"
				
		# If switching animations and already jittering, start new animation at frame 1
		if target_animation != animated_sprite_2d.animation:
			animated_sprite_2d.play(target_animation)
			if attack_frame_reached:
				animated_sprite_2d.frame = 1
		else:
			# Same animation, just make sure it's playing (don't restart it)
			if not animated_sprite_2d.is_playing():
				animated_sprite_2d.play(target_animation)
				
		# Handle jitter if button held and frame 1+ reached
		if Input.is_action_pressed("shoot") and attack_frame_reached:
			if animated_sprite_2d.frame >= 3:
				animated_sprite_2d.frame = 1
	
	# Is Moving
	elif not is_attacking:
		if velocity != Vector2.ZERO:
			if direction.x > 0:
				animated_sprite_2d.play("run_right")
				last_direction = facing_direction.RIGHT
			elif direction.x < 0:
				animated_sprite_2d.play("run_right")
				last_direction = facing_direction.LEFT
			elif direction.y > 0 and direction.x == 0:
				animated_sprite_2d.play("run_down")
				last_direction = facing_direction.DOWN
			elif direction.y < 0 and direction.x == 0:
				animated_sprite_2d.play("run_up")
				last_direction = facing_direction.UP
		else:
			match last_direction:
				facing_direction.RIGHT:
					animated_sprite_2d.play("idle_right")
				facing_direction.LEFT:
					animated_sprite_2d.play("idle_right")
				facing_direction.DOWN:
					animated_sprite_2d.play("idle_down")
				facing_direction.UP:
					animated_sprite_2d.play("idle_up")
	
	move_and_slide()

func start_attack() -> void:
	is_attacking = true
	attack_frame_reached = false

func _on_frame_changed() -> void:
	if is_attacking and animated_sprite_2d.frame == 1:
		spawn_projectile()
		attack_frame_reached = true

func spawn_projectile() -> void:
	if projectile_scene == null:
		return
	
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	
	# Shoot toward mouse
	var mouse_pos = get_global_mouse_position()
	var shoot_direction = global_position.direction_to(mouse_pos)
	
	projectile.initialize(global_position, shoot_direction)
	
	shoot.play()

func set_health(new_health: float) -> void:
	current_health = new_health
	progress_bar.value = current_health
	if current_health <= 0:
		die()

func damage(damage: float) -> void:
	set_health(current_health - damage)

func die() -> void:
	set_physics_process(false)
	progress_bar.visible = false
	remove_from_group("player")
	match last_direction:
		facing_direction.RIGHT:
			animated_sprite_2d.play("death_right")
		facing_direction.LEFT:
			animated_sprite_2d.play("death_right")
		facing_direction.DOWN:
			animated_sprite_2d.play("death_down")
		facing_direction.UP:
			animated_sprite_2d.play("death_up")

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation in ["attack_right", "attack_up", "attack_down"]:
		is_attacking = false
		attack_frame_reached = false
