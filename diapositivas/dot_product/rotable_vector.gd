@tool
extends Line2D

@onready var vector_name_label: Label = $VectorName
@export var vector_name: String:
	set(new_value):
		vector_name = new_value
		if not is_node_ready():
			await ready
			vector_name_label.text = vector_name
var being_dragged: bool = false

func _ready():
	vector_name_label.text = vector_name	

func vector() -> Vector2:
	return (points[1] - points[0]).rotated(rotation)

func _contains_point(global_point: Vector2) -> bool:
	var size = Vector2(points[1].x - points[0].x, width)
	var line_rect: Rect2 = Rect2(Vector2.UP * (size / 2), size)
	return line_rect.has_point(to_local(global_point)) 

func _input(event: InputEvent) -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT and _contains_point(mouse_position):
			being_dragged = true
			get_viewport().set_input_as_handled()

func _process(_delta: float) -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		being_dragged = false

	if being_dragged:
		look_at(get_global_mouse_position())
		default_color = Color.GREEN
	elif _contains_point(mouse_position):
		default_color = Color.ORANGE
	else:
		default_color = Color.WHITE
