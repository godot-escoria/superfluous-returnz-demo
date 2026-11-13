# The game menu drawn on Sophie's phone, as in Sosage (System/Menu.cpp,
# Menu__creations.cpp, Config values from Menu.h). The same scene is used for
# Escoria's main menu (mode "main") and pause menu (mode "pause", also opened
# by using the phone in the inventory).
extends Control


const IMG := "res://game/images/interface/"
const FONT: Font = preload("res://game/fonts/PTN77F.ttf")         # interface_font
const LIGHT_FONT: Font = preload("res://game/fonts/PTN57F.ttf")   # interface_light_font
const INFO_FONT: Font = preload("res://game/fonts/DejaVuSansMono.ttf")
const WORLD := Vector2(1920, 1080)

# Config (Menu.h)
const MENU_MARGIN := 90
const MENU_SMALL_MARGIN := 35
const OKNOTOK_Y := 858
const OK_X := 120
const NOTOK_X := 360
const EXIT_MENU_LOGO := 130
const EXIT_MENU_START := 220
const EXIT_MENU_TEXT := MENU_MARGIN + 60
const SETTINGS_MARGIN := 15
const SETTINGS_START := 135
const SETTINGS_HEIGHT := 100
const SETTINGS_IN_MARGIN := 20
const SETTINGS_VALUE_MARGIN := 75
const LARROW_X := SETTINGS_MARGIN + 370
const RARROW_X := SETTINGS_MARGIN + 420

const PHONE_SCRIPT := "res://game/items/inventory/phone.ash"

# Phone book (data/actions/numero_*.yaml labels)
const PHONE_BOOK := [
	["Hint Hotline", "04.65.71.19.45", "call_hints"],
	["Harpagon Lonion", "06.39.98.07.55", "call_harpagon"],
]

const TEXTS := {
	"wanna_quit": "Exit the game?\n",
	"wanna_restart": "Your progress will be\nlost.\n\nDo you want to start\nover?\n",
	"wanna_save": "The previous save point\nwill be overwritten.\n\nConfirm?\n",
	"saved": "Game saved!\n",
	"wanna_load": "Your progress will be\nlost.\n\nConfirm?\n",
	"no_phone_allowed": "You cannot make a\ncall at the moment.\n",
	"no_savegame": "No saved game\navailable.\n",
	"controls_mouse": "ESCAPE:\n  - while playing, access the menu\n\nRIGHT CLICK/SPACE:\n  - skip a line of dialogue\n",
}

const TEXT_SPEEDS := [["slow", 18.0 / 12.0], ["medium", 1.0], ["fast", 9.0 / 12.0]]

# Languages, named in their own language (Sosage: "English (US)", "Italiano (Italia)")
const LANGUAGES := [["en", "English (US)"], ["es", "Español"], ["fr", "Français (France)"],
		["de", "Deutsch"], ["it", "Italiano (Italia)"]]
const SAVE_SLOTS := 5

## "main" before a game is started, "pause" during the game
@export var mode: String = "pause"

var _phone: TextureRect
var _page: Control
var _ref: Vector2   # Sosage "Menu" reference point
var _shown_frame: int = -1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_STOP
	size = WORLD
	var overlay := ColorRect.new()
	# Sosage: Menu_overlay, black at 64/255 over the game; the start menu has
	# no game behind it
	overlay.color = Color(0, 0, 0, 64.0 / 255.0) if mode == "pause" else Color.BLACK
	overlay.size = WORLD
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)
	_phone = TextureRect.new()
	_phone.texture = load(IMG + "menu.png")
	_phone.size = _phone.texture.get_size()
	_phone.position = ((WORLD - _phone.size) / 2).round()
	_phone.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_phone)
	_ref = WORLD / 2 + Vector2(-240, -420)
	var info := Label.new()
	info.text = "Superfluous Returnz (demo)"
	info.add_theme_font_override("font", INFO_FONT)
	info.add_theme_font_size_override("font_size", 20)
	info.size = Vector2(600, 30)
	info.position = WORLD - info.size - Vector2(5, 5)
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(info)
	visibility_changed.connect(func(): _shown_frame = Engine.get_process_frames())
	hide()


## ESCGame API ##

func reset() -> void:
	_show_main()


func set_save_enabled(_enabled: bool) -> void:
	pass


## PAGES ##

func _new_page() -> Control:
	if _page:
		_page.queue_free()
	_page = Control.new()
	_page.size = WORLD
	_page.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_page)
	return _page


func _main_items() -> Array:
	if mode == "main":
		return [["new_game", "New game", "nouvelle_partie"], ["load", "Load", "load"],
				["settings", "Settings", "preferences"], ["controls", "Controls", "credits"],
				["quit", "Quit", "quitter"]]
	var items := [["phone", "Phone", "telephone"], ["settings", "Settings", "preferences"],
			["controls", "Controls", "credits"], ["new_game", "New game", "nouvelle_partie"],
			["load", "Load", "load"]]
	if escoria.save_manager.save_enabled:
		items.append(["save", "Save", "save"])
	items.append(["quit", "Quit", "quitter"])
	return items


# Sosage Menu::init() "Exit" menu
func _show_main() -> void:
	_new_page()
	_image(IMG + "menu_logo.png", _ref + Vector2(240, EXIT_MENU_LOGO))
	var items := _main_items()
	var y := float(EXIT_MENU_START)
	for it in items:
		var b := _button(IMG + "menu_bouton.png", _ref + Vector2(240, y), _on_main_item.bind(it[0]))
		_image(IMG + it[2] + ".png", _ref + Vector2(MENU_MARGIN, y))
		_text(tr(it[1]), FONT, 40, _ref + Vector2(EXIT_MENU_TEXT, y), Vector2(0, 0.5))
		y += MENU_MARGIN * (7.0 / items.size())
	if mode == "pause":
		_ok_alone(_close)


func _on_main_item(id: String) -> void:
	match id:
		"phone":
			_show_phone_book()
		"settings":
			_show_settings()
		"controls":
			_show_text("Controls", TEXTS["controls_mouse"], _show_main)
		"new_game":
			if mode == "main":
				escoria.new_game()
			else:
				_confirm("New game", TEXTS["wanna_restart"], func():
					_close()
					escoria.new_game())
		"load":
			_show_load()
		"save":
			_show_save()
		"quit":
			if mode == "main":
				escoria.quit()
			else:
				_confirm("Quit", TEXTS["wanna_quit"], func(): escoria.quit())


# Sosage Menu::update_phone_menu()
func _show_phone_book() -> void:
	if not _can_call():
		_show_text("Phone", TEXTS["no_phone_allowed"], _show_main)
		return
	_new_page()
	_title("Phone")
	var y := float(SETTINGS_START)
	for entry in PHONE_BOOK:
		_list_entry(y, tr(entry[0]), entry[1], _call.bind(entry[2]))
		y += SETTINGS_HEIGHT
	_ok_alone(_show_main)


func _can_call() -> bool:
	return mode == "pause" and escoria.main.current_scene != null \
			and escoria.object_manager.has("sophie")


func _call(event_name: String) -> void:
	_close()
	var script = escoria.esc_compiler.load_esc_file(PHONE_SCRIPT)
	escoria.event_manager.queue_event_from_esc(script, event_name, "_front", false)


# Sosage Menu::init_loadsave_menus(), Save menu
func _show_save() -> void:
	_new_page()
	_title("Save")
	var saves: Dictionary = escoria.save_manager.get_saves_list()
	var y := float(SETTINGS_START)
	for slot in range(1, SAVE_SLOTS + 1):
		var title := "%d. " % slot
		var info := tr("(Free slot)")
		if saves.has(slot):
			title += tr(saves[slot]["name"])
			info = _date(saves[slot]["date"])
		_list_entry(y, title, info, _on_save_slot.bind(slot, saves.has(slot)))
		y += SETTINGS_HEIGHT + SETTINGS_MARGIN
	_ok_alone(_show_main)


func _on_save_slot(slot: int, exists: bool) -> void:
	var do_save := func():
		escoria.save_manager.save_game(slot, _room_name())
		_show_text("Save", TEXTS["saved"], _show_main)
	if exists:
		_confirm("Save", TEXTS["wanna_save"], do_save, _show_save)
	else:
		do_save.call()


# Sosage Menu::init_loadsave_menus(), Load menu
func _show_load() -> void:
	_new_page()
	_title("Load")
	var saves: Dictionary = escoria.save_manager.get_saves_list()
	if saves.is_empty():
		_lines(TEXTS["no_savegame"])
	var y := float(SETTINGS_START)
	var slots := saves.keys()
	slots.sort()
	for slot in slots:
		_list_entry(y, "%d. %s" % [slot, tr(saves[slot]["name"])], _date(saves[slot]["date"]),
				_on_load_slot.bind(slot))
		y += SETTINGS_HEIGHT + SETTINGS_MARGIN
	_ok_alone(_show_main)


func _on_load_slot(slot: int) -> void:
	var do_load := func():
		_close()
		escoria.save_manager.load_game(slot)
	if mode == "pause":
		_confirm("Load", TEXTS["wanna_load"], do_load, _show_load)
	else:
		do_load.call()


# Sosage Menu::make_settings_item(): title, value and arrows
func _show_settings() -> void:
	_new_page()
	_title("Settings")
	var y := float(SETTINGS_START)
	var settings := [
		["Language", LANGUAGES[_language_index()][1],
			_change_language.bind(-1), _change_language.bind(1)],
		["Full screen", _fullscreen_text(), _toggle_fullscreen, _toggle_fullscreen],
		["Dialogue speed", tr(TEXT_SPEEDS[_text_speed_index()][0]),
			_change_text_speed.bind(-1), _change_text_speed.bind(1)],
		["Music volume", _volume_text(ESCProjectSettingsManager.MUSIC_VOLUME),
			_change_volume.bind(ESCProjectSettingsManager.MUSIC_VOLUME, -0.1),
			_change_volume.bind(ESCProjectSettingsManager.MUSIC_VOLUME, 0.1)],
		["Sound effects volume", _volume_text(ESCProjectSettingsManager.SFX_VOLUME),
			_change_volume.bind(ESCProjectSettingsManager.SFX_VOLUME, -0.1),
			_change_volume.bind(ESCProjectSettingsManager.SFX_VOLUME, 0.1)],
	]
	for s in settings:
		_image(IMG + "menu_bouton_preferences.png", _ref + Vector2(240, y + SETTINGS_HEIGHT / 2.0))
		_text(tr(s[0]), FONT, 40, _ref + Vector2(SETTINGS_MARGIN + SETTINGS_IN_MARGIN,
				y + SETTINGS_IN_MARGIN + SETTINGS_MARGIN), Vector2(0, 0.5), 415)
		_text(s[1], LIGHT_FONT, 36, _ref + Vector2(SETTINGS_MARGIN + SETTINGS_IN_MARGIN,
				y + SETTINGS_VALUE_MARGIN), Vector2(0, 0.5))
		_button(IMG + "gauche_menu.png", _ref + Vector2(LARROW_X, y + SETTINGS_VALUE_MARGIN), s[2], true)
		_button(IMG + "droite_menu.png", _ref + Vector2(RARROW_X, y + SETTINGS_VALUE_MARGIN), s[3], true)
		y += SETTINGS_HEIGHT + SETTINGS_MARGIN
	_ok_alone(func():
		escoria.settings_manager.save_settings()
		_show_main())


func _language_index() -> int:
	var locale := TranslationServer.get_locale()
	for i in LANGUAGES.size():
		if locale.begins_with(LANGUAGES[i][0]):
			return i
	return 0


func _change_language(delta: int) -> void:
	var i := wrapi(_language_index() + delta, 0, LANGUAGES.size())
	TranslationServer.set_locale(LANGUAGES[i][0])
	ESCProjectSettingsManager.set_setting(ESCProjectSettingsManager.TEXT_LANG, LANGUAGES[i][0])
	_show_settings()


func _fullscreen_text() -> String:
	var fs := DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN,
			DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]
	return tr("yes") if fs else tr("no")


func _toggle_fullscreen() -> void:
	var fs := DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN,
			DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]
	ESCProjectSettingsManager.set_setting(ESCProjectSettingsManager.FULLSCREEN, not fs)
	escoria.settings_manager.apply_settings()
	_show_settings()


func _volume_text(setting: String) -> String:
	# Sosage shows "100 %" (with a space, as in the original)
	return "%d %%" % int(round(ESCProjectSettingsManager.get_setting(setting) * 100))


func _change_volume(setting: String, delta: float) -> void:
	var v: float = clamp(ESCProjectSettingsManager.get_setting(setting) + delta, 0.0, 1.0)
	ESCProjectSettingsManager.set_setting(setting, snappedf(v, 0.1))
	escoria.settings_manager.apply_settings()
	_show_settings()


func _text_speed_index() -> int:
	var factor: float = escoria.settings_manager.get_custom_setting("text_speed", 1.0)
	for i in TEXT_SPEEDS.size():
		if is_equal_approx(TEXT_SPEEDS[i][1], factor):
			return i
	return 1


func _change_text_speed(delta: int) -> void:
	var i := clampi(_text_speed_index() + delta, 0, TEXT_SPEEDS.size() - 1)
	escoria.settings_manager.custom_settings["text_speed"] = TEXT_SPEEDS[i][1]
	_show_settings()


## SMALL PAGES ##

# Sosage make_text_menu_title + make_text_menu_text + OK
func _show_text(title: String, text: String, on_ok: Callable) -> void:
	_new_page()
	_title(title)
	_lines(text)
	_ok_alone(on_ok)


func _confirm(title: String, text: String, on_ok: Callable, on_cancel: Callable = _show_main) -> void:
	_new_page()
	_title(title)
	_lines(text)
	_button_box(Vector2(230, 50), _ref + Vector2(OK_X, OKNOTOK_Y), on_ok)
	_image(IMG + "ok.png", _ref + Vector2(OK_X, OKNOTOK_Y))
	_button_box(Vector2(230, 50), _ref + Vector2(NOTOK_X, OKNOTOK_Y), on_cancel)
	_image(IMG + "annuler.png", _ref + Vector2(NOTOK_X, OKNOTOK_Y))


func _title(text: String) -> void:
	_text(tr(text), FONT, 60, _ref + Vector2(240, MENU_MARGIN), Vector2(0.5, 0.5))


func _lines(text: String) -> void:
	var y := float(EXIT_MENU_START)
	for line in tr(text).split("\n"):
		_text(line, LIGHT_FONT, 40, _ref + Vector2(MENU_SMALL_MARGIN, y), Vector2(0, 0))
		y += MENU_SMALL_MARGIN


func _list_entry(y: float, title: String, subtitle: String, callback: Callable) -> void:
	_button(IMG + "menu_bouton_preferences.png", _ref + Vector2(240, y + SETTINGS_HEIGHT / 2.0), callback)
	_text(title, FONT, 40, _ref + Vector2(SETTINGS_MARGIN + SETTINGS_IN_MARGIN,
			y + SETTINGS_IN_MARGIN + SETTINGS_MARGIN), Vector2(0, 0.5), 415)
	_text(subtitle, LIGHT_FONT, 36, _ref + Vector2(SETTINGS_MARGIN + SETTINGS_IN_MARGIN,
			y + SETTINGS_VALUE_MARGIN), Vector2(0, 0.5), 415)


func _ok_alone(callback: Callable) -> void:
	_button_box(Vector2(460, 50), _ref + Vector2(240, OKNOTOK_Y), callback)
	_image(IMG + "ok.png", _ref + Vector2(240, OKNOTOK_Y))


## WIDGETS ##

func _image(path: String, center: Vector2) -> TextureRect:
	var t := TextureRect.new()
	t.texture = load(path)
	t.size = t.texture.get_size()
	t.position = (center - t.size / 2).round()
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_page.add_child(t)
	return t


# A Label whose `anchor` (0..1 of its size) is placed on `point`
func _text(text: String, font: Font, font_size: int, point: Vector2, anchor: Vector2,
		max_width: float = 0.0) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_override("font", font)
	var w := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	if max_width > 0 and w > max_width:
		font_size = int(font_size * max_width / w)
		w = max_width
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", Color.WHITE)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var h := font.get_height(font_size)
	l.size = Vector2(w, h)
	l.position = (point - Vector2(w, h) * anchor).round()
	_page.add_child(l)
	return l


# Image button; Sosage highlights the hovered button with a white overlay
func _button(path: String, center: Vector2, callback: Callable, small: bool = false) -> TextureButton:
	var b := TextureButton.new()
	b.texture_normal = load(path)
	b.size = b.texture_normal.get_size()
	b.position = (center - b.size / 2).round()
	b.mouse_entered.connect(func(): b.modulate = Color(1.6, 1.6, 1.6))
	b.mouse_exited.connect(func(): b.modulate = Color.WHITE)
	b.pressed.connect(callback)
	_page.add_child(b)
	return b


# Plain dark box button (Sosage Ok_button: black at 64/255)
func _button_box(box: Vector2, center: Vector2, callback: Callable) -> void:
	var b := Button.new()
	b.flat = true
	b.size = box
	b.position = (center - box / 2).round()
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0, 0, 0, 64.0 / 255.0)
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(1, 1, 1, 64.0 / 255.0)
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", hover)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	b.pressed.connect(callback)
	_page.add_child(b)


func _close() -> void:
	if mode == "pause":
		escoria.main.current_scene.game.unpause_game()
	else:
		hide()


func _date(d: Dictionary) -> String:
	return "%02d/%02d/%04d %02d:%02d" % [d["day"], d["month"], d["year"], d["hour"], d["minute"]]


# Save names: Sosage rooms' "name" (English locale)
func _room_name() -> String:
	var gid: String = escoria.main.current_scene.global_id if escoria.main.current_scene else ""
	match gid:
		"room_desk":
			return "Office"
		"room_flug":
			return "Fluouscave"
	return gid


func _unhandled_input(event: InputEvent) -> void:
	# ESC closes the phone like its OK button (but not the ESC press that
	# just opened it, which reaches us right after ESCGame opened the menu)
	if visible and mode == "pause" and event.is_action_pressed("ui_cancel") \
			and Engine.get_process_frames() > _shown_frame:
		get_viewport().set_input_as_handled()
		_close()
