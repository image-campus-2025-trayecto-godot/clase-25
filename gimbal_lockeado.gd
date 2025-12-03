@tool
extends Node3D

func _process(delta: float) -> void:
	$"../CSGTorus3D2".rotation.x = rotation.x
	$"../CSGTorus3D".rotation.y = rotation.y
	$"../CSGTorus3D3".rotation.z = rotation.z
