extends Control

@onready var cursors: Dictionary = {
	"walk": {
		"filename": "res://components/sr-ui-simplemouse/cursors/cursor.png",
		"hotspot": Vector2(0,0)
	},
	"action": {
		"filename": "res://components/sr-ui-simplemouse/cursors/cursor_object.png",
		"hotspot": Vector2(0,0)
	},
	"exit_left": {
		"filename": "res://components/sr-ui-simplemouse/cursors/gauche_aller.png",
		"hotspot": Vector2(0,0)
	},
	"exit_right": {
		"filename": "res://components/sr-ui-simplemouse/cursors/droite_aller.png",
		"hotspot": Vector2(0,0)
	}
}
var resized_cursors: Dictionary
@onready var action_manually_changed = false


func _ready():
	if !Engine.is_editor_hint():
		get_tree().root.size_changed.connect(_on_window_size_changed)
		_on_window_size_changed()
		set_by_name("walk")
		set_process(false)

func _process(delta):
	$mouse_position.global_position = get_global_mouse_position()


func set_by_name(name: String, force_verb: String = "") -> void:
	if name.is_empty():
		return
	#Input.set_custom_mouse_cursor(
	#	cursors[current_cursor_id].texture,
	#	Input.CURSOR_ARROW,
	#	Vector2(0,0)
	#)
	Input.set_custom_mouse_cursor(resized_cursors[name], Input.CURSOR_ARROW, cursors[name].hotspot)
	
	if force_verb.is_empty():
		escoria.action_manager.set_current_action(name)
	else:
		escoria.action_manager.set_current_action(force_verb)

func set_tool_texture(texture: Texture2D):
	set_process(true)
	$mouse_position/tool.texture = texture

func clear_tool_texture():
	$mouse_position/tool.texture = null
	set_process(false)

func _on_window_size_changed():
	#find out how much you need to scale the image by dividing the current window size by the defualt window size
	var wy = DisplayServer.window_get_size().y
	var vpy = ESCProjectSettingsManager.get_setting("display/window/size/viewport_height")
	var scale_size: float = float(wy)/float(vpy)
	
	for action in cursors.keys():
		var file_name = cursors[action].filename
		if file_name.get_extension() == "png":
			var texture: CompressedTexture2D = load(file_name)
			var image = texture.get_image()
			image.resize(image.get_size().x * scale_size, image.get_size().y * scale_size, Image.INTERPOLATE_NEAREST) #Resize to fit window size
			resized_cursors[action] = image
