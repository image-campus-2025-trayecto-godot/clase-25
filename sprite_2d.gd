extends Sprite2D

const SPEED = 100

@onready var current_speed: Label = $"../CurrentSpeed"

func _physics_process(delta: float) -> void:
	var horizontal_movement = Vector2(1, 0) * Input.get_axis("move_left", "move_right")
	var vertical_movement = Vector2(0, 1) * Input.get_axis("move_up", "move_down")
	var direction = (horizontal_movement + vertical_movement).normalized()

	var velocity = direction * SPEED
	
	global_position += velocity * delta

	current_speed.text = "Current speed: %.2f" % velocity.length()
