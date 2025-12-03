extends Node3D

@export var tiempo_rotacion: float = 1.0
@onready var usando_cuaterniones: CheckBox = $"../../CanvasLayer/PanelContainer2/VBoxContainer/HBoxContainer/UsandoCuaterniones"
@onready var copiar_rotacion_boton: Button = %CopiarRotacionBoton
@onready var dado_objetivo: Node3D = $"../RingY/RingX/RingZ/Dado "

var from_rotation: Vector3
var target_rotation: Vector3

func interpolate_rotation(value):
	if usando_cuaterniones.button_pressed:
		var quat = Quaternion.from_euler(from_rotation)
		var target_quat = Quaternion.from_euler(target_rotation)
		var result_quat: Quaternion = quat.slerp(target_quat, value)
		global_rotation = result_quat.get_euler()
	else:
		global_rotation = from_rotation.slerp(target_rotation, value)

func _ready():
	copiar_rotacion_boton.pressed.connect(self.copiar_rotacion)

func copiar_rotacion():
	from_rotation = global_rotation
	target_rotation = dado_objetivo.global_rotation
	create_tween().tween_method(interpolate_rotation, 0.0, 1.0, tiempo_rotacion)
