@tool
extends Control

# Exported constants for easy customization
@export var grid_spacing: float = 30.0
@export var grid_color: Color = Color(0.4, 0.4, 0.4, 0.6)
@export var axis_color: Color = Color(0.8, 0.8, 0.8, 0.8)
@export var vector_u_color: Color = Color.CYAN
@export var vector_v_color: Color = Color.GREEN
@export var vector_sum_color: Color = Color.RED
@export var coordinate_range: int = 4

# Node references for controls
@onready var ux_spinbox = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/UControl/UXSpinBox
@onready var uy_spinbox = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/UControl/UYSpinBox
@onready var vx_spinbox = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/VControl/VXSpinBox
@onready var vy_spinbox = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/VControl/VYSpinBox
@onready var resultado_label = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/ResultadoLabel
@onready var show_sum_checkbox = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/ShowSumCheckbox
@onready var visualizacion = $MarginContainer/VBoxContainer/ContenidoContainer/VisualizacionContainer/VisualizacionSuma

# UI Labels for color coding
@onready var u_label = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/UControl/ULabel
@onready var v_label = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/VControl/VLabel

@export_tool_button("Redraw") var redraw_button = _update_displays

# Vector values
var u_x: float = 2.0
var u_y: float = 1.5
var v_x: float = 1.0
var v_y: float = 2.0
var show_sum_vector: bool = true

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
	
	# Connect checkbox signal
	if show_sum_checkbox:
		show_sum_checkbox.toggled.connect(_on_show_sum_toggled)
	
	await get_tree().process_frame
	_update_displays()
	_update_label_colors()

func _on_ux_changed(value: float):
	_update_displays()

func _on_uy_changed(value: float):
	_update_displays()

func _on_vx_changed(value: float):
	_update_displays()

func _on_vy_changed(value: float):
	_update_displays()

func _on_show_sum_toggled(pressed: bool):
	show_sum_vector = pressed
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

func _update_label_colors():
	# Set label colors to match vector colors
	if u_label:
		u_label.modulate = vector_u_color
	if v_label:
		v_label.modulate = vector_v_color
	if resultado_label:
		resultado_label.modulate = vector_sum_color

func _draw_visualization():
	if not visualizacion:
		return
		
	var size = visualizacion.size
	var center = size / 2
	
	# Draw grid and axes
	_draw_grid_and_axes(size, center)
	
	# Use interactive values as proper 2D vectors
	var vector_u = Vector2(u_x, u_y)
	var vector_v = Vector2(v_x, v_y)
	var vector_sum = vector_u + vector_v
	
	# Draw vector u (from origin)
	_draw_vector(Vector2.ZERO, vector_u, vector_u_color, "u", center)
	
	# Draw vector v (from end of u)
	_draw_vector(vector_u, vector_v, vector_v_color, "v", center)
	
	# Draw result vector (from origin to sum) only if checkbox is checked
	if show_sum_vector:
		_draw_vector(Vector2.ZERO, vector_sum, vector_sum_color, "u+v", center)

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
