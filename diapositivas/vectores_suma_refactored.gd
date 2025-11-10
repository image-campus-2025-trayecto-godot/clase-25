@tool
extends Control

# Exported constants for easy customization
@export var vector_u_color: Color = Color.CYAN
@export var vector_v_color: Color = Color.GREEN
@export var vector_sum_color: Color = Color.RED

# Node references for controls
@onready var u_controller: VectorController = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/UController
@onready var v_controller: VectorController = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/VController
@onready var resultado_label = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/ResultadoLabel
@onready var show_sum_checkbox = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/ShowSumCheckbox
@onready var grid_visualization: GridVisualization = $MarginContainer/VBoxContainer/ContenidoContainer/VisualizacionContainer/GridVisualization

@export_tool_button("Redraw") var redraw_button = _update_displays

# Vector values
var show_sum_vector: bool = true

func _ready():
	# Configure vector controllers
	if u_controller:
		u_controller.vector_label = "u"
		u_controller.vector_color = vector_u_color
		u_controller.initial_vector = Vector2(2.0, 1.5)
		u_controller.vector_changed.connect(_on_vector_changed)
	
	if v_controller:
		v_controller.vector_label = "v"
		v_controller.vector_color = vector_v_color
		v_controller.initial_vector = Vector2(1.0, 2.0)
		v_controller.vector_changed.connect(_on_vector_changed)
	
	# Connect checkbox signal
	if show_sum_checkbox:
		show_sum_checkbox.toggled.connect(_on_show_sum_toggled)
	
	await get_tree().process_frame
	_update_displays()

func _on_vector_changed(_vector: Vector2):
	_update_displays()

func _on_show_sum_toggled(pressed: bool):
	show_sum_vector = pressed
	_update_displays()

func _update_displays():
	if not u_controller or not v_controller or not grid_visualization:
		return
	
	var u_vector = Vector2(u_controller.get_vector().x, -u_controller.get_vector().y)
	var v_vector = Vector2(v_controller.get_vector().x, -v_controller.get_vector().y)
	var sum_vector = u_vector + v_vector
	
	# Update result label
	if resultado_label:
		resultado_label.text = "Resultado: u + v = (%.1f, %.1f)" % [sum_vector.x, -sum_vector.y]
		resultado_label.modulate = vector_sum_color
	
	# Clear and add vectors to visualization
	grid_visualization.clear_vectors()
	
	# Add vector u (from origin)
	grid_visualization.add_vector(Vector2.ZERO, u_vector, vector_u_color, "u")
	
	# Add vector v (from end of u)
	grid_visualization.add_vector(u_vector, v_vector, vector_v_color, "v")
	
	# Add result vector (from origin to sum) only if checkbox is checked
	if show_sum_vector:
		grid_visualization.add_vector(Vector2.ZERO, sum_vector, vector_sum_color, "u+v")
	
	# Redraw visualization
	grid_visualization.redraw()
