@tool
extends Control

@export_category("Debug")
@export_tool_button("Redraw") var _redraw_button = func():
	grid_lines.queue_redraw()
	vector_arrow.queue_redraw()
	_update_vector_display()

@export_category("Grid Settings")
@export_range(1, 100, 1) var GRID_SPACING: float = 30.0  # pixels per coordinate unit
@export_range(1, 100, 1) var COORDINATE_RANGE: int = 5
@export_range(1, 100, 1) var FONT_SIZE: int = 16

@export_category("Line Widths")
@export_range(1, 10, 1) var AXIS_LINE_WIDTH: int = 3
@export_range(1, 10, 1) var GRID_LINE_WIDTH: int = 1
@export_range(1, 10, 1) var VECTOR_LINE_WIDTH: int = 4
@export_range(1, 10, 1) var COMPONENT_LINE_WIDTH: int = 2

@export_category("Vector Settings")
@export_range(1, 100, 1) var ARROW_SIZE: float = 10.0
@export_range(1, 100, 1) var CORNER_SIZE: float = 15.0
@export_range(0.005, 0.5, 0.005) var MIN_VECTOR_THRESHOLD: float = 0.01

@export_category("Colors")
@export var GRID_COLOR: Color = Color.GRAY
@export var AXIS_COLOR: Color = Color.WHITE
@export var VECTOR_COLOR: Color = Color.RED
@export var COMPONENT_COLOR: Color = Color.CYAN
@export var RIGHT_ANGLE_COLOR: Color = Color.YELLOW
@export var COORDINATE_LABEL_COLOR: Color = Color.WHITE


# Node references
@onready var grid_lines = $VisualizacionContainer/VectorVisualization/GridLines
@onready var vector_arrow = $VisualizacionContainer/VectorVisualization/VectorArrow
@onready var x_slider = $MarginContainer/VBoxContainer/InteractiveControls/MarginContainer/VBoxContainer/XControl/XSlider
@onready var y_slider = $MarginContainer/VBoxContainer/InteractiveControls/MarginContainer/VBoxContainer/YControl/YSlider
@onready var x_value_label = $MarginContainer/VBoxContainer/InteractiveControls/MarginContainer/VBoxContainer/XControl/XValue
@onready var y_value_label = $MarginContainer/VBoxContainer/InteractiveControls/MarginContainer/VBoxContainer/YControl/YValue
@onready var result_label = $MarginContainer/VBoxContainer/InteractiveControls/ResultLabel

# Vector components
var vector_x: float = 3.0
var vector_y: float = 4.0

func _ready():
	if grid_lines:
		grid_lines.draw.connect(_draw_grid)
	if vector_arrow:
		vector_arrow.draw.connect(_draw_vector)
	
	if x_slider:
		x_slider.value_changed.connect(_on_x_slider_changed)
	if y_slider:
		y_slider.value_changed.connect(_on_y_slider_changed)
	
	_update_vector_display()

func _draw_grid():
	if not grid_lines:
		return
		
	var size = grid_lines.size
	var center = size / 2
	
	_draw_grid_lines(size, center)
	_draw_axes(size, center)
	_draw_coordinate_labels(center)

func _draw_grid_lines(size: Vector2, center: Vector2):
	var grid_offset_x = fmod(center.x, GRID_SPACING)
	var grid_offset_y = fmod(center.y, GRID_SPACING)
	
	# Draw vertical grid lines
	var start_x = grid_offset_x
	while start_x <= size.x:
		grid_lines.draw_line(Vector2(start_x, 0), Vector2(start_x, size.y), GRID_COLOR, GRID_LINE_WIDTH)
		start_x += GRID_SPACING
	
	# Draw horizontal grid lines
	var start_y = grid_offset_y
	while start_y <= size.y:
		grid_lines.draw_line(Vector2(0, start_y), Vector2(size.x, start_y), GRID_COLOR, GRID_LINE_WIDTH)
		start_y += GRID_SPACING

func _draw_axes(size: Vector2, center: Vector2):
	grid_lines.draw_line(Vector2(center.x, 0), Vector2(center.x, size.y), AXIS_COLOR, AXIS_LINE_WIDTH)
	grid_lines.draw_line(Vector2(0, center.y), Vector2(size.x, center.y), AXIS_COLOR, AXIS_LINE_WIDTH)

func _draw_coordinate_labels(center: Vector2):
	for i in range(-COORDINATE_RANGE, COORDINATE_RANGE + 1):
		if i == 0:
			continue
			
		var x_pos = center.x + i * GRID_SPACING
		var y_pos = center.y + i * GRID_SPACING
		
		# X-axis labels
		if x_pos >= 0 and x_pos <= grid_lines.size.x:
			grid_lines.draw_string(get_theme_default_font(), Vector2(x_pos - 5, center.y + 20), str(i), HORIZONTAL_ALIGNMENT_CENTER, -1, FONT_SIZE, COORDINATE_LABEL_COLOR)
		
		# Y-axis labels (negative because screen Y is inverted)
		if y_pos >= 0 and y_pos <= grid_lines.size.y:
			grid_lines.draw_string(get_theme_default_font(), Vector2(center.x - 20, y_pos + 5), str(-i), HORIZONTAL_ALIGNMENT_CENTER, -1, FONT_SIZE, COORDINATE_LABEL_COLOR)

func _draw_vector():
	if not vector_arrow:
		return
		
	var vector_end = Vector2(vector_x * GRID_SPACING, -vector_y * GRID_SPACING)
	
	if vector_end.length() > MIN_VECTOR_THRESHOLD:
		_draw_component_lines(vector_end)
		_draw_main_vector(vector_end)
		_draw_arrowhead(vector_end)
		_draw_right_angle_indicator(vector_end)

func _draw_component_lines(vector_end: Vector2):
	if abs(vector_x) > MIN_VECTOR_THRESHOLD:
		vector_arrow.draw_line(Vector2.ZERO, Vector2(vector_end.x, 0), COMPONENT_COLOR, COMPONENT_LINE_WIDTH)
	if abs(vector_y) > MIN_VECTOR_THRESHOLD:
		vector_arrow.draw_line(Vector2(vector_end.x, 0), vector_end, COMPONENT_COLOR, COMPONENT_LINE_WIDTH)

func _draw_main_vector(vector_end: Vector2):
	vector_arrow.draw_line(Vector2.ZERO, vector_end, VECTOR_COLOR, VECTOR_LINE_WIDTH)

func _draw_arrowhead(vector_end: Vector2):
	var angle = vector_end.angle()
	var arrow_point1 = vector_end + Vector2(cos(angle + 2.8), sin(angle + 2.8)) * ARROW_SIZE
	var arrow_point2 = vector_end + Vector2(cos(angle - 2.8), sin(angle - 2.8)) * ARROW_SIZE
	
	vector_arrow.draw_line(vector_end, arrow_point1, VECTOR_COLOR, VECTOR_LINE_WIDTH)
	vector_arrow.draw_line(vector_end, arrow_point2, VECTOR_COLOR, VECTOR_LINE_WIDTH)

func _draw_right_angle_indicator(vector_end: Vector2):
	if abs(vector_x) > MIN_VECTOR_THRESHOLD and abs(vector_y) > MIN_VECTOR_THRESHOLD:
		var sign_x = 1 if vector_x > 0 else -1
		var sign_y = 1 if vector_y > 0 else -1
		var corner_points = PackedVector2Array([
			Vector2(vector_end.x - CORNER_SIZE * sign_x, 0),
			Vector2(vector_end.x - CORNER_SIZE * sign_x, -CORNER_SIZE * sign_y),
			Vector2(vector_end.x, -CORNER_SIZE * sign_y)
		])
		vector_arrow.draw_polyline(corner_points, RIGHT_ANGLE_COLOR, COMPONENT_LINE_WIDTH)

func _on_x_slider_changed(value: float):
	vector_x = value
	_update_vector_display()

func _on_y_slider_changed(value: float):
	vector_y = value
	_update_vector_display()

func _update_vector_display():
	_update_slider_labels()
	_update_calculation_display()
	_redraw_vector()

func _update_slider_labels():
	if x_value_label:
		x_value_label.text = "%.1f" % vector_x
	if y_value_label:
		y_value_label.text = "%.1f" % vector_y

func _update_calculation_display():
	if not result_label:
		return
		
	var length = sqrt(vector_x * vector_x + vector_y * vector_y)
	var x_squared = vector_x * vector_x
	var y_squared = vector_y * vector_y
	var sum_squares = x_squared + y_squared
	
	result_label.text = "Vector v = (%.1f, %.1f)\n|v| = √(%.1f² + %.1f²) = √(%.1f + %.1f) = √%.1f = %.2f" % [
		vector_x, vector_y, 
		vector_x, vector_y,
		x_squared, y_squared,
		sum_squares,
		length
	]

func _redraw_vector():
	if vector_arrow:
		vector_arrow.queue_redraw()
