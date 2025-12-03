extends WorldEnvironment

func _process(delta: float) -> void:
	environment.sky_rotation.y -= delta / 50.0
