## `action(character: String[, duration: Number[, pose: String]])`
##
## Plays one of the character's idle poses (Sosage `play: [pose, duration]`)
## then goes back to idle. `pose` is "action" (reaching for something,
## default) or "phone"; it follows the current direction and animation set
## (idle_right -> action_right, crouch_idle_left -> crouch_action_left).
## A negative duration keeps the pose and returns at once; `pose` "idle"
## goes back to idle.
extends ESCBaseCommand


func configure() -> ESCCommandArgumentDescriptor:
	return ESCCommandArgumentDescriptor.new(
		1, [TYPE_STRING, [TYPE_INT, TYPE_FLOAT], TYPE_STRING], [null, 0.2, "action"]
	)


func validate(arguments: Array):
	if not super.validate(arguments):
		return false
	if not escoria.object_manager.has(arguments[0]):
		raise_invalid_object_error(self, arguments[0])
		return false
	return true


func run(command_params: Array) -> int:
	var item: ESCItem = escoria.object_manager.get_object(command_params[0]).node
	if command_params[2] == "idle":
		item.update_idle()
		return ESCExecution.RC_OK
	var player: Node = item.get_animation_player()
	var idle: String = item.animations.idles[item._movable.last_dir].animation
	var pose: String = idle.replace("idle", command_params[2])
	if player.has_animation(pose):
		player.play(pose)
	if float(command_params[1]) < 0:
		return ESCExecution.RC_OK
	await escoria.get_tree().create_timer(float(command_params[1])).timeout
	item.update_idle()
	return ESCExecution.RC_OK


func interrupt():
	pass
