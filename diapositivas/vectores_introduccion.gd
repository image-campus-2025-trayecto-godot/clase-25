@tool
extends Control

# Node references for visualization areas
@onready var visualizacion_suma = $MarginContainer/VBoxContainer/OperacionesContainer/SumaVectores/VisualizacionSuma
@onready var visualizacion_multiplicacion = $MarginContainer/VBoxContainer/OperacionesContainer/MultiplicacionEscalar/VisualizacionMultiplicacion

# Node references for controls - Vector Addition
@onready var u_slider = $MarginContainer/VBoxContainer/OperacionesContainer/SumaVectores/ControlesSuma/UControl/UXSlider
@onready var u_value_label = $MarginContainer/VBoxContainer/OperacionesContainer/SumaVectores/ControlesSuma/UControl/UXValue
@onready var v_slider = $MarginContainer/VBoxContainer/OperacionesContainer/SumaVectores/ControlesSuma/VControl/VXSlider
@onready var v_value_label = $MarginContainer/VBoxContainer/OperacionesContainer/SumaVectores/ControlesSuma/VControl/VXValue

# Node references for controls - Scalar Multiplication
@onready var vector_slider = $MarginContainer/VBoxContainer/OperacionesContainer/MultiplicacionEscalar/ControlesMultiplicacion/VectorControl/VectorSlider
@onready var vector_value_label = $MarginContainer/VBoxContainer/OperacionesContainer/MultiplicacionEscalar/ControlesMultiplicacion/VectorControl/VectorValue
@onready var scalar_slider = $MarginContainer/VBoxContainer/OperacionesContainer/MultiplicacionEscalar/ControlesMultiplicacion/ScalarControl/ScalarSlider
@onready var scalar_value_label = $MarginContainer/VBoxContainer/OperacionesContainer/MultiplicacionEscalar/ControlesMultiplicacion/ScalarControl/ScalarValue

# Vector values
var u_x: float = 2.0
var v_x: float = 1.0
var vector_x: float = 2.0
var scalar: float = 1.5

# Constants
const GRID_SPACING: float = 25.0
const GRID_COLOR: Color = Color(0.4, 0.4, 0.4, 0.6)
const AXIS_COLOR: Color = Color(0.8, 0.8, 0.8, 0.8)

func _ready():
	if visualizacion_suma:
		visualizacion_suma.draw.connect(_draw_vector_addition)
	if visualizacion_multiplicacion:
		visualizacion_multiplicacion.draw.connect(_draw_scalar_multiplication)
	
	# Connect slider signals
	if u_slider:
		u_slider.value_changed.connect(_on_u_slider_changed)
	if v_slider:
		v_slider.value_changed.connect(_on_v_slider_changed)
	if vector_slider:
		vector_slider.value_changed.connect(_on_vector_slider_changed)
	if scalar_slider:
		scalar_slider.value_changed.connect(_on_scalar_slider_changed)
	
	_update_displays()

func _draw_vector_addition():
	if not visualizacion_suma:
		return
		
	var size = visualizacion_suma.size
	var center = size / 2
	
	# Draw grid and axes
	_draw_grid_and_axes(visualizacion_suma, size, center)
	
	# Use interactive values (treating as 1D vectors for simplicity)
	var vector_u = Vector2(u_x, 1)  # Blue vector
	var vector_v = Vector2(v_x, 1)  # Green vector
	var vector_sum = vector_u + vector_v  # Red result vector
	
	# Draw vector u (from origin)
	_draw_vector(visualizacion_suma, Vector2.ZERO, vector_u, Color.CYAN, "u", center)
	
	# Draw vector v (from end of u)
	_draw_vector(visualizacion_suma, vector_u, vector_v, Color.GREEN, "v", center)
	
	# Draw result vector (from origin to sum)
	_draw_vector(visualizacion_suma, Vector2.ZERO, vector_sum, Color.RED, "u+v", center)
	
	# Draw dashed line to show the parallelogram
	_draw_dashed_line_between_points(visualizacion_suma, vector_u, vector_sum, Color.YELLOW, 2.0, center)

func _draw_scalar_multiplication():
	if not visualizacion_multiplicacion:
		return
		
	var size = visualizacion_multiplicacion.size
	var center = size / 2
	
	# Draw grid and axes
	_draw_grid_and_axes(visualizacion_multiplicacion, size, center)
	
	# Use interactive values
	var original_vector = Vector2(vector_x, 1)
	var scaled_vector = original_vector * scalar
	
	# Draw original vector
	_draw_vector(visualizacion_multiplicacion, Vector2.ZERO, original_vector, Color.WHITE, "v", center)
	
	# Draw scaled version
	_draw_vector(visualizacion_multiplicacion, Vector2.ZERO, scaled_vector, Color.CYAN, "k×v", center)

# Signal handlers
func _on_u_slider_changed(value: float):
	u_x = value
	_update_displays()

func _on_v_slider_changed(value: float):
	v_x = value
	_update_displays()

func _on_vector_slider_changed(value: float):
	vector_x = value
	_update_displays()

func _on_scalar_slider_changed(value: float):
	scalar = value
	_update_displays()

func _update_displays():
	# Update value labels
	if u_value_label:
		u_value_label.text = "%.1f" % u_x
	if v_value_label:
		v_value_label.text = "%.1f" % v_x
	if vector_value_label:
		vector_value_label.text = "%.1f" % vector_x
	if scalar_value_label:
		scalar_value_label.text = "%.1f" % scalar
	
	# Redraw visualizations
	if visualizacion_suma:
		visualizacion_suma.queue_redraw()
	if visualizacion_multiplicacion:
		visualizacion_multiplicacion.queue_redraw()

func _draw_grid_and_axes(control: Control, size: Vector2, center: Vector2):
	# Draw grid
	var start_x = fmod(center.x, GRID_SPACING)
	while start_x <= size.x:
		control.draw_line(Vector2(start_x, 0), Vector2(start_x, size.y), GRID_COLOR, 1)
		start_x += GRID_SPACING
	
	var start_y = fmod(center.y, GRID_SPACING)
	while start_y <= size.y:
		control.draw_line(Vector2(0, start_y), Vector2(size.x, start_y), GRID_COLOR, 1)
		start_y += GRID_SPACING
	
	# Draw axes
	control.draw_line(Vector2(center.x, 0), Vector2(center.x, size.y), AXIS_COLOR, 2)
	control.draw_line(Vector2(0, center.y), Vector2(size.x, center.y), AXIS_COLOR, 2)

func _draw_vector(control: Control, start: Vector2, vector: Vector2, color: Color, label: String, center_offset: Vector2):
	var start_pos = center_offset + start * GRID_SPACING
	var end_pos = center_offset + (start + vector) * GRID_SPACING
	
	# Draw vector line
	control.draw_line(start_pos, end_pos, color, 3)
	
	# Draw arrowhead
	if vector.length() > 0.01:
		var direction = (end_pos - start_pos).normalized()
		var arrow_size = 8
		var arrow_angle = 0.5
		
		var arrow_point1 = end_pos - direction.rotated(arrow_angle) * arrow_size
		var arrow_point2 = end_pos - direction.rotated(-arrow_angle) * arrow_size
		
		control.draw_line(end_pos, arrow_point1, color, 3)
		control.draw_line(end_pos, arrow_point2, color, 3)
	
	# Draw label
	var label_pos = end_pos + Vector2(5, -5)
	control.draw_string(get_theme_default_font(), label_pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, color)

func _draw_dashed_line_between_points(control: Control, start_vec: Vector2, end_vec: Vector2, color: Color, width: float, center_offset: Vector2):
	var start_pos = center_offset + start_vec * GRID_SPACING
	var end_pos = center_offset + end_vec * GRID_SPACING
	
	var direction = (end_pos - start_pos).normalized()
	var distance = start_pos.distance_to(end_pos)
	var dash_length = 6.0
	var gap_length = 3.0
	var total_length = dash_length + gap_length
	
	var current_pos = start_pos
	var traveled = 0.0
	
	while traveled < distance:
		var remaining = distance - traveled
		var segment_length = min(dash_length, remaining)
		var segment_end = current_pos + direction * segment_length
		
		control.draw_line(current_pos, segment_end, color, width)
		
		traveled += total_length
		current_pos += direction * total_length
