# A Sosage "window": an image centered on screen, faded in/out, closed by a
# click. With a code (keypad), clicks on its buttons are recorded and checked
# against the answer (Sosage: Control::code_mouse(), Logic::update_code(),
# Interface::update_code_hover()).
class_name SosageWindow
extends CanvasLayer


signal closed

const WORLD := Vector2(1920, 1080)
const FADE := 0.25           # Config::inventory_speed
const CLICK_TIME := 0.1      # Config::button_click_duration
const RESULT_SUCCESS := preload("res://game/images/interface/code_succes.png")
const RESULT_FAILURE := preload("res://game/images/interface/code_echec.png")
const EFFECTS := "res://game/sounds/effects/"

# True if the code was entered correctly before the window closed
var success: bool = false

var _root: Control
var _image: TextureRect
var _code: Dictionary = {}
var _on_texture: Texture2D
var _proposal: Array = []
var _flash: TextureRect
var _hover: ColorRect
var _locked: bool = false
var _closing: bool = false
var _sound: AudioStreamPlayer


# File for `name` in `dir`, preferring the version for the current locale
# (the untranslated images are the French originals).
static func find_image(dir: String, name: String) -> String:
	var locale := TranslationServer.get_locale()
	var candidates: Array = []
	if locale.begins_with("it"):
		candidates.append(name + ".it_IT")
	elif not locale.begins_with("fr"):
		candidates.append(name + ".en_US")
	candidates.append(name)
	for c in candidates:
		var path: String = dir + c + ".png"
		if ResourceLoader.exists(path):
			return path
	return ""


func _ready() -> void:
	layer = 20
	_root = Control.new()
	_root.size = WORLD
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.gui_input.connect(_on_input)
	add_child(_root)
	_sound = AudioStreamPlayer.new()
	if AudioServer.get_bus_index("SFX") != -1:
		_sound.bus = "SFX"
	add_child(_sound)


func open(texture: Texture2D) -> void:
	_image = TextureRect.new()
	_image.texture = texture
	_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_image.size = texture.get_size()
	_image.position = ((WORLD - _image.size) / 2).round()
	_root.add_child(_image)
	_image.modulate.a = 0.0
	create_tween().tween_property(_image, "modulate:a", 1.0, FADE)


# code: {"buttons": [[value, x, y, w, h], ...], "answer": [...],
#        "button_sound", "success_sound", "failure_sound"}
func open_code(off: Texture2D, on: Texture2D, code: Dictionary) -> void:
	open(off)
	# The item used on the keypad follows the cursor (e.g. the Q-tip on the bust)
	if code.has("cursor"):
		var ui = get_tree().get_first_node_in_group("sosage_interface")
		if ui:
			ui.set_cursor("selected", load(code["cursor"]))
	_code = code
	_on_texture = on
	_hover = ColorRect.new()
	_hover.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var color: Color = Color("5FD38D")
	var player = escoria.main.current_scene.player if escoria.main.current_scene else null
	if player and "dialog_color" in player:
		color = player.dialog_color
	color.a = 0.5
	_hover.color = color
	_hover.visible = false
	_image.add_child(_hover)
	_flash = TextureRect.new()
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash.visible = false
	_image.add_child(_flash)


func _on_input(event: InputEvent) -> void:
	if _closing:
		return
	if event is InputEventMouseMotion and not _code.is_empty():
		var b = _button_at(event.position - _image.position)
		_hover.visible = b != null and not _locked
		if b != null:
			_hover.position = Vector2(b[1], b[2])
			_hover.size = Vector2(b[3], b[4])
	elif event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		if _locked:
			return
		var p: Vector2 = event.position - _image.position
		var inside := Rect2(Vector2.ZERO, _image.size).has_point(p)
		if _code.is_empty() or not inside:
			close()
		else:
			var b = _button_at(p)
			if b != null:
				_press(b)


func _button_at(p: Vector2):
	for b in _code.get("buttons", []):
		if Rect2(b[1], b[2], b[3], b[4]).has_point(p):
			return b
	return null


func _press(b: Array) -> void:
	# Show the "on" version of the button for a moment
	var atlas := AtlasTexture.new()
	atlas.atlas = _on_texture
	atlas.region = Rect2(b[1], b[2], b[3], b[4])
	_flash.texture = atlas
	_flash.position = Vector2(b[1], b[2])
	_flash.size = Vector2(b[3], b[4])
	_flash.visible = true
	get_tree().create_timer(CLICK_TIME).timeout.connect(func(): _flash.visible = false)

	_proposal.append(b[0])
	var answer: Array = _code["answer"]
	if _proposal.size() < answer.size():
		_play(_code["button_sound"])
		return
	var ok := _proposal == answer
	_proposal.clear()
	_play(_code["success_sound"] if ok else _code["failure_sound"])
	_show_result(ok)
	if ok:
		success = true
		_locked = true
		_hover.visible = false
		get_tree().create_timer(CLICK_TIME).timeout.connect(close)


func _show_result(ok: bool) -> void:
	var r := TextureRect.new()
	r.texture = RESULT_SUCCESS if ok else RESULT_FAILURE
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	r.size = r.texture.get_size()
	r.position = ((WORLD - r.size) / 2).round()
	_root.add_child(r)
	get_tree().create_timer(CLICK_TIME * 5).timeout.connect(r.queue_free)


func _play(sound: String) -> void:
	var path := EFFECTS + sound + ".ogg"
	if ResourceLoader.exists(path):
		_sound.stream = load(path)
		_sound.play()


func close() -> void:
	if _closing:
		return
	_closing = true
	if _hover:
		_hover.visible = false
	var t := create_tween()
	t.tween_property(_image, "modulate:a", 0.0, FADE)
	# Let a success result/sound finish before handing control back
	t.tween_interval(CLICK_TIME * 4 if success else 0.0)
	await t.finished
	if _code.has("cursor"):
		var ui = get_tree().get_first_node_in_group("sosage_interface")
		if ui:
			ui.set_cursor("default")
	closed.emit()
