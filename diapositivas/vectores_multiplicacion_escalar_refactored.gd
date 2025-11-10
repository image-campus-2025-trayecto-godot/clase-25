@tool
extends Control

# Exported constants for easy customization
@export var vector_original_color: Color = Color.WHITE
@export var vector_scaled_color: Color = Color.CYAN

# Node references for controls
@onready var v_controller: VectorController = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/VController
@onready var scalar_controller: ScalarController = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/Controles/ScalarController
@onready var resultado_label = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/ResultadoLabel
@onready var show_scaled_checkbox = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/ShowScaledCheckbox
@onready var grid_visualization: GridVisualization = $MarginContainer/VBoxContainer/ContenidoContainer/VisualizacionContainer/GridVisualization

@export_tool_button("Redraw") var redraw_button = _update_displays

# Vector values
var show_scaled_vector: bool = true

func _ready():
	# Configure vector controller
	if v_controller:
		v_controller.vector_label = "v"
		v_controller.vector_color = vector_original_color
		v_controller.initial_vector = Vector2(2.0, 1.5)
		v_controller.vector_changed.connect(_on_vector_changed)
	
	# Configure scalar controller
	if scalar_controller:
		scalar_controller.scalar_label = "k"
		scalar_controller.initial_value = 1.5
		scalar_controller.scalar_changed.connect(_on_scalar_changed)
	
	# Connect checkbox signal
	if show_scaled_checkbox:
		show_scaled_checkbox.toggled.connect(_on_show_scaled_toggled)
	
	await get_tree().process_frame
	_update_displays()

func _on_vector_changed(_vector: Vector2):
	_update_displays()

func _on_scalar_changed(_value: float):
	_update_displays()

func _on_show_scaled_toggled(pressed: bool):
	show_scaled_vector = pressed
	_update_displays()

func _update_displays():
	if not v_controller or not scalar_controller or not grid_visualization:
		return
	
	var original_vector = Vector2(v_controller.get_vector().x, -v_controller.get_vector().y)
	var scalar = scalar_controller.get_value()
	var scaled_vector = original_vector * scalar
	
	# Update result label
	if resultado_label:
		resultado_label.text = "Resultado: k × v = (%.1f, %.1f)" % [scaled_vector.x, -scaled_vector.y]
		resultado_label.modulate = vector_scaled_color
	
	# Clear and add vectors to visualization
	grid_visualization.clear_vectors()
	
	# Add original vector
	grid_visualization.add_vector(Vector2.ZERO, original_vector, vector_original_color, "v")
	
	# Add scaled vector only if checkbox is checked
	if show_scaled_vector:
		grid_visualization.add_vector(Vector2.ZERO, scaled_vector, vector_scaled_color, "k×v")
	
	# Redraw visualization
	grid_visualization.redraw()
