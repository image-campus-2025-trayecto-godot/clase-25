extends VBoxContainer

@onready var slider_y: HSlider = $HBoxContainer/SliderY
@onready var slider_x: HSlider = $HBoxContainer2/SliderX
@onready var slider_z: HSlider = $HBoxContainer3/SliderZ
@onready var ring_y: CSGTorus3D = %RingY
@onready var ring_x: CSGTorus3D = %RingX
@onready var ring_z: CSGTorus3D = %RingZ
@onready var reset: Button = $Reset
@onready var value_y: Label = $HBoxContainer/ValueY
@onready var value_x: Label = $HBoxContainer2/ValueX
@onready var value_z: Label = $HBoxContainer3/ValueZ


func _ready():
	reset_sliders()
	reset.pressed.connect(self.reset_sliders)

func reset_sliders():
	slider_y.value = rad_to_deg(PI/2)
	slider_x.value = rad_to_deg(PI/2)
	slider_z.value = rad_to_deg(PI/2)

func _process(delta: float) -> void:
	ring_y.rotation.y = deg_to_rad(slider_y.value)
	ring_x.rotation.z = deg_to_rad(slider_x.value)
	ring_z.rotation.z = deg_to_rad(slider_z.value)
	value_y.text = str(slider_y.value)
	value_x.text = str(slider_x.value)
	value_z.text = str(slider_z.value)
