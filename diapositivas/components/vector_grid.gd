@tool
extends Control
class_name VectorGrid

@export_category("Grid Settings")
@export_range(10, 100, 5) var grid_spacing: float = 30.0
@export_range(1, 10, 1) var coordinate_range: int = 5
@export_range(8, 32, 2) var font_size: int = 12

@export_category("Grid Colors")
@export var grid_color: Color = Color(0.4, 0.4, 0.4, 0.6)
@export var axis_color: Color = Color(0.8, 0.8, 0.8, 0.8)
@export var coordinate_label_color: Color = Color.WHITE

@export_category("Debug")
@export_tool_button("Redraw Grid") var _redraw_button = func():
	queue_redraw()

func _ready():
	custom_minimum_size = Vector2(200, 200)

func _draw():
	_draw_grid()

func _draw_grid():
	var size = get_size()
	var center = size / 2
	
	# Draw grid lines
	_draw_grid_lines(size, center)
	
	# Draw axes
	_draw_axes(size, center)
	
	# Draw coordinate labels
	_draw_coordinate_labels(center)

func _draw_grid_lines(size: Vector2, center: Vector2):
	var grid_offset_x = fmod(center.x, grid_spacing)
	var grid_offset_y = fmod(center.y, grid_spacing)
	
	# Vertical grid lines
	var start_x = grid_offset_x
	while start_x <= size.x:
		draw_line(Vector2(start_x, 0), Vector2(start_x, size.y), grid_color, 1)
		start_x += grid_spacing
	
	# Horizontal grid lines
	var start_y = grid_offset_y
	while start_y <= size.y:
		draw_line(Vector2(0, start_y), Vector2(size.x, start_y), grid_color, 1)
		start_y += grid_spacing

func _draw_axes(size: Vector2, center: Vector2):
	draw_line(Vector2(center.x, 0), Vector2(center.x, size.y), axis_color, 2)
	draw_line(Vector2(0, center.y), Vector2(size.x, center.y), axis_color, 2)

func _draw_coordinate_labels(center: Vector2):
	for i in range(-coordinate_range, coordinate_range + 1):
		if i == 0:
			continue
			
		var x_pos = center.x + i * grid_spacing
		var y_pos = center.y + i * grid_spacing
		
		# X-axis labels
		if x_pos >= 0 and x_pos <= size.x:
			draw_string(get_theme_default_font(), Vector2(x_pos - 5, center.y + 15), str(i), HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, coordinate_label_color)
		
		# Y-axis labels (negative because screen Y is inverted)
		if y_pos >= 0 and y_pos <= size.y:
			draw_string(get_theme_default_font(), Vector2(center.x - 15, y_pos + 3), str(-i), HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, coordinate_label_color)

# Helper functions for drawing vectors
func draw_vector(start: Vector2, vector: Vector2, color: Color, label: String = ""):
	var center = get_size() / 2
	var start_pos = center + start * grid_spacing
	var end_pos = center + (start + vector) * grid_spacing
	
	# Draw vector line
	draw_line(start_pos, end_pos, color, 3)
	
	# Draw arrowhead
	if vector.length() > 0.01:
		var direction = (end_pos - start_pos).normalized()
		var arrow_size = 8
		var arrow_angle = 0.5
		
		var arrow_point1 = end_pos - direction.rotated(arrow_angle) * arrow_size
		var arrow_point2 = end_pos - direction.rotated(-arrow_angle) * arrow_size
		
		draw_line(end_pos, arrow_point1, color, 3)
		draw_line(end_pos, arrow_point2, color, 3)
	
	# Draw label if provided
	if label != "":
		var label_pos = end_pos + Vector2(5, -5)
		draw_string(get_theme_default_font(), label_pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size + 2, color)

func draw_dashed_line(start: Vector2, end: Vector2, color: Color, width: float = 2.0):
	var center = get_size() / 2
	var start_pos = center + start * grid_spacing
	var end_pos = center + end * grid_spacing
	
	var direction = (end_pos - start_pos).normalized()
	var distance = start_pos.distance_to(end_pos)
	var dash_length = 8.0
	var gap_length = 4.0
	var total_length = dash_length + gap_length
	
	var current_pos = start_pos
	var traveled = 0.0
	
	while traveled < distance:
		var remaining = distance - traveled
		var segment_length = min(dash_length, remaining)
		var segment_end = current_pos + direction * segment_length
		
		draw_line(current_pos, segment_end, color, width)
		
		traveled += total_length
		current_pos += direction * total_length
