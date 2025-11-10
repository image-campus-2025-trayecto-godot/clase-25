@tool
extends Control

# Exported constants for easy customization
@export var grid_spacing: float = 30.0
@export var grid_color: Color = Color(0.4, 0.4, 0.4, 0.6)
@export var axis_color: Color = Color(0.8, 0.8, 0.8, 0.8)
@export var vector_original_color: Color = Color.WHITE
@export var vector_scaled_color: Color = Color.CYAN
@export var coordinate_range: int = 4

# Node references for controls
@onready var vx_spinbox = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/VControl/VXSpinBox
@onready var vy_spinbox = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/VControl/VYSpinBox
@onready var scalar_spinbox = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/ScalarControl/ScalarSpinBox
@onready var resultado_label = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/ResultadoLabel
@onready var show_scaled_checkbox = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/ShowScaledCheckbox
@onready var visualizacion = $MarginContainer/VBoxContainer/ContenidoContainer/VisualizacionContainer/VisualizacionMultiplicacion

# UI Labels for color coding
@onready var v_label = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/VControl/VLabel
@onready var k_label = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/ScalarControl/KLabel

@export_tool_button("Redraw") var redraw_button = _update_displays

# Vector values
var vector_x: float = 2.0
var vector_y: float = 1.5
var scalar: float = 1.5
var show_scaled_vector: bool = true

func _ready():
	if visualizacion:
		visualizacion.draw.connect(_draw_visualization)
	
	# Connect spinbox signals
	if vx_spinbox:
		vx_spinbox.value_changed.connect(_on_vx_changed)
	if vy_spinbox:
		vy_spinbox.value_changed.connect(_on_vy_changed)
	if scalar_spinbox:
		scalar_spinbox.value_changed.connect(_on_scalar_changed)
	
	# Connect checkbox signal
	if show_scaled_checkbox:
		show_scaled_checkbox.toggled.connect(_on_show_scaled_toggled)
	
	await get_tree().process_frame
	_update_displays()
	_update_label_colors()

func _on_vx_changed(value: float):
	_update_displays()

func _on_vy_changed(value: float):
	_update_displays()

func _on_scalar_changed(value: float):
	_update_displays()

func _on_show_scaled_toggled(pressed: bool):
	show_scaled_vector = pressed
	_update_displays()

func _update_displays():
	vector_x = vx_spinbox.value
	vector_y = -vy_spinbox.value
	scalar = scalar_spinbox.value
	
	# Update result
	if resultado_label:
		var result_x = vector_x * scalar
		var result_y = vector_y * scalar
		resultado_label.text = "Resultado: k × v = (%.1f, %.1f)" % [result_x, result_y]
	
	# Redraw visualization
	if visualizacion:
		visualizacion.queue_redraw()

func _update_label_colors():
	# Set label colors to match vector colors
	if v_label:
		v_label.modulate = vector_original_color
	if resultado_label:
		resultado_label.modulate = vector_scaled_color

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
	_draw_vector(Vector2.ZERO, original_vector, vector_original_color, "v", center)
	
	# Draw scaled version only if checkbox is checked
	if show_scaled_vector:
		_draw_vector(Vector2.ZERO, scaled_vector, vector_scaled_color, "k×v", center)

func _draw_grid_and_axes(size: Vector2, center: Vector2):
	# Draw grid lines
	var start_x = fmod(center.x, grid_spacing)
	while start_x <= size.x:
		visualizacion.draw_line(Vector2(start_x, 0), Vector2(start_x, size.y), grid_color, 1)
		start_x += grid_spacing
	
	var start_y = fmod(center.y, grid_spacing)
	while start_y <= size.y:
		visualizacion.draw_line(Vector2(0, start_y), Vector2(size.x, start_y), grid_color, 1)
		start_y += grid_spacing
	
	# Draw axes
	visualizacion.draw_line(Vector2(center.x, 0), Vector2(center.x, size.y), axis_color, 2)
	visualizacion.draw_line(Vector2(0, center.y), Vector2(size.x, center.y), axis_color, 2)
	
	# Draw coordinate labels
	for i in range(-coordinate_range, coordinate_range + 1):
		if i == 0:
			continue
			
		var x_pos = center.x + i * grid_spacing
		var y_pos = center.y + i * grid_spacing
		
		# X-axis labels
		if x_pos >= 0 and x_pos <= size.x:
			visualizacion.draw_string(get_theme_default_font(), Vector2(x_pos - 8, center.y + 18), str(i), HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color.WHITE)
		
		# Y-axis labels (negative because screen Y is inverted)
		if y_pos >= 0 and y_pos <= size.y:
			visualizacion.draw_string(get_theme_default_font(), Vector2(center.x - 18, y_pos + 4), str(-i), HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color.WHITE)

func _draw_vector(start: Vector2, vector: Vector2, color: Color, label: String, center_offset: Vector2):
	var start_pos = center_offset + start * grid_spacing
	var end_pos = center_offset + (start + vector) * grid_spacing
	
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
