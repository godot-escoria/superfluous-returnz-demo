## `crouch(character: String, crouched: Boolean)`
##
## Switches the character between its standing and crouched animation sets
## (Sosage swaps "sophie" for "sophie_accroupie"). The crouched set is
## `<animations>` with `_crouch` before `_animations.tres`.
extends ESCBaseCommand


func configure() -> ESCCommandArgumentDescriptor:
	return ESCCommandArgumentDescriptor.new(2, [TYPE_STRING, TYPE_BOOL], [null, null])


func validate(arguments: Array):
	if not super.validate(arguments):
		return false
	if not escoria.object_manager.has(arguments[0]):
		raise_invalid_object_error(self, arguments[0])
		return false
	return true


func run(command_params: Array) -> int:
	var item: ESCItem = escoria.object_manager.get_object(command_params[0]).node
	var path: String = item.animations.resource_path
	var standing := path.replace("_crouch_animations.tres", "_animations.tres")
	var crouched := standing.replace("_animations.tres", "_crouch_animations.tres")
	var target := crouched if command_params[1] else standing
	if target != path and ResourceLoader.exists(target):
		item.animations = load(target)
	item.update_idle()
	return ESCExecution.RC_OK


func interrupt():
	pass
