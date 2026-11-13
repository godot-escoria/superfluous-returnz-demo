## `show_code(code: String, result_global: String[, variant: String])`
##
## Shows a keypad window (Sosage "code") and waits until it is solved or
## closed. Sets the global `result_global` to true if the right code was
## entered, false otherwise. `variant` selects alternative images (e.g. the
## safe keypad covered with ashes).
##
## Codes are copied from Sosage's data/codes/*.yaml.
extends ESCBaseCommand


const WINDOWS := "res://game/images/windows/"

const CODES := {
	# data/codes/code_coffre_fort.yaml
	"safe": {
		"images": {"": "coffre_fort", "ashes": "coffre_fort_cendre"},
		"button_sound": "bip1",
		"success_sound": "succes1",
		"failure_sound": "echec",
		"buttons": [
			[0, 260, 672, 225, 200],
			[1, 25, 475, 225, 200], [2, 260, 475, 225, 200], [3, 500, 475, 225, 200],
			[4, 25, 250, 225, 200], [5, 260, 250, 225, 200], [6, 500, 250, 225, 200],
			[7, 25, 30, 225, 200], [8, 260, 30, 225, 200], [9, 500, 30, 225, 200],
		],
		"answer": [1, 9, 8, 9],
	},
	# data/codes/code_buste_gnu.yaml (1/2: ears, 3/4: nostrils)
	"gnu_bust": {
		"images": {"": "buste_gnu"},
		"cursor": "res://game/images/inventory/coton_tige.png",
		"button_sound": "gnou",
		"success_sound": "gnou_succes",
		"failure_sound": "gnou_echec",
		"buttons": [
			[1, 71, 423, 104, 98], [2, 181, 423, 104, 98],
			[3, 412, 423, 104, 98], [4, 518, 423, 104, 98],
		],
		"answer": [1, 4, 2, 2],
	},
}


func configure() -> ESCCommandArgumentDescriptor:
	return ESCCommandArgumentDescriptor.new(
		2, [TYPE_STRING, TYPE_STRING, TYPE_STRING], [null, null, ""]
	)


func validate(arguments: Array):
	if not super.validate(arguments):
		return false
	if not CODES.has(arguments[0]):
		raise_error(self, "Unknown code '%s'." % arguments[0])
		return false
	if not CODES[arguments[0]]["images"].has(arguments[2]):
		raise_error(self, "Unknown variant '%s' for code '%s'." % [arguments[2], arguments[0]])
		return false
	return true


func run(command_params: Array) -> int:
	var code: Dictionary = CODES[command_params[0]]
	var base: String = code["images"][command_params[2]]
	var w := SosageWindow.new()
	escoria.get_tree().root.add_child(w)
	w.open_code(
		load(WINDOWS + base + "_off.png"),
		load(WINDOWS + base + "_on.png"),
		code
	)
	await w.closed
	escoria.globals_manager.set_global(command_params[1], w.success)
	w.queue_free()
	return ESCExecution.RC_OK


func interrupt():
	pass
