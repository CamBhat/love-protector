extends Area2D

@export var speed: float = 300.0
@export var damage: float = 2.0
var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
	# Create collision shape
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 4
	collision.shape = shape
	add_child(collision)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	# Auto-destroy after going offscreen far enough
	if global_position.length() > 2000:
		queue_free()

func initialize(start_pos: Vector2, target_direction: Vector2) -> void:
	global_position = start_pos
	rotation = global_position.angle_to_point(get_global_mouse_position())
	direction = target_direction.normalized()

func _on_area_entered(area: Area2D) -> void:
	print("Bullet hit area: ", area.name)
	print("Parent: ", area.get_parent().name)
	print("Parent has take_damage: ", area.get_parent().has_method("take_damage"))
	
	# Hit an enemy
	if area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(damage)
	queue_free()
