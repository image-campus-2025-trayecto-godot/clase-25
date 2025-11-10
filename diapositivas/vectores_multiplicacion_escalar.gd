@tool
extends Control

# Node references for controls
@onready var vx_slider = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/VectorControls/VXControl/VXSlider
@onready var vx_value_label = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/VectorControls/VXControl/VXValue
@onready var vy_slider = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/VectorControls/VYControl/VYSlider
@onready var vy_value_label = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/VectorControls/VYControl/VYValue
@onready var scalar_slider = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/ScalarControl/ScalarSlider
@onready var scalar_value_label = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/ScalarControl/ScalarValue
@onready var resultado_label = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/ResultadoLabel
@onready var visualizacion = $MarginContainer/VBoxContainer/ContenidoContainer/VisualizacionContainer/VisualizacionMultiplicacion

# Vector values
var vector_x: float = 2.0
var vector_y: float = 1.5
var scalar: float = 1.5

# Constants
const GRID_SPACING: float = 30.0
const GRID_COLOR: Color = Color(0.4, 0.4, 0.4, 0.6)
const AXIS_COLOR: Color = Color(0.8, 0.8, 0.8, 0.8)

func _ready():
	if visualizacion:
		visualizacion.draw.connect(_draw_visualization)
	
	# Connect slider signals
	if vx_slider:
		vx_slider.value_changed.connect(_on_vx_slider_changed)
	if vy_slider:
		vy_slider.value_changed.connect(_on_vy_slider_changed)
	if scalar_slider:
		scalar_slider.value_changed.connect(_on_scalar_slider_changed)
	
	_update_displays()

func _on_vx_slider_changed(value: float):
	vector_x = value
	_update_displays()

func _on_vy_slider_changed(value: float):
	vector_y = value
	_update_displays()

func _on_scalar_slider_changed(value: float):
	scalar = value
	_update_displays()

func _update_displays():
	# Update value labels
	if vx_value_label:
		vx_value_label.text = "%.1f" % vector_x
	if vy_value_label:
		vy_value_label.text = "%.1f" % vector_y
	if scalar_value_label:
		scalar_value_label.text = "%.1f" % scalar
	
	# Update result
	if resultado_label:
		var result_x = vector_x * scalar
		var result_y = vector_y * scalar
		resultado_label.text = "Resultado: k × v = (%.1f, %.1f)" % [result_x, result_y]
	
	# Redraw visualization
	if visualizacion:
		visualizacion.queue_redraw()

func _draw_visualization():
	if not visualizacion:
		return
		
	var size = visualizacion.size
	var center = size / 2
	
	# Draw grid and axes
	_draw_grid_and_axes(size, center)
	
	# Use interactive values as proper 2D vectors
	var original_vector = Vector2(vector_x, vector_y)
	var scaled_vector = original_vector * scalar
	
	# Draw original vector
	_draw_vector(Vector2.ZERO, original_vector, Color.WHITE, "v", center)
	
	# Draw scaled version
	_draw_vector(Vector2.ZERO, scaled_vector, Color.CYAN, "k×v", center)
	
	# Draw magnitude comparison lines
	if abs(scalar) > 0.1:
		var magnitude_color = Color.ORANGE if scalar > 0 else Color.MAGENTA
		_draw_magnitude_indicator(original_vector, scaled_vector, magnitude_color, center)

func _draw_grid_and_axes(size: Vector2, center: Vector2):
	# Draw grid lines
	var start_x = fmod(center.x, GRID_SPACING)
	while start_x <= size.x:
		visualizacion.draw_line(Vector2(start_x, 0), Vector2(start_x, size.y), GRID_COLOR, 1)
		start_x += GRID_SPACING
	
	var start_y = fmod(center.y, GRID_SPACING)
	while start_y <= size.y:
		visualizacion.draw_line(Vector2(0, start_y), Vector2(size.x, start_y), GRID_COLOR, 1)
		start_y += GRID_SPACING
	
	# Draw axes
	visualizacion.draw_line(Vector2(center.x, 0), Vector2(center.x, size.y), AXIS_COLOR, 2)
	visualizacion.draw_line(Vector2(0, center.y), Vector2(size.x, center.y), AXIS_COLOR, 2)
	
	# Draw coordinate labels
	var coordinate_range = 4
	for i in range(-coordinate_range, coordinate_range + 1):
		if i == 0:
			continue
			
		var x_pos = center.x + i * GRID_SPACING
		var y_pos = center.y + i * GRID_SPACING
		
		# X-axis labels
		if x_pos >= 0 and x_pos <= size.x:
			visualizacion.draw_string(get_theme_default_font(), Vector2(x_pos - 8, center.y + 18), str(i), HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color.WHITE)
		
		# Y-axis labels (negative because screen Y is inverted)
		if y_pos >= 0 and y_pos <= size.y:
			visualizacion.draw_string(get_theme_default_font(), Vector2(center.x - 18, y_pos + 4), str(-i), HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color.WHITE)

func _draw_vector(start: Vector2, vector: Vector2, color: Color, label: String, center_offset: Vector2):
	var start_pos = center_offset + start * GRID_SPACING
	var end_pos = center_offset + (start + vector) * GRID_SPACING
	
	# Draw vector line
	visualizacion.draw_line(start_pos, end_pos, color, 4)
	
	# Draw arrowhead
	if vector.length() > 0.01:
		var direction = (end_pos - start_pos).normalized()
		var arrow_size = 10
		var arrow_angle = 0.5
		
		var arrow_point1 = end_pos - direction.rotated(arrow_angle) * arrow_size
		var arrow_point2 = end_pos - direction.rotated(-arrow_angle) * arrow_size
		
		visualizacion.draw_line(end_pos, arrow_point1, color, 4)
		visualizacion.draw_line(end_pos, arrow_point2, color, 4)
	
	# Draw label
	var label_pos = end_pos + Vector2(8, -8)
	visualizacion.draw_string(get_theme_default_font(), label_pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, color)

func _draw_magnitude_indicator(original: Vector2, scaled: Vector2, color: Color, center_offset: Vector2):
	# Draw a subtle indicator showing the magnitude relationship
	var original_end = center_offset + original * GRID_SPACING
	var scaled_end = center_offset + scaled * GRID_SPACING
	
	# Draw a dashed line between the endpoints to show the scaling
	var direction = (scaled_end - original_end).normalized()
	var distance = original_end.distance_to(scaled_end)
	var dash_length = 6.0
	var gap_length = 3.0
	var total_length = dash_length + gap_length
	
	var current_pos = original_end
	var traveled = 0.0
	
	while traveled < distance:
		var remaining = distance - traveled
		var segment_length = min(dash_length, remaining)
		var segment_end = current_pos + direction * segment_length
		
		visualizacion.draw_line(current_pos, segment_end, color, 2)
		
		traveled += total_length
		current_pos += direction * total_length
