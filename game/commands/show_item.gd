## `show_item(object: String, visible: Boolean)`
##
## Shows or hides an object without deactivating it (Sosage `show`/`hide` on
## a character), so it can still speak or be animated while hidden.
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
	escoria.object_manager.get_object(command_params[0]).node.visible = command_params[1]
	return ESCExecution.RC_OK


func interrupt():
	pass
