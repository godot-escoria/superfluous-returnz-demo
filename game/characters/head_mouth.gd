extends Sprite2D

var direction: int
var from_frame: int = 0
var head_displacements: Array[Vector2]
var mouth_frames: Array[int]
var initial_head_pos: Vector2
var steps_sound_enabled: bool
var frame_counter: int = 0

var _play_snd: PlaySndCommand = PlaySndCommand.new()

@onready var head = $head
@onready var mouth = $head/mouth

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timer.timeout.connect(self.change_frame)
	randomize()

func generate_random_anim():
	for i in range(50):
		var head_displacement: Vector2 = Vector2(0,0)
		if randi() % 3 == 0:
			var radius: float = 3.5
			var direction: float = randf_range(0.0, 2*PI);
			var length: float = randf_range(radius / 2.0, radius);
			head_displacement = Vector2(length * cos(direction), length * sin(direction))
		head_displacements.push_back(head_displacement)
		mouth_frames.push_back(randi_range(from_frame, from_frame + hframes - 1))

	
func change_frame() -> void:
	head.position = head.position + head_displacements[frame_counter]
	mouth.frame = mouth_frames[frame_counter]
	frame_counter += 1
	$Timer.start()


func _on_sophie_started_talking(dir: int) -> void:
	direction = dir
	initial_head_pos = head.position
	
	if direction > 0: # right
		from_frame = 1
	else:
		from_frame = mouth.hframes + 1
	generate_random_anim()
	$Timer.start()


func _on_sophie_stopped_talking() -> void:
	head.position = initial_head_pos
	mouth.frame = from_frame - 1
	frame_counter = 0
	$Timer.stop()

func _on_sophie_started_walking() -> void:
	steps_sound_enabled = true

func _on_sophie_stopped_walking() -> void:
	steps_sound_enabled = false

func _on_walk_frame_changed() -> void:
	if $"../walk".frame_coords.x == 1 \
			or $"../walk".frame_coords.x == 5:
		_play_snd.run(["res://game/sounds/effects/pas1.ogg", "_sound", 0.0])
