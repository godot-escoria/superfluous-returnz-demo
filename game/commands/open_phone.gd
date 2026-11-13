## `open_phone()`
##
## Opens the phone menu over the game, as using the telephone does in Sosage
## (telephone.yaml: use -> trigger "Exit").
extends ESCBaseCommand


func configure() -> ESCCommandArgumentDescriptor:
	return ESCCommandArgumentDescriptor.new(0, [], [])


func run(_command_params: Array) -> int:
	# Deferred so the current event can finish before the tree is paused
	escoria.main.current_scene.game.call_deferred("pause_game")
	return ESCExecution.RC_OK


func interrupt():
	pass
