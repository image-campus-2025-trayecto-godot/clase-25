@tool
extends Control

# Node references for controls
@onready var ux_spinbox = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/UControl/UXSpinBox
@onready var uy_spinbox = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/UControl/UYSpinBox
@onready var vx_spinbox = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/VControl/VXSpinBox
@onready var vy_spinbox = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/VControl/VYSpinBox
@onready var resultado_label = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/ResultadoLabel
@onready var visualizacion = $MarginContainer/VBoxContainer/ContenidoContainer/VisualizacionContainer/VisualizacionSuma

# Vector values
var u_x: float = 2.0
var u_y: float = 1.5
var v_x: float = 1.0
var v_y: float = 2.0

# Constants
const GRID_SPACING: float = 30.0
const GRID_COLOR: Color = Color(0.4, 0.4, 0.4, 0.6)
const AXIS_COLOR: Color = Color(0.8, 0.8, 0.8, 0.8)

func _ready():
	if visualizacion:
		visualizacion.draw.connect(_draw_visualization)
	
	# Connect spinbox signals
	if ux_spinbox:
		ux_spinbox.value_changed.connect(_on_ux_changed)
	if uy_spinbox:
		uy_spinbox.value_changed.connect(_on_uy_changed)
	if vx_spinbox:
		vx_spinbox.value_changed.connect(_on_vx_changed)
	if vy_spinbox:
		vy_spinbox.value_changed.connect(_on_vy_changed)
	
	_update_displays()

func _on_ux_changed(value: float):
	_update_displays()

func _on_uy_changed(value: float):
	_update_displays()

func _on_vx_changed(value: float):
	_update_displays()

func _on_vy_changed(value: float):
	_update_displays()

func _update_displays():
	u_x = ux_spinbox.value
	u_y = -uy_spinbox.value
	v_x = vx_spinbox.value
	v_y = -vy_spinbox.value
	# Update result (no need to update spinbox values as they update themselves)
	if resultado_label:
		var sum_x = u_x + v_x
		var sum_y = u_y + v_y
		resultado_label.text = "Resultado: u + v = (%.1f, %.1f)" % [sum_x, sum_y]
	
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
	var vector_u = Vector2(u_x, u_y)  # Cyan vector
	var vector_v = Vector2(v_x, v_y)  # Green vector
	var vector_sum = vector_u + vector_v  # Red result vector
	
	# Draw vector u (from origin)
	_draw_vector(Vector2.ZERO, vector_u, Color.CYAN, "u", center)
	
	# Draw vector v (from end of u)
	_draw_vector(vector_u, vector_v, Color.GREEN, "v", center)
	
	# Draw result vector (from origin to sum)
	_draw_vector(Vector2.ZERO, vector_sum, Color.RED, "u+v", center)
	
	# Draw dashed line to show the parallelogram
	_draw_dashed_line_between_points(vector_v, vector_sum, Color.YELLOW, 2.0, center)

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

func _draw_dashed_line_between_points(start_vec: Vector2, end_vec: Vector2, color: Color, width: float, center_offset: Vector2):
	var start_pos = center_offset + start_vec * GRID_SPACING
	var end_pos = center_offset + end_vec * GRID_SPACING
	
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
		
		visualizacion.draw_line(current_pos, segment_end, color, width)
		
		traveled += total_length
		current_pos += direction * total_length
