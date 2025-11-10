@tool
extends WithActionList

@onready var dot_product_label = $DotProductLabel
@onready var vector_a: Line2D = $OriginPoint/VectorA
@onready var vector_b: Line2D = $OriginPoint/VectorB
@onready var origin_point: Control = $OriginPoint
@onready var contenido: RichTextLabel = $MarginContainer/VBoxContainer/Contenido

func entrar():
	contenido.visible_ratio = 0.5

func _ready() -> void:
	action_list.actions = [
		Action.change_property(
			contenido,
			"visible_ratio",
			1.0
		)
	]

func _process(delta: float) -> void:
	var vector_a_versor: Vector2 = vector_a.vector().normalized()
	var vector_b_versor: Vector2 = vector_b.vector().normalized()
	var vector_a_text: String = "%s: %.3v" % [vector_a.vector_name, vector_a_versor]
	var vector_b_text: String = "%s: %.3v" % [vector_b.vector_name, vector_b_versor]
	var angle: String = "Θ: %.3f" % [rad_to_deg(vector_a_versor.angle_to(vector_b_versor))]
	var text: String = "%s . %s = %.3f * %.3f + %.3f * %.3f = %.3f" % [
		vector_a.vector_name,
		vector_b.vector_name,
		vector_a_versor.x,
		vector_b_versor.x,
		vector_a_versor.y,
		vector_b_versor.y,
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
