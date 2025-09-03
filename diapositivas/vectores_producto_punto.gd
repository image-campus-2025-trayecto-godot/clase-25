@tool
extends Control

@onready var dot_product_label = $DotProductLabel
@onready var vector_a: Line2D = $OriginPoint/VectorA
@onready var vector_b: Line2D = $OriginPoint/VectorB
@onready var origin_point: Control = $OriginPoint

func _process(delta: float) -> void:
	var vector_a_versor: Vector2 = vector_a.vector().normalized()
	var vector_b_versor: Vector2 = vector_b.vector().normalized()
	var vector_a_text: String = "%s: %.2v" % [vector_a.vector_name, vector_a_versor]
	var vector_b_text: String = "%s: %.2v" % [vector_b.vector_name, vector_b_versor]
	var angle: String = "Θ: %.2f" % [rad_to_deg(vector_a_versor.angle_to(vector_b_versor))]
	var text: String = "%s . %s = %.4f" % [
		vector_a.vector_name,
		vector_b.vector_name,
		vector_a_versor.dot(vector_b_versor)
	]
	dot_product_label.text = "\n".join([
		vector_a_text,
		vector_b_text,
		angle,
		text
	])
	queue_redraw()

func _draw() -> void:
	var vector_a_versor: Vector2 = vector_a.vector().normalized()
	var vector_b_versor: Vector2 = vector_b.vector().normalized()
	draw_arc(origin_point.position, 100, vector_a_versor.angle(), vector_b_versor.angle(), 50.0, Color.RED, 200.0)
