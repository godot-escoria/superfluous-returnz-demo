# Sosage-style mouse interface: software cursor, hover label and the
# 4-way action selector (Sosage's Interface::set_action_selector()).
class_name SosageInterface
extends CanvasLayer


# Emitted when the player picks a choice in the selector; "" if cancelled.
signal choice_made(choice: String)

const IMG := "res://game/images/interface/"
const CURSOR_SCALE := 0.5        # Interface::update_cursor()
const SELECTED_SCALE := 0.28     # item drawn on the cursor while combining
const LABEL_MARGIN := 20.0
const WORLD := Vector2(1920, 1080)
const DEPLOY_TIME := 0.25       # Config::inventory_speed
# Interface::wriggly_position(): selector items drift outwards and back
const WRIGGLE_RANGE := 5.0
const WRIGGLE_PERIOD := 0.75

# Cursor textures and their relative origins (File_IO::read_init_cursor())
var _cursors := {
	"default": [preload(IMG + "cursor.png"), Vector2(0.1, 0.1)],
	"object": [preload(IMG + "cursor_object.png"), Vector2(0.5, 0.5)],
	"goto_left": [preload(IMG + "gauche_aller.png"), Vector2(1.0, 0.5)],
	"goto_right": [preload(IMG + "droite_aller.png"), Vector2(0.0, 0.5)],
	"selected": [preload(IMG + "big_circle.png"), Vector2(0.5, 0.5)],
}

# Choice geometry relative to the click point (Interface::compute_action_positions())
const _ORIENT := {
	"up": {"button": Vector2(0, -40), "label": Vector2(0, -80), "start": Vector2(0, -14), "kind": SosageLabel.Kind.PLAIN},
	"down": {"button": Vector2(0, 40), "label": Vector2(0, 80), "start": Vector2(0, 14), "kind": SosageLabel.Kind.PLAIN},
	"left": {"button": Vector2(-40, 0), "label": Vector2(-40, 0), "start": Vector2(-14, 0), "kind": SosageLabel.Kind.OPEN_RIGHT},
	"right": {"button": Vector2(40, 0), "label": Vector2(40, 0), "start": Vector2(14, 0), "kind": SosageLabel.Kind.OPEN_LEFT},
}

var cursor_state: String = "default"

var _root: Control
var _cursor_layer: CanvasLayer
var _cursor: Sprite2D
var _selected_item: Sprite2D
var _hover: SosageLabel = null
var _hover_mode: String = ""     # "cursor" (follows the mouse), "fixed"
var _blocker: Control = null
var _choice_nodes: Array = []
# Selector items being animated: [node, deployed position, start position, direction]
var _choice_motion: Array = []
var _selector_time: float = 0.0


func _ready() -> void:
	add_to_group("sosage_interface")
	# The cursor keeps working while the game is paused (phone menu)
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	_root = Control.new()
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.size = WORLD
	add_child(_root)

	_cursor_layer = CanvasLayer.new()
	_cursor_layer.layer = 128
	add_child(_cursor_layer)
	_selected_item = Sprite2D.new()
	_selected_item.scale = Vector2(SELECTED_SCALE, SELECTED_SCALE)
	_selected_item.visible = false
	_cursor = Sprite2D.new()
	_cursor.centered = false
	_cursor.scale = Vector2(CURSOR_SCALE, CURSOR_SCALE)
	_cursor_layer.add_child(_cursor)
	_cursor_layer.add_child(_selected_item)
	set_cursor("default")

	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _exit_tree() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(delta: float) -> void:
	if not _choice_motion.is_empty():
		_animate_selector(delta)
	var p := mouse_position()
	_cursor.position = p
	_selected_item.position = p
	if _hover != null and _hover_mode == "cursor":
		_place_cursor_label(p)


func mouse_position() -> Vector2:
	return _root.get_global_mouse_position()


## CURSOR ##

func set_cursor(state: String, item_texture: Texture2D = null) -> void:
	cursor_state = state
	var c: Array = _cursors[state]
	var tex: Texture2D = c[0]
	_cursor.texture = tex
	_cursor.offset = -tex.get_size() * c[1]
	if state == "selected" and item_texture != null:
		_selected_item.texture = item_texture
		_selected_item.visible = true
	elif state != "selected":
		_selected_item.visible = false


## HOVER LABEL ##

# kind: "object", "goto_left", "goto_right"
func show_cursor_label(text: String, kind: String) -> void:
	clear_label()
	if text == "":
		return
	var k := SosageLabel.Kind.CURSOR_LEFT
	if kind == "goto_left":
		k = SosageLabel.Kind.GOTO_LEFT
	elif kind == "goto_right":
		k = SosageLabel.Kind.GOTO_RIGHT
	_hover = SosageLabel.make(text, k)
	_hover_mode = "cursor"
	_root.add_child(_hover)
	_place_cursor_label(mouse_position())
	_fade_in(_hover)


# Centered label at a fixed point (inventory items)
func show_fixed_label(text: String, center: Vector2) -> void:
	clear_label()
	if text == "":
		return
	_hover = SosageLabel.make(text, SosageLabel.Kind.PLAIN)
	_hover_mode = "fixed"
	_root.add_child(_hover)
	_hover.place(center)
	_clamp_x(_hover, LABEL_MARGIN)
	_fade_in(_hover)


func clear_label() -> void:
	if _hover != null:
		_hover.queue_free()
		_hover = null
	_hover_mode = ""


func _place_cursor_label(p: Vector2) -> void:
	_hover.place(p)
	# Labels that would leave the screen flip to the other side of the cursor
	if _hover.kind == SosageLabel.Kind.CURSOR_LEFT \
			and _hover.position.x + _hover.size.x > WORLD.x - SosageLabel.HEIGHT:
		_hover.kind = SosageLabel.Kind.CURSOR_RIGHT
		_hover._layout()
		_hover.place(p)
	elif _hover.kind == SosageLabel.Kind.CURSOR_RIGHT \
			and p.x + _hover.size.x <= WORLD.x - SosageLabel.HEIGHT:
		_hover.kind = SosageLabel.Kind.CURSOR_LEFT
		_hover._layout()
		_hover.place(p)


## ACTION SELECTOR ##

func is_selector_open() -> bool:
	return _blocker != null


# choices: Array of [id, text, orientation] with orientation in up/down/left/right
func open_selector(point: Vector2, choices: Array) -> void:
	close_selector()
	clear_label()

	_blocker = Control.new()
	_blocker.size = WORLD
	_blocker.mouse_filter = Control.MOUSE_FILTER_STOP
	_blocker.gui_input.connect(_on_blocker_input)
	_root.add_child(_blocker)

	point = _keep_selector_on_screen(point, choices)

	for c in choices:
		var id: String = c[0]
		var o: Dictionary = _ORIENT[c[2]]
		var label := SosageLabel.make(c[1], o["kind"])
		var button := SosageLabel.make("", SosageLabel.Kind.BUTTON)
		for n in [label, button]:
			n.mouse_filter = Control.MOUSE_FILTER_STOP
			n.gui_input.connect(_on_choice_input.bind(id))
			n.mouse_entered.connect(func(): button.highlighted = true)
			n.mouse_exited.connect(func(): button.highlighted = false)
			_root.add_child(n)
			_choice_nodes.append(n)
		# Interface::animate_label(DEPLOY): buttons slide out from the click
		# point growing from 0.177/0.5 of their size, labels grow from 0.05/0.5
		# and fade in
		label.place(point + o["label"])
		button.place(point + o["button"])
		var dir: Vector2 = o["button"].normalized()
		_choice_motion.append([button, button.position, button.position - o["button"] + o["start"], dir])
		_choice_motion.append([label, label.position, label.position, dir])
		button.scale = Vector2.ONE * (0.177 / 0.5)
		label.scale = Vector2.ONE * 0.1
		label.modulate.a = 0.0
		var t := create_tween().set_parallel()
		t.tween_property(button, "scale", Vector2.ONE, DEPLOY_TIME)
		t.tween_property(label, "scale", Vector2.ONE, DEPLOY_TIME)
		t.tween_property(label, "modulate:a", 1.0, DEPLOY_TIME)
	_selector_time = 0.0
	_animate_selector(0.0)


func _animate_selector(delta: float) -> void:
	_selector_time += delta
	var deploy: float = clamp(_selector_time / DEPLOY_TIME, 0.0, 1.0)
	# Sosage starts the sine at its low point, so items begin at rest
	var wriggle := WRIGGLE_RANGE * (0.5 + 0.5 * sin(-PI / 2 - DEPLOY_TIME + _selector_time / WRIGGLE_PERIOD))
	for m in _choice_motion:
		if is_instance_valid(m[0]):
			m[0].position = m[2].lerp(m[1], deploy) + m[3] * wriggle


func close_selector() -> void:
	for n in _choice_nodes:
		if is_instance_valid(n):
			n.queue_free()
	_choice_nodes.clear()
	_choice_motion.clear()
	if _blocker != null:
		_blocker.queue_free()
		_blocker = null


# Shift the whole selector so every label stays inside the screen
func _keep_selector_on_screen(point: Vector2, choices: Array) -> Vector2:
	var shift := Vector2.ZERO
	for c in choices:
		var o: Dictionary = _ORIENT[c[2]]
		var probe := SosageLabel.make(c[1], o["kind"])
		probe.place(point + o["label"])
		var r := Rect2(probe.position, probe.size)
		probe.free()
		if r.position.x < LABEL_MARGIN:
			shift.x = max(shift.x, LABEL_MARGIN - r.position.x)
		if r.end.x > WORLD.x - LABEL_MARGIN:
			shift.x = min(shift.x, WORLD.x - LABEL_MARGIN - r.end.x)
		if r.position.y < LABEL_MARGIN:
			shift.y = max(shift.y, LABEL_MARGIN - r.position.y)
		if r.end.y > WORLD.y - LABEL_MARGIN:
			shift.y = min(shift.y, WORLD.y - LABEL_MARGIN - r.end.y)
	return point + shift


func _on_choice_input(event: InputEvent, id: String) -> void:
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		close_selector()
		choice_made.emit(id)


func _on_blocker_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		get_viewport().set_input_as_handled()
		close_selector()
		choice_made.emit("")


## HELPERS ##

func _fade_in(node: CanvasItem) -> void:
	node.modulate.a = 0.0
	create_tween().tween_property(node, "modulate:a", 1.0, DEPLOY_TIME)


func _clamp_x(node: Control, margin: float) -> void:
	node.position.x = clamp(node.position.x, margin, WORLD.x - margin - node.size.x)
