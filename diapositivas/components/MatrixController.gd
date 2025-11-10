@tool
extends VBoxContainer
class_name MatrixController

# Signals
signal matrix_changed(matrix: Array)

# Exported properties
@export var matrix_label: String = "A" : set = set_matrix_label
@export var matrix_color: Color = Color.WHITE : set = set_matrix_color
@export var min_value: float = -10.0 : set = set_min_value
@export var max_value: float = 10.0 : set = set_max_value
@export var step_value: float = 0.1 : set = set_step_value
@export var initial_matrix: Array[float] = [1.0, 2.0, 3.0, 4.0] : set = set_initial_matrix
@export var label_settings: LabelSettings :
	set(new_value):
		label_settings = new_value
		if not is_node_ready():
			await ready
		update_label_settings()

# Node references
@onready var matrix_label_node: Label = $MatrixLabel
@onready var a11_spinbox: SpinBox = $MatrixContainer/Row1/A11
@onready var a12_spinbox: SpinBox = $MatrixContainer/Row1/A12
@onready var a21_spinbox: SpinBox = $MatrixContainer/Row2/A21
@onready var a22_spinbox: SpinBox = $MatrixContainer/Row2/A22
@onready var left_bracket1: Label = $MatrixContainer/Row1/LeftBracket1
@onready var right_bracket1: Label = $MatrixContainer/Row1/RightBracket1
@onready var left_bracket2: Label = $MatrixContainer/Row2/LeftBracket2
@onready var right_bracket2: Label = $MatrixContainer/Row2/RightBracket2

# Current matrix values
var current_matrix: Array[float] = [1.0, 2.0, 3.0, 4.0]

func update_label_settings():
	var labels = [matrix_label_node, left_bracket1, right_bracket1, left_bracket2, right_bracket2]
	for label in labels:
		if label:
			label.label_settings = label_settings

func _ready():
	# Connect spinbox signals
	if a11_spinbox:
		a11_spinbox.value_changed.connect(_on_value_changed)
	if a12_spinbox:
		a12_spinbox.value_changed.connect(_on_value_changed)
	if a21_spinbox:
		a21_spinbox.value_changed.connect(_on_value_changed)
	if a22_spinbox:
		a22_spinbox.value_changed.connect(_on_value_changed)
	
	# Apply initial settings
	update_label_settings()
	_update_display()

func _on_value_changed(_value: float):
	_update_matrix_from_spinboxes()
	matrix_changed.emit(current_matrix)

func _update_matrix_from_spinboxes():
	if a11_spinbox and a12_spinbox and a21_spinbox and a22_spinbox:
		current_matrix = [
			a11_spinbox.value,
			a12_spinbox.value,
			a21_spinbox.value,
			a22_spinbox.value
		]

func get_matrix() -> Array[float]:
	_update_matrix_from_spinboxes()
	return current_matrix

func set_matrix(matrix: Array[float]):
	if matrix.size() >= 4:
		current_matrix = matrix
		if a11_spinbox:
			a11_spinbox.value = matrix[0]
		if a12_spinbox:
			a12_spinbox.value = matrix[1]
		if a21_spinbox:
			a21_spinbox.value = matrix[2]
		if a22_spinbox:
			a22_spinbox.value = matrix[3]

func highlight_element(row: int, col: int, highlight: bool = true):
	var spinbox: SpinBox = null
	match [row, col]:
		[0, 0]: spinbox = a11_spinbox
		[0, 1]: spinbox = a12_spinbox
		[1, 0]: spinbox = a21_spinbox
		[1, 1]: spinbox = a22_spinbox
	
	if spinbox:
		if highlight:
			spinbox.modulate = Color.YELLOW
		else:
			spinbox.modulate = Color.WHITE

func clear_highlights():
	for spinbox in [a11_spinbox, a12_spinbox, a21_spinbox, a22_spinbox]:
		if spinbox:
			spinbox.modulate = Color.WHITE

# Property setters
func set_matrix_label(value: String):
	matrix_label = value
	if matrix_label_node:
		matrix_label_node.text = value

func set_matrix_color(color: Color):
	matrix_color = color
	if matrix_label_node:
		matrix_label_node.modulate = color

func set_min_value(value: float):
	min_value = value
	for spinbox in [a11_spinbox, a12_spinbox, a21_spinbox, a22_spinbox]:
		if spinbox:
			spinbox.min_value = value

func set_max_value(value: float):
	max_value = value
	for spinbox in [a11_spinbox, a12_spinbox, a21_spinbox, a22_spinbox]:
		if spinbox:
			spinbox.max_value = value

func set_step_value(value: float):
	step_value = value
	for spinbox in [a11_spinbox, a12_spinbox, a21_spinbox, a22_spinbox]:
		if spinbox:
			spinbox.step = value

func set_initial_matrix(matrix: Array[float]):
	if matrix.size() >= 4:
		initial_matrix = matrix
		current_matrix = matrix
		set_matrix(matrix)

func _update_display():
	if matrix_label_node:
		matrix_label_node.text = matrix_label + " ="
		matrix_label_node.modulate = matrix_color
	
	# Update spinbox properties
	for spinbox in [a11_spinbox, a12_spinbox, a21_spinbox, a22_spinbox]:
		if spinbox:
			spinbox.min_value = min_value
			spinbox.max_value = max_value
			spinbox.step = step_value
	
	# Set initial values
	if initial_matrix.size() >= 4:
		set_matrix(initial_matrix)
