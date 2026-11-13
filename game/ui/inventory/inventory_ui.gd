# Sosage-style inventory: a black 150 px bar that slides up from the bottom,
# with an "Inventory" tab and chamfer that stay visible while idle.
# (Sosage: Interface::init() and Interface::update_inventory())
extends ESCInventory


enum Mode { HIDDEN, TAB, OPEN }

const WORLD_HEIGHT := 1080.0
const HEIGHT := 150.0          # Config::inventory_height
const ACTIVE_ZONE := 50.0      # Config::inventory_active_zone
const SPEED := 0.25            # Config::inventory_speed
const LABEL_MARGIN := 20.0
const ITEM_SCALE := 0.7
const ITEM_ACTIVE_SCALE := 0.9

var mode: int = Mode.HIDDEN
var _tween: Tween = null

@onready var panel: Control = $panel
@onready var container: Control = $panel/container


func _ready() -> void:
	super._ready()
	$panel/tab/label.text = tr("Inventory")
	_layout_tab()
	panel.position.y = _target_y(Mode.HIDDEN)


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		$panel/tab/label.text = tr("Inventory")
		_layout_tab()


func _layout_tab() -> void:
	var label: Label = $panel/tab/label
	var font: Font = label.get_theme_font("font")
	var tw := font.get_string_size(label.text, HORIZONTAL_ALIGNMENT_LEFT, -1,
		label.get_theme_font_size("font_size")).x
	var w := ceilf(LABEL_MARGIN + tw)
	$panel/tab.size = Vector2(w, ACTIVE_ZONE)
	$panel/chamfer.position.x = w


func _target_y(m: int) -> float:
	match m:
		Mode.OPEN:
			return WORLD_HEIGHT - HEIGHT
		Mode.TAB:
			return WORLD_HEIGHT
	return WORLD_HEIGHT + ACTIVE_ZONE


func set_mode(m: int) -> void:
	if m == mode:
		return
	mode = m
	if _tween != null:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(panel, "position:y", _target_y(m), SPEED)


func is_open() -> bool:
	return mode == Mode.OPEN


# Width of the "Inventory" tab including the chamfer, used to open the
# inventory when the cursor is over it.
func tab_width() -> float:
	return $panel/chamfer.position.x + $panel/chamfer.size.x


# Top of the bar when open, in viewport coordinates
func open_top() -> float:
	return WORLD_HEIGHT - HEIGHT


func get_button(item_id: String) -> Control:
	for c in container.get_children():
		if c is ESCInventoryButton and c.global_id == item_id:
			return c
	return null


func set_item_active(item_id: String, active: bool) -> void:
	var b := get_button(item_id)
	if b == null:
		return
	b.pivot_offset = b.size / 2
	var s := ITEM_ACTIVE_SCALE / ITEM_SCALE if active else 1.0
	b.scale = Vector2(s, s)


# Kept for callers of the old UI
func show_inventory() -> void:
	set_mode(Mode.OPEN)


func hide_inventory() -> void:
	set_mode(Mode.TAB)
