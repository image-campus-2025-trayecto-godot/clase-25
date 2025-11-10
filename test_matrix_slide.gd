@tool
extends EditorScript

func _run():
	print("Testing Matrix Slide Components...")
	
	# Check if MatrixController class exists
	var matrix_controller_script = load("res://diapositivas/components/MatrixController.gd")
	if matrix_controller_script:
		print("✓ MatrixController script found")
	else:
		print("✗ MatrixController script missing")
	
	# Check if MatrixController scene exists
	var matrix_controller_scene = load("res://diapositivas/components/MatrixController.tscn")
	if matrix_controller_scene:
		print("✓ MatrixController scene found")
	else:
		print("✗ MatrixController scene missing")
	
	# Check if matrices slide script exists
	var matrices_script = load("res://diapositivas/matrices_multiplicacion.gd")
	if matrices_script:
		print("✓ Matrix multiplication script found")
	else:
		print("✗ Matrix multiplication script missing")
	
	print("Matrix slide test completed!")
