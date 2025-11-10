@tool
extends HBoxContainer
class_name VectorController

# Signals
signal vector_changed(vector: Vector2)

# Exported properties
@export var vector_label: String = "v" : set = set_vector_label
@export var vector_color: Color = Color.WHITE : set = set_vector_color
@export var min_value: float = -10.0 : set = set_min_value
@export var max_value: float = 10.0 : set = set_max_value
@export var step_value: float = 0.1 : set = set_step_value
@export var initial_vector: Vector2 = Vector2.ZERO : set = set_initial_vector
@export var label_settings: LabelSettings :
	set(new_value):
		label_settings = new_value
		if not is_node_ready():
			await ready
			update_label_settings()

# Node references
@onready var vector_label_node: Label = $VectorLabel
@onready var x_spinbox: SpinBox = $XSpinBox
@onready var y_spinbox: SpinBox = $YSpinBox

# Current vector value
var current_vector: Vector2 = Vector2.ZERO

func update_label_settings():
	for label in [$VectorLabel, $OpenParen, $Comma, $CloseParen]:
		label.label_settings = label_settings

func _ready():
	# Connect spinbox signals
	if x_spinbox:
		x_spinbox.value_changed.connect(_on_x_changed)
	if y_spinbox:
		y_spinbox.value_changed.connect(_on_y_changed)
	
	update_label_settings()
	# Apply initial settings
	_update_display()

func _on_x_changed(value: float):
	current_vector.x = value
	vector_changed.emit(current_vector)

func _on_y_changed(value: float):
	current_vector.y = value
	vector_changed.emit(current_vector)

func get_vector() -> Vector2:
	if x_spinbox and y_spinbox:
		return Vector2(x_spinbox.value, y_spinbox.value)
	return current_vector

func set_vector(vector: Vector2):
	current_vector = vector
	if x_spinbox:
		x_spinbox.value = vector.x
	if y_spinbox:
		y_spinbox.value = vector.y

# Property setters
func set_vector_label(value: String):
	vector_label = value
	if vector_label_node:
		vector_label_node.text = value + " ="

func set_vector_color(color: Color):
	vector_color = color
	if vector_label_node:
		vector_label_node.modulate = color

func set_min_value(value: float):
	min_value = value
	if x_spinbox:
		x_spinbox.min_value = value
	if y_spinbox:
		y_spinbox.min_value = value

func set_max_value(value: float):
	max_value = value
	if x_spinbox:
		x_spinbox.max_value = value
	if y_spinbox:
		y_spinbox.max_value = value

func set_step_value(value: float):
	step_value = value
	if x_spinbox:
		x_spinbox.step = value
	if y_spinbox:
		y_spinbox.step = value

func set_initial_vector(vector: Vector2):
	initial_vector = vector
	current_vector = vector
	if x_spinbox:
		x_spinbox.value = vector.x
	if y_spinbox:
		y_spinbox.value = vector.y

func _update_display():
	if vector_label_node:
		vector_label_node.text = vector_label + " ="
		vector_label_node.modulate = vector_color
	
	if x_spinbox:
		x_spinbox.min_value = min_value
		x_spinbox.max_value = max_value
		x_spinbox.step = step_value
		x_spinbox.value = initial_vector.x
	
	if y_spinbox:
		y_spinbox.min_value = min_value
		y_spinbox.max_value = max_value
		y_spinbox.step = step_value
		y_spinbox.value = initial_vector.y
