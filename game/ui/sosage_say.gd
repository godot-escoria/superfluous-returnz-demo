# Speech above the character's head like Sosage (Logic::create_dialog,
# Logic::function_talk), over escoria-dialog-simple's floating dialog: the
# whole line at once, split into similar parts, TovariSans 60 px (80 * 0.75)
# with a black outline; lips move 0.05 s per character; the line stays
# (1.5 + 0.05 * characters) s scaled by the phone's "Dialogue speed"; SPACE
# skips it, even in cutscenes that block input.
# Used by addons/escoria-dialog-simple/types/floating.tscn (its script).
extends "res://addons/escoria-dialog-simple/types/floating.gd"


const FONT := preload("res://game/fonts/TovariSans.ttf")
const FONT_SIZE := 60
const OUTLINE_SIZE := 15
const SOSAGE_WIDTH_MAX := 960          # 0.5 * world_width
const SOSAGE_CHAR_WIDTH := 18.75       # 25 * 0.75, estimate used to split lines
const SOSAGE_MARGIN_X := 50
const SOSAGE_MIN_Y := 100
const SOSAGE_MIN_READING_TIME := 1.5   # seconds
const SOSAGE_CHAR_SPOKEN_TIME := 0.05  # seconds per character (lips moving)

# Incremented on every line, so an old lips timer doesn't stop a newer line
var _say_id: int = 0
# whose lips are moving (the line's timer stops them; a new line by someone
# else stops them at once)
var _talking: Node = null


func _ready():
	super()
	clip_contents = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	fit_content = true
	scroll_active = false
	autowrap_mode = TextServer.AUTOWRAP_OFF
	add_theme_font_override("normal_font", FONT)
	add_theme_font_size_override("normal_font_size", FONT_SIZE)
	add_theme_color_override("font_outline_color", Color.BLACK)
	add_theme_constant_override("outline_size", OUTLINE_SIZE)
	$Timer.one_shot = true


func _process(_delta):
	if _current_character.is_inside_tree() and \
			is_instance_valid(dialog_location_node):
		_place_above(dialog_location_node.get_global_transform_with_canvas().origin)


# Sosage: SPACE ends the line (a click does it through the dialog states)
func _input(event: InputEvent) -> void:
	if not visible or _text_timing_finished or $Timer.is_stopped():
		return
	if event is InputEventKey and event.pressed and not event.echo \
			and event.physical_keycode == KEY_SPACE:
		get_viewport().set_input_as_handled()
		_on_dialog_finished()


func say(character: String, line: String):
	_current_line = line
	_text_timing_finished = false
	_waiting_for_voice_audio = false

	show()

	_is_speeding_up = false

	_current_character = escoria.object_manager.get_object(character).node

	for c in _current_character.get_children():
		if c is ESCDialogLocation:
			dialog_location_node = c

	var text_color_html: String = _current_character.dialog_color.to_html(false)
	var lines := _split_like_sosage(tr(line))
	text_node.text = "[center][color=#" + text_color_html + "]" \
		+ "\n".join(lines) + "[/color][/center]"
	size.x = _measure_width(lines)

	if _current_character.is_inside_tree() and \
			is_instance_valid(dialog_location_node):
		_place_above(dialog_location_node.get_global_transform_with_canvas().origin)
	else:
		_place_above(Vector2(
			ProjectSettings.get_setting("display/window/size/viewport_width") / 2.0,
			ProjectSettings.get_setting("display/window/size/viewport_height") / 2.0))

	# The whole line at once; the lips move for 0.05 s per character. Someone
	# else still moving their lips (a line skipped before its time) stops now:
	# the timer below only stops the lips of the latest line.
	if is_instance_valid(_talking) and _talking != _current_character:
		_talking.stop_talking()
	_talking = _current_character
	_current_character.start_talking()
	_say_id += 1
	var this_say := _say_id
	var talking_character = _current_character
	get_tree().create_timer(SOSAGE_CHAR_SPOKEN_TIME * len(_current_line)).timeout.connect(
		func():
			if this_say == _say_id and is_instance_valid(talking_character):
				talking_character.stop_talking()
				_talking = null
	)

	text_node.visible_ratio = 1.0
	tween.reset()
	tween.interpolate_property(text_node, "visible_ratio",
		1.0, 1.0, 0.0, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.play()
	set_process(true)


# The line is shown: wait, then finish. (escoria-dialog-simple would stop the
# lips here; Sosage keeps them moving for 0.05 s per character.)
func _on_dialog_line_typed(_object, _key):
	text_node.visible_characters = -1
	_waiting_for_voice_audio = false
	$Timer.start(_calculate_time_to_disappear())
	if not $Timer.timeout.is_connected(_on_dialog_finished):
		$Timer.timeout.connect(_on_dialog_finished)
	say_visible.emit()


func _calculate_time_to_disappear() -> float:
	# Sosage: (min_reading_time + nb_char * char_spoken_time) at medium speed,
	# scaled by the "Dialogue speed" setting of the phone menu
	var speed: float = escoria.settings_manager.get_custom_setting("text_speed", 1.0)
	return (SOSAGE_MIN_READING_TIME + SOSAGE_CHAR_SPOKEN_TIME * len(_current_line)) * speed


# Split a line into roughly equal parts at spaces, as Sosage does.
func _split_like_sosage(line: String) -> PackedStringArray:
	var estimated := SOSAGE_CHAR_WIDTH * line.length()
	if estimated < SOSAGE_WIDTH_MAX:
		return PackedStringArray([line])
	var nb := 1 + int(estimated / SOSAGE_WIDTH_MAX)
	var result := PackedStringArray()
	var begin := 0
	for i in range(1, nb):
		var cut := int(i * (line.length() / float(nb)))
		var before := cut
		while before > begin and line[before] != " ":
			before -= 1
		var after := cut
		while after < line.length() and line[after] != " ":
			after += 1
		var best := before
		if line[before] != " " or \
				(after < line.length() and after - cut < cut - before):
			best = after
		if best <= begin or best >= line.length():
			continue
		result.append(line.substr(begin, best - begin))
		begin = best + 1
	result.append(line.substr(begin))
	return result


func _measure_width(lines: PackedStringArray) -> float:
	var width := 0.0
	for l in lines:
		width = max(width, FONT.get_string_size(l, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x)
	# Room for the outline on both sides plus shaping differences
	return ceil(width) + 2 * OUTLINE_SIZE + 8


# Place the text block centered on x, its bottom on the character's label.
func _place_above(label: Vector2) -> void:
	position.x = label.x - size.x / 2
	position.y = max(label.y - size.y, SOSAGE_MIN_Y)
	_account_for_margin_x()
	_account_for_margin_y()


func _account_for_margin_x() -> void:
	if position.x < SOSAGE_MARGIN_X:
		position.x = SOSAGE_MARGIN_X

	var screen_margin_x = position.x + size.x + SOSAGE_MARGIN_X - \
			ProjectSettings.get("display/window/size/viewport_width")

	if screen_margin_x > 0:
		position.x -= screen_margin_x
