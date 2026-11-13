## `show_window(image: String)`
##
## Shows a full-size image centered on screen (a document, a plan...) until
## the player clicks, like Sosage's "show" on a window. `image` is a file name
## in res://game/images/windows/ without extension; a localized version
## (`name.en_US.png`) is used when it exists.
extends ESCBaseCommand


const WINDOWS := "res://game/images/windows/"
const FADE := 0.25   # Config::inventory_speed


func configure() -> ESCCommandArgumentDescriptor:
	return ESCCommandArgumentDescriptor.new(1, [TYPE_STRING], [null])


func validate(arguments: Array):
	if not super.validate(arguments):
		return false
	if SosageWindow.find_image(WINDOWS, arguments[0]) == "":
		raise_error(self, "Window image '%s' not found." % arguments[0])
		return false
	return true


func run(command_params: Array) -> int:
	var w := SosageWindow.new()
	escoria.get_tree().root.add_child(w)
	w.open(load(SosageWindow.find_image(WINDOWS, command_params[0])))
	await w.closed
	w.queue_free()
	return ESCExecution.RC_OK


func interrupt():
	pass
