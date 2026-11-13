## `show_end_text(text: String)`
##
## Black screen with a centered text, until the player clicks (the end of the
## Sosage demo: flug.yaml text "fin_demo").
extends ESCBaseCommand


const FONT := preload("res://game/fonts/PTN77F.ttf")


func configure() -> ESCCommandArgumentDescriptor:
	return ESCCommandArgumentDescriptor.new(1, [TYPE_STRING], [null])


func run(command_params: Array) -> int:
	var layer := CanvasLayer.new()
	layer.layer = 30
	var root := ColorRect.new()
	root.color = Color.BLACK
	root.size = Vector2(1920, 1080)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(root)
	var label := Label.new()
	# ASHES strings only escape quotes: turn "\\n" into line breaks
	label.text = tr(command_params[0]).replace("\\n", "\n")
	label.add_theme_font_override("font", FONT)
	label.add_theme_font_size_override("font_size", 50)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.size = root.size
	root.add_child(label)
	escoria.get_tree().root.add_child(layer)
	root.modulate.a = 0.0
	escoria.get_tree().create_tween().tween_property(root, "modulate:a", 1.0, 0.5)
	while true:
		var event = await root.gui_input
		if event is InputEventMouseButton and event.pressed:
			break
	layer.queue_free()
	return ESCExecution.RC_OK


func interrupt():
	pass
