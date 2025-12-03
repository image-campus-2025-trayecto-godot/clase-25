@tool
extends Sprite2D

@export var mi_transform: Transform2D

func _process(delta: float) -> void:
	
	transform = (get_parent() as Node2D).transform.affine_inverse() * mi_transform
