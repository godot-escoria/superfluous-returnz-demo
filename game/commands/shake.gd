## `shake(intensity: Number, duration: Number)`
##
## Shakes the camera horizontally (Sosage `shake: [intensity, duration]`).
## Doesn't block.
extends ESCBaseCommand


func configure() -> ESCCommandArgumentDescriptor:
	return ESCCommandArgumentDescriptor.new(
		2, [[TYPE_INT, TYPE_FLOAT], [TYPE_INT, TYPE_FLOAT]], [null, null]
	)


func run(command_params: Array) -> int:
	var camera := escoria.get_viewport().get_camera_2d()
	if camera == null:
		return ESCExecution.RC_OK
	var intensity := float(command_params[0])
	var duration := float(command_params[1])
	var t := escoria.get_tree().create_tween()
	var steps := int(duration / 0.05)
	for i in steps:
		# Sosage: amplitude decreases linearly over the duration
		var a := intensity * (1.0 - float(i) / steps)
		t.tween_property(camera, "offset:x", a if i % 2 == 0 else -a, 0.05)
	t.tween_property(camera, "offset:x", 0.0, 0.05)
	return ESCExecution.RC_OK


func interrupt():
	pass
