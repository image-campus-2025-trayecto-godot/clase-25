extends Node2D

var direction_it_is_looking_at: Vector2 = Vector2.LEFT
var sight_range: float = 500.0
@onready var sprite_2d: Sprite2D = $"../Sprite2D"
@onready var dot_product: Label = $"../DotProduct"

func is_player_in_sight() -> bool:
	var vector_to_player = sprite_2d.global_position - global_position
	var dot_product_result = direction_it_is_looking_at.normalized().dot(vector_to_player.normalized())
	return dot_product_result > 0.9 && vector_to_player.length() < sight_range

func _process(delta: float) -> void:
	direction_it_is_looking_at = direction_it_is_looking_at.rotated(delta * PI / 8)
	var vector_to_player = sprite_2d.global_position - global_position
	var dot_product_result = direction_it_is_looking_at.normalized().dot(vector_to_player.normalized())
	dot_product.text = "Dot product: %f" % dot_product_result
	dot_product.text += "\nAngle between vectors: %f" % rad_to_deg(direction_it_is_looking_at.normalized().angle_to(vector_to_player.normalized()))
	if is_player_in_sight():
		modulate = Color.ORANGE
	else:
		modulate = Color.WHITE
	queue_redraw()

func _draw() -> void:
	draw_line(Vector2.ZERO, direction_it_is_looking_at * sight_range, Color.RED, 10.0)
	draw_line(Vector2.ZERO, sprite_2d.global_position - global_position, Color.CYAN, 10.0)
