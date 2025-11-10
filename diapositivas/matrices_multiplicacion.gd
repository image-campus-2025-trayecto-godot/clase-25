@tool
extends Control

# Exported constants for easy customization
@export var matrix_a_color: Color = Color.CYAN
@export var matrix_b_color: Color = Color.GREEN
@export var result_color: Color = Color.RED
@export var highlight_color: Color = Color.YELLOW
@export var step_duration: float = 1.5

# Node references for controls
@onready var matrix_a_controller: MatrixController = $MarginContainer/VBoxContainer/ContenidoContainer/MatricesContainer/MatrixAController
@onready var matrix_b_controller: MatrixController = $MarginContainer/VBoxContainer/ContenidoContainer/MatricesContainer/MatrixBController
@onready var prev_button: Button = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/NavigationContainer/PrevButton
@onready var next_button: Button = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/NavigationContainer/NextButton
@onready var reset_button: Button = $MarginContainer/VBoxContainer/ContenidoContainer/ControlesContainer/ResetButton
@onready var calculation_container: VBoxContainer = $MarginContainer/VBoxContainer/ContenidoContainer/CalculationContainer
@onready var step_label: Label = $MarginContainer/VBoxContainer/ContenidoContainer/CalculationContainer/StepLabel
@onready var equation_label: Label = $MarginContainer/VBoxContainer/ContenidoContainer/CalculationContainer/EquationLabel
@onready var result_label: Label = $MarginContainer/VBoxContainer/ContenidoContainer/CalculationContainer/ResultLabel

# Result matrix display nodes
@onready var c11_label: Label = $MarginContainer/VBoxContainer/ContenidoContainer/MatricesContainer/ResultMatrixContainer/MatrixDisplay/Row1/C11
@onready var c12_label: Label = $MarginContainer/VBoxContainer/ContenidoContainer/MatricesContainer/ResultMatrixContainer/MatrixDisplay/Row1/C12
@onready var c21_label: Label = $MarginContainer/VBoxContainer/ContenidoContainer/MatricesContainer/ResultMatrixContainer/MatrixDisplay/Row2/C21
@onready var c22_label: Label = $MarginContainer/VBoxContainer/ContenidoContainer/MatricesContainer/ResultMatrixContainer/MatrixDisplay/Row2/C22

@export_tool_button("Test Navigation") var test_button = _next_step

# Navigation state
var current_step: int = -1  # -1 means no steps shown yet
var max_steps: int = 5
var matrix_a: Array[float] = []
var matrix_b: Array[float] = []
var result_matrix: Array[float] = [0.0, 0.0, 0.0, 0.0]

# Step-by-step calculation data
var calculation_steps: Array[Dictionary] = []

func _ready():
	# Configure matrix controllers
	if matrix_a_controller:
		matrix_a_controller.matrix_label = "A"
		matrix_a_controller.matrix_color = matrix_a_color
		matrix_a_controller.initial_matrix = [1.0, 2.0, 3.0, 4.0]
		matrix_a_controller.matrix_changed.connect(_on_matrix_changed)
	
	if matrix_b_controller:
		matrix_b_controller.matrix_label = "B"
		matrix_b_controller.matrix_color = matrix_b_color
		matrix_b_controller.initial_matrix = [2.0, 0.0, 1.0, 3.0]
		matrix_b_controller.matrix_changed.connect(_on_matrix_changed)
	
	# Connect button signals
	if prev_button:
		prev_button.pressed.connect(_prev_step)
	if next_button:
		next_button.pressed.connect(_next_step)
	if reset_button:
		reset_button.pressed.connect(_reset_navigation)
	
	await get_tree().process_frame
	_update_displays()

func _on_matrix_changed(_matrix: Array):
	_update_displays()

func _update_displays():
	if not matrix_a_controller or not matrix_b_controller:
		return
	
	matrix_a = matrix_a_controller.get_matrix()
	matrix_b = matrix_b_controller.get_matrix()
	
	# Prepare steps (just the highlighting patterns)
	_prepare_calculation_steps()
	
	# Update current step display
	_update_step_display()
	
	# Update button states
	_update_button_states()

func _calculate_result_matrix():
	# C[i,j] = sum(A[i,k] * B[k,j]) for k in [0,1]
	result_matrix[0] = matrix_a[0] * matrix_b[0] + matrix_a[1] * matrix_b[2]  # C11
	result_matrix[1] = matrix_a[0] * matrix_b[1] + matrix_a[1] * matrix_b[3]  # C12
	result_matrix[2] = matrix_a[2] * matrix_b[0] + matrix_a[3] * matrix_b[2]  # C21
	result_matrix[3] = matrix_a[2] * matrix_b[1] + matrix_a[3] * matrix_b[3]  # C22

func _prepare_calculation_steps():
	calculation_steps.clear()
	
	# Step 1: Show C11 multiplication pattern
	calculation_steps.append({
		"highlight_a": [[0,0], [0,1]],
		"highlight_b": [[0,0], [1,0]],
		"result_name": "C₁₁",
		"result_position": [0, 0]
	})
	
	# Step 2: Show C12 multiplication pattern  
	calculation_steps.append({
		"highlight_a": [[0,0], [0,1]],
		"highlight_b": [[0,1], [1,1]],
		"result_name": "C₁₂",
		"result_position": [0, 1]
	})
	
	# Step 3: Show C21 multiplication pattern
	calculation_steps.append({
		"highlight_a": [[1,0], [1,1]],
		"highlight_b": [[0,0], [1,0]],
		"result_name": "C₂₁",
		"result_position": [1, 0]
	})
	
	# Step 4: Show C22 multiplication pattern
	calculation_steps.append({
		"highlight_a": [[1,0], [1,1]],
		"highlight_b": [[0,1], [1,1]],
		"result_name": "C₂₂",
		"result_position": [1, 1]
	})
	
	# Step 5: Show final calculated values
	calculation_steps.append({
		"highlight_a": [],
		"highlight_b": [],
		"result_name": "Final",
		"result_position": [-1, -1]  # Special case for final step
	})

func _next_step():
	if current_step < max_steps - 1:
		current_step += 1
		_update_step_display()
		_update_button_states()

func _prev_step():
	if current_step >= 0:
		current_step -= 1
		_update_step_display()
		_update_button_states()

func _reset_navigation():
	current_step = -1
	
	# Clear highlights
	if matrix_a_controller:
		matrix_a_controller.clear_highlights()
	if matrix_b_controller:
		matrix_b_controller.clear_highlights()
	
	_update_step_display()
	_update_button_states()

func _update_step_display():
	if current_step == -1:
		# Initial state
		if equation_label:
			equation_label.text = "C = A × B"
		if result_label:
			result_label.text = ""
		_reset_result_matrix()
		return
	
	if current_step >= calculation_steps.size():
		return
	
	var step_data = calculation_steps[current_step]
	
	# Clear previous highlights
	if matrix_a_controller:
		matrix_a_controller.clear_highlights()
	if matrix_b_controller:
		matrix_b_controller.clear_highlights()
	
	# Highlight current elements
	for pos in step_data.highlight_a:
		if matrix_a_controller:
			matrix_a_controller.highlight_element(pos[0], pos[1], true)
	
	for pos in step_data.highlight_b:
		if matrix_b_controller:
			matrix_b_controller.highlight_element(pos[0], pos[1], true)
	
	# Update equation display
	if equation_label:
		if step_data.result_name == "Final":
			equation_label.text = "Matriz resultado final"
		else:
			equation_label.text = _build_equation_from_highlights(step_data)
	
	# Update result matrix display
	_update_result_matrix(current_step)
	
	# Build accumulative equations
	_build_accumulative_equations(current_step)

func _build_accumulative_equations(up_to_step: int):
	if not result_label:
		return
	
	var result_text = ""
	
	# Add all completed equations
	for i in range(up_to_step + 1):
		if i < calculation_steps.size():
			var step_data = calculation_steps[i]
			
			# Handle final step differently
			if step_data.result_name == "Final":
				_calculate_result_matrix()
				result_text += "\nResultados finales:\n"
				result_text += "C₁₁ = %.1f, C₁₂ = %.1f\n" % [result_matrix[0], result_matrix[1]]
				result_text += "C₂₁ = %.1f, C₂₂ = %.1f" % [result_matrix[2], result_matrix[3]]
			else:
				# Build equation dynamically using highlighted elements
				var equation = _build_equation_from_highlights(step_data)
				result_text += equation
				
				if i < up_to_step:  # Add separator between equations
					result_text += "\n"
	
	result_label.text = result_text

func _build_equation_from_highlights(step_data: Dictionary) -> String:
	var result_name = step_data.result_name
	var highlight_a = step_data.highlight_a
	var highlight_b = step_data.highlight_b
	
	# Get the matrix values for highlighted positions
	var a_vals = []
	var b_vals = []
	
	for pos in highlight_a:
		var row = pos[0]
		var col = pos[1]
		a_vals.append(matrix_a[row * 2 + col])
	
	for pos in highlight_b:
		var row = pos[0]
		var col = pos[1]
		b_vals.append(matrix_b[row * 2 + col])
	
	# Build equation: "C₁₁ = 1.0×2.0 + 2.0×1.0"
	return "%s = %.1f×%.1f + %.1f×%.1f" % [result_name, a_vals[0], b_vals[0], a_vals[1], b_vals[1]]

func _reset_result_matrix():
	# Reset all matrix elements to "?"
	if c11_label:
		c11_label.text = "?"
		c11_label.modulate = Color.WHITE
	if c12_label:
		c12_label.text = "?"
		c12_label.modulate = Color.WHITE
	if c21_label:
		c21_label.text = "?"
		c21_label.modulate = Color.WHITE
	if c22_label:
		c22_label.text = "?"
		c22_label.modulate = Color.WHITE

func _update_result_matrix(up_to_step: int):
	# Reset matrix first
	_reset_result_matrix()
	
	# Show elements progressively based on current step
	var element_labels = [c11_label, c12_label, c21_label, c22_label]
	var element_names = ["C₁₁", "C₁₂", "C₂₁", "C₂₂"]
	
	# Check if we're at the final step (step 4, which is index 4)
	if up_to_step == 4:
		# Final step: show calculated values
		_calculate_result_matrix()
		var calculated_values = ["%.1f" % result_matrix[0], "%.1f" % result_matrix[1], 
								"%.1f" % result_matrix[2], "%.1f" % result_matrix[3]]
		
		for i in range(element_labels.size()):
			if element_labels[i]:
				element_labels[i].text = calculated_values[i]
				element_labels[i].modulate = result_color
	else:
		# Regular steps: show symbolic names
		for i in range(up_to_step + 1):
			if i < element_labels.size() and element_labels[i]:
				element_labels[i].text = element_names[i]
				element_labels[i].modulate = result_color

func _update_button_states():
	if prev_button:
		prev_button.disabled = (current_step <= -1)
	
	if next_button:
		next_button.disabled = (current_step >= max_steps - 1)
