extends "res://components/sr-ui-simplemouse/patterns/state_machine/state.gd"

var _ready_to_choose: bool



func initialize() -> void:
	pass

func enter():
	escoria.logger.trace(self, "Verbs chooser: Entered 'displayed'.")
	_ready_to_choose = true


func update(_delta):
	if _ready_to_choose:
		_ready_to_choose = false
		_dialog_chooser_ui.do_choose(_dialog_player, _dialog, _type)
		var option = await _dialog_chooser_ui.option_chosen

		escoria.logger.trace(self, "Dialog State Machine: 'displayed' -> 'hidden'")

		finished.emit("hidden")
		_dialog_player.option_chosen.emit(option)
