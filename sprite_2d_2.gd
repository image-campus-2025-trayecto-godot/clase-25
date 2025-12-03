@tool
extends Sprite2D

@export var mi_transform: Transform2D
@onready var sprite_2d: Sprite2D = $"../Sprite2D"

func _process(delta: float) -> void:
	transform = sprite_2d.transform.affine_inverse()
