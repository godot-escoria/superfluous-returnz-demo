## Sosage's random idle (src/Sosage/System/Animation.cpp,
## generate_random_idle_body_animation / generate_random_idle_head_animation).
## While the character's AnimationPlayer plays idle_left or idle_right:
## - the body stands in its "default" pose or one of its "idle" poses (the
##   skin's idle positions; Sophie: hands in pockets, arms crossed, hands on
##   hips) for 50 to 500 frames, going from one to the next through the
##   "transition" frame (2 frames);
## - the head blinks every 5 to 50 frames and, every 30 to 300 frames, one
##   time in four takes another expression (any column of the head sheet but
##   the closed eyes).
## Frames are Sosage's: 12 per second. The idle animations (an hour long, so
## they don't start over) set the default pose and expression when they
## start; then this node sets body:frame and body/head:frame.
## A child of the character, next to body/ and AnimationPlayer.
extends Node

const FPS := 12.0
const TRANSITION := 0     # column of the "transition" body frame
const DEFAULT_POSE := 1   # column of the "default" body pose
const CLOSED_EYES := 0    # column of the blinking head

## Columns of the body sheet to stand in: "default" and the "idle" ones
@export var body_poses: PackedInt32Array = PackedInt32Array([1, 2, 3, 4])

@onready var _player: AnimationPlayer = get_parent().get_node("AnimationPlayer")
@onready var _body: Sprite2D = get_parent().get_node("body")
@onready var _head: Sprite2D = get_parent().get_node("body/head")

var _anim := ""
var _row := 0
var _body_pose := DEFAULT_POSE
var _body_left := 0.0
var _in_transition := false
var _head_pose := 1
var _head_left := 0.0
var _blink_left := 0.0
var _blinking := false


func _process(delta: float) -> void:
	var anim: String = ""
	if _player.is_playing():
		anim = _player.current_animation
	if anim != "idle_left" and anim != "idle_right":
		_anim = ""
		return
	if anim != _anim:
		_start(anim)
	_tick_body(delta)
	_tick_head(delta)


# Sosage random_int(a, b): a <= n < b frames, in seconds
func _frames(n_min: int, n_max: int) -> float:
	return randi_range(n_min, n_max - 1) / FPS


# A new idle (Sosage generates one each time the character stops): the
# default pose and expression
func _start(anim: String) -> void:
	_anim = anim
	_row = 1 if anim == "idle_left" else 0
	_body_pose = DEFAULT_POSE
	_in_transition = false
	_body_left = _frames(50, 500)
	_head_pose = 1
	_head_left = _frames(30, 300)
	_blinking = false
	_blink_left = _frames(5, 50)
	_show()


func _tick_body(delta: float) -> void:
	_body_left -= delta
	if _body_left > 0.0:
		return
	if _in_transition:
		_in_transition = false
		_body_left = _frames(50, 500)
	else:
		_in_transition = true
		_body_left = 2.0 / FPS
		var next := _body_pose
		while next == _body_pose and body_poses.size() > 1:
			next = body_poses[randi_range(0, body_poses.size() - 1)]
		_body_pose = next
	_show()


func _tick_head(delta: float) -> void:
	if _blinking:
		_blink_left -= delta
		if _blink_left <= 0.0:
			_blinking = false
			_blink_left = _frames(5, 50)
			_show()
		return
	_blink_left -= delta
	_head_left -= delta
	if _head_left <= 0.0:
		# end of a while with this expression: another one, one time in four
		if randi_range(0, 3) == 0 and _head.hframes > 2:
			var next := _head_pose
			while next == _head_pose:
				next = randi_range(1, _head.hframes - 1)
			_head_pose = next
		_head_left = _frames(30, 300)
		_blink_left = _frames(5, 50)
		_show()
	elif _blink_left <= 0.0:
		_blinking = true
		_blink_left = 1.0 / FPS
		_show()


func _show() -> void:
	var body_col := TRANSITION if _in_transition else _body_pose
	_body.frame = _row * _body.hframes + body_col
	var head_col := CLOSED_EYES if _blinking else _head_pose
	_head.frame = _row * _head.hframes + head_col
