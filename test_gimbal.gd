@tool
extends Node3D

var rotation_minus_90_x: Basis = Basis(
	Vector3(1, 0, 0),
	Vector3(0, 0, -1),
	Vector3(0, 1, 0)
)

var rotation_minus_90_y: Basis = Basis(
	Vector3(0, 0, 1),
	Vector3(0, 1, 0),
	Vector3(1, 0, 0)
)

# rotation_minus_90_x * rotation_minus_90_y
# [X: (0.0, 1.0, 0.0), Y: (0.0, 0.0, -1.0), Z: (1.0, 0.0, 0.0)]

# rotation_minus_90_y * rotation_minus_90_x
# [X: (0.0, 0.0, 1.0), Y: (-1.0, 0.0, 0.0), Z: (0.0, 1.0, 0.0)]


var rotation_minus_90_z: Basis = Basis(
	Vector3(0, -1, 0),
	Vector3(1, 0, 0),
	Vector3(0, 0, 1)
)

func apply_basis_to_dado(some_basis: Basis):
	$"Example/Dado 2".basis = some_basis * $"Example/Dado 2".basis
