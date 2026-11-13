# Dialog choices like Sosage (Interface::update_dialog_choices()), over
# escoria-dialog-simple's chooser: the options are stacked from the bottom of
# the screen, left aligned, over a black band at 75 % opacity, in TovariSans
# 60 px (80 * 0.75), white; the hovered one takes the player's color.
# Used by addons/escoria-dialog-simple/chooser/simple.tscn (its script); the
# scene's own MarginContainer list stays hidden, these nodes are made here.
extends "res://addons/escoria-dialog-simple/chooser/simple.gd"


const FONT := preload("res://game/fonts/TovariSans.ttf")
const WORLD := Vector2(1920, 1080)
const FONT_SIZE := 60
const MARGIN := 10

var _background: ColorRect
var _choices: VBoxContainer


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_background = ColorRect.new()
	_background.color = Color(0, 0, 0, 0.752941)
	_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_background)
	_choices = VBoxContainer.new()
	_choices.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_choices.add_theme_constant_override("separation", 0)
	add_child(_choices)
	$Timer.one_shot = true
	super()


func _process(_delta: float) -> void:
	pass


func show_chooser():
	for c in _choices.get_children():
		_choices.remove_child(c)
		c.queue_free()

	var hover := Color("5FD38D")
	var player = escoria.main.current_scene.player if escoria.main.current_scene else null
	if player and "dialog_color" in player:
		hover = player.dialog_color

	for option in self.dialog.options:
		if not option.is_valid():
			continue
		var b := Button.new()
		b.text = tr((option as ESCDialogOption).option)
		b.flat = true
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_override("font", FONT)
		b.add_theme_font_size_override("font_size", FONT_SIZE)
		for state in ["font_color", "font_focus_color", "font_pressed_color"]:
			b.add_theme_color_override(state, Color.WHITE)
		b.add_theme_color_override("font_hover_color", hover)
		b.add_theme_color_override("font_hover_pressed_color", hover)
		var empty := StyleBoxEmpty.new()
		for style in ["normal", "hover", "pressed", "focus"]:
			b.add_theme_stylebox_override(style, empty)
		# Very long lines are shrunk to fit, as in Sosage
		var w := FONT.get_string_size(b.text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x
		if w > WORLD.x - 2 * MARGIN:
			b.add_theme_font_size_override("font_size", int(FONT_SIZE * (WORLD.x - 2 * MARGIN) / w))
		_choices.add_child(b)
		b.pressed.connect(_on_answer_selected.bind(option))

	if _choices.get_child_count() == 0:
		_no_more_options = true
		$Timer.start(0.05)
		return

	# Stack from the bottom of the screen
	_choices.reset_size()
	var h := _choices.get_combined_minimum_size().y
	_choices.position = Vector2(MARGIN, WORLD.y - MARGIN - h)
	_background.position = Vector2(0, WORLD.y - h - 2 * MARGIN)
	_background.size = Vector2(WORLD.x, h + 2 * MARGIN)
	_background.show()
	_choices.show()
	if self.dialog.timeout > 0 and self.dialog.get_timeout_option():
		$Timer.start(self.dialog.timeout)


func hide_chooser():
	super()
	if _choices:
		_choices.hide()
		_background.hide()


func _option_chosen(option: ESCDialogOption):
	hide_chooser()
	super(option)
