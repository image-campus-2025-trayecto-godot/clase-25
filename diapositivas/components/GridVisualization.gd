@tool
extends Control
class_name GridVisualization

# Exported properties for easy customization
@export var grid_spacing: float = 30.0 : set = set_grid_spacing
@export var grid_color: Color = Color(0.4, 0.4, 0.4, 0.6) : set = set_grid_color
@export var axis_color: Color = Color(0.8, 0.8, 0.8, 0.8) : set = set_axis_color
@export var coordinate_range: int = 4 : set = set_coordinate_range
@export var show_coordinate_labels: bool = true : set = set_show_coordinate_labels
@export var coordinate_label_color: Color = Color.WHITE : set = set_coordinate_label_color

# Vector drawing data
var vectors_to_draw: Array[VectorDrawData] = []

# Data structure for vector drawing
class VectorDrawData:
	var start_position: Vector2
	var vector: Vector2
	var color: Color
	var label: String
	
	func _init(start: Vector2, vec: Vector2, col: Color, lbl: String):
		start_position = start
		vector = vec
		color = col
		label = lbl

func _ready():
	# Connect draw signal
	draw.connect(_draw_visualization)

func _draw_visualization():
	var size = get_size()
	var center = size / 2
	
	# Draw grid and axes
	_draw_grid_and_axes(size, center)
	
	# Draw all registered vectors
	for vector_data in vectors_to_draw:
		_draw_vector(vector_data.start_position, vector_data.vector, vector_data.color, vector_data.label, center)

func _draw_grid_and_axes(size: Vector2, center: Vector2):
	# Draw grid lines
	var start_x = fmod(center.x, grid_spacing)
	while start_x <= size.x:
		draw_line(Vector2(start_x, 0), Vector2(start_x, size.y), grid_color, 1)
		start_x += grid_spacing
	
	var start_y = fmod(center.y, grid_spacing)
	while start_y <= size.y:
		draw_line(Vector2(0, start_y), Vector2(size.x, start_y), grid_color, 1)
		start_y += grid_spacing
	
	# Draw axes
	draw_line(Vector2(center.x, 0), Vector2(center.x, size.y), axis_color, 2)
	draw_line(Vector2(0, center.y), Vector2(size.x, center.y), axis_color, 2)
	
	# Draw coordinate labels if enabled
	if show_coordinate_labels:
		_draw_coordinate_labels(size, center)

func _draw_coordinate_labels(size: Vector2, center: Vector2):
	for i in range(-coordinate_range, coordinate_range + 1):
		if i == 0:
			continue
			
		var x_pos = center.x + i * grid_spacing
		var y_pos = center.y + i * grid_spacing
		
		# X-axis labels
		if x_pos >= 0 and x_pos <= size.x:
			draw_string(get_theme_default_font(), Vector2(x_pos - 8, center.y + 18), str(i), HORIZONTAL_ALIGNMENT_CENTER, -1, 12, coordinate_label_color)
		
		# Y-axis labels (negative because screen Y is inverted)
		if y_pos >= 0 and y_pos <= size.y:
			draw_string(get_theme_default_font(), Vector2(center.x - 18, y_pos + 4), str(-i), HORIZONTAL_ALIGNMENT_CENTER, -1, 12, coordinate_label_color)

func _draw_vector(start: Vector2, vector: Vector2, color: Color, label: String, center_offset: Vector2):
	var start_pos = center_offset + start * grid_spacing
	var end_pos = center_offset + (start + vector) * grid_spacing
	
	# Draw vector line
	draw_line(start_pos, end_pos, color, 4)
	
	# Draw arrowhead
	if vector.length() > 0.01:
		var direction = (end_pos - start_pos).normalized()
		var arrow_size = 10
		var arrow_angle = 0.5
		
		var arrow_point1 = end_pos - direction.rotated(arrow_angle) * arrow_size
		var arrow_point2 = end_pos - direction.rotated(-arrow_angle) * arrow_size
		
		draw_line(end_pos, arrow_point1, color, 4)
		draw_line(end_pos, arrow_point2, color, 4)
	
	# Draw label
	var label_pos = end_pos + Vector2(8, -8)
	draw_string(get_theme_default_font(), label_pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, color)

# Public API for adding vectors to draw
func add_vector(start_position: Vector2, vector: Vector2, color: Color, label: String = ""):
	vectors_to_draw.append(VectorDrawData.new(start_position, vector, color, label))

func clear_vectors():
	vectors_to_draw.clear()

func redraw():
	queue_redraw()

# Property setters that trigger redraw
func set_grid_spacing(value: float):
	grid_spacing = value
	queue_redraw()

func set_grid_color(color: Color):
	grid_color = color
	queue_redraw()

func set_axis_color(color: Color):
	axis_color = color
	queue_redraw()

func set_coordinate_range(value: int):
	coordinate_range = value
	queue_redraw()

func set_show_coordinate_labels(value: bool):
	show_coordinate_labels = value
	queue_redraw()

func set_coordinate_label_color(color: Color):
	coordinate_label_color = color
	queue_redraw()
