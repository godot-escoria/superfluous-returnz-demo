# A Sosage-style label: a rounded black "pill" with white text, or a round
# action button. Geometry follows Sosage's Interface::create_label() and
# Interface::update_label() at interface scale 1 (1920x1080, 80 px fonts
# rendered at 0.5, label_height 50, label_margin 20).
class_name SosageLabel
extends Control


enum Kind {
	PLAIN,         # centered pill (inventory item names, "move"/"inventory" choices)
	CURSOR_LEFT,   # hover label to the right of the cursor (square left side)
	CURSOR_RIGHT,  # hover label to the left of the cursor (square right side)
	GOTO_LEFT,     # exit label to the right of a "go left" arrow
	GOTO_RIGHT,    # exit label to the left of a "go right" arrow
	OPEN_LEFT,     # choice label extending right from its button ("look")
	OPEN_RIGHT,    # choice label extending left from its button ("take")
	BUTTON,        # round 50 px action button
}

const HEIGHT := 50.0
const RADIUS := 25.0
const FONT: Font = preload("res://game/fonts/PTN77F.ttf")
const FONT_SIZE := 40
const LABEL_ALPHA := 100.0 / 255.0

var text: String = ""
var kind: int = Kind.PLAIN
var highlighted: bool = false:
	set(value):
		highlighted = value
		queue_redraw()

# Where the anchor point (cursor, button center...) is, relative to our left edge
var _anchor_x: float = 0.0
var _text_center_x: float = 0.0


static func make(p_text: String, p_kind: int) -> SosageLabel:
	var l := SosageLabel.new()
	l.text = p_text
	l.kind = p_kind
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	l._layout()
	return l


func _layout() -> void:
	var tw := 0.0
	if text != "":
		tw = FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x
	var w := 0.0
	match kind:
		Kind.PLAIN:
			w = tw + 70
			_anchor_x = w / 2
			_text_center_x = w / 2
		Kind.CURSOR_LEFT:
			w = tw + 65
			_anchor_x = 0
			_text_center_x = 37.5 + tw / 2
		Kind.CURSOR_RIGHT:
			w = tw + 65
			_anchor_x = w
			_text_center_x = w - 37.5 - tw / 2
		Kind.GOTO_LEFT:
			w = tw + 45
			_anchor_x = 0
			_text_center_x = 22.5 + tw / 2
		Kind.GOTO_RIGHT:
			w = tw + 45
			_anchor_x = w
			_text_center_x = w - 22.5 - tw / 2
		Kind.OPEN_LEFT:
			w = tw + 90
			_anchor_x = RADIUS
			_text_center_x = 65 + tw / 2
		Kind.OPEN_RIGHT:
			w = tw + 90
			_anchor_x = w - RADIUS
			_text_center_x = w - 65 - tw / 2
		Kind.BUTTON:
			w = HEIGHT
			_anchor_x = RADIUS
			_text_center_x = RADIUS
	size = Vector2(w, HEIGHT)
	pivot_offset = Vector2(_anchor_x, HEIGHT / 2)
	queue_redraw()


# Put the label's anchor point on `point` (viewport coordinates)
func place(point: Vector2) -> void:
	position = point - Vector2(_anchor_x, HEIGHT / 2)


func set_text(p_text: String) -> void:
	text = p_text
	_layout()


func _draw() -> void:
	if kind == Kind.BUTTON:
		# Sosage highlight = white overlay at 50 % of the shape alpha
		var c := Color(0.5, 0.5, 0.5) if highlighted else Color(0, 0, 0)
		draw_circle(Vector2(RADIUS, RADIUS), RADIUS, c)
		return

	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, LABEL_ALPHA)
	sb.anti_aliasing = true
	var left_round := kind not in [Kind.CURSOR_LEFT, Kind.GOTO_LEFT]
	var right_round := kind not in [Kind.CURSOR_RIGHT, Kind.GOTO_RIGHT]
	sb.corner_radius_top_left = int(RADIUS) if left_round else 0
	sb.corner_radius_bottom_left = int(RADIUS) if left_round else 0
	sb.corner_radius_top_right = int(RADIUS) if right_round else 0
	sb.corner_radius_bottom_right = int(RADIUS) if right_round else 0
	draw_style_box(sb, Rect2(Vector2.ZERO, size))

	if text != "":
		var tw := FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x
		var ascent := FONT.get_ascent(FONT_SIZE)
		var descent := FONT.get_descent(FONT_SIZE)
		var baseline := HEIGHT / 2 + (ascent - descent) / 2
		draw_string(FONT, Vector2(_text_center_x - tw / 2, baseline), text,
			HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, Color.WHITE)
