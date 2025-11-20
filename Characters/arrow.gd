extends Area2D

const SPEED: float = 100.0
const RANGE: float = 500.0

var damage: float = 1.0

var distance_travelled: float = 0.0

func _physics_process(delta: float) -> void:
	position += transform.x * SPEED * delta
	distance_travelled += SPEED * delta
	if distance_travelled >= RANGE:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	var player = area.get_parent()
	if player.is_in_group("player") and player.has_method("damage"):
		queue_free()
		player.damage(damage)
