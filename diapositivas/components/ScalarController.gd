@tool
extends HBoxContainer
class_name ScalarController

# Signals
signal scalar_changed(value: float)

# Exported properties
@export var scalar_label: String = "k" : set = set_scalar_label
@export var scalar_color: Color = Color.WHITE : set = set_scalar_color
@export var min_value: float = -5.0 : set = set_min_value
@export var max_value: float = 5.0 : set = set_max_value
@export var step_value: float = 0.1 : set = set_step_value
@export var initial_value: float = 1.0 : set = set_initial_value
@export var label_settings: LabelSettings :
	set(new_value):
		label_settings = new_value
		if not is_node_ready():
			await ready
			update_label_settings()

# Node references
@onready var scalar_label_node: Label = $ScalarLabel
@onready var scalar_spinbox: SpinBox = $ScalarSpinBox

# Current scalar value
var current_value: float = 1.0

func update_label_settings():
	for label in [scalar_label_node]:
		label.label_settings = label_settings

func _ready():
	# Connect spinbox signal
	if scalar_spinbox:
		scalar_spinbox.value_changed.connect(_on_value_changed)
	
	# Apply initial settings
	update_label_settings()
	_update_display()

func _on_value_changed(value: float):
	current_value = value
	scalar_changed.emit(value)

func get_value() -> float:
	if scalar_spinbox:
		return scalar_spinbox.value
	return current_value

func set_value(value: float):
	current_value = value
	if scalar_spinbox:
		scalar_spinbox.value = value

# Property setters
func set_scalar_label(value: String):
	scalar_label = value
	if scalar_label_node:
		scalar_label_node.text = value + " ="

func set_scalar_color(color: Color):
	scalar_color = color
	if scalar_label_node:
		scalar_label_node.modulate = color

func set_min_value(value: float):
	min_value = value
	if scalar_spinbox:
		scalar_spinbox.min_value = value

func set_max_value(value: float):
	max_value = value
	if scalar_spinbox:
		scalar_spinbox.max_value = value

func set_step_value(value: float):
	step_value = value
	if scalar_spinbox:
		scalar_spinbox.step = value

func set_initial_value(value: float):
	initial_value = value
	current_value = value
	if scalar_spinbox:
		scalar_spinbox.value = value

func _update_display():
	if scalar_label_node:
		scalar_label_node.text = scalar_label + " ="
		scalar_label_node.modulate = scalar_color
	
	if scalar_spinbox:
		scalar_spinbox.min_value = min_value
		scalar_spinbox.max_value = max_value
		scalar_spinbox.step = step_value
		scalar_spinbox.value = initial_value
