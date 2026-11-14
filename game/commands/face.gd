## `face(character: String, target: String)`
##
## Sosage's `look: [target]`: the character faces the target's side, right if
## the target is to its right, else left (Sosage only compares x). Escoria's
## turn_to takes the angle to the target instead, and a target almost straight
## above or below falls in the "up" / "down" direction, whose idle animation is
## one side or the other whatever side the target is on (Sophie unlocking the
## secret passage looked left at a passage on her right).
extends ESCBaseCommand


func configure() -> ESCCommandArgumentDescriptor:
	return ESCCommandArgumentDescriptor.new(
		2, [TYPE_STRING, TYPE_STRING], [null, null]
	)


func validate(arguments: Array):
	if not super.validate(arguments):
		return false
	for id in arguments:
		if not escoria.object_manager.has(id):
			raise_invalid_object_error(self, id)
			return false
	return true


func run(command_params: Array) -> int:
	var item: ESCItem = escoria.object_manager.get_object(command_params[0]).node
	var target: Node2D = escoria.object_manager.get_object(command_params[1]).node
	var dx: float = target.global_position.x - item.global_position.x
	if dx == 0.0:
		return ESCExecution.RC_OK
	# Escoria's angles (0 up, 90 right, 270 left), less 90 as set_angle.gd passes them
	var angle: int = 90 if dx > 0.0 else 270
	item.set_angle(wrapi(angle - 90, 0, 360))
	return ESCExecution.RC_OK


func interrupt():
	pass
