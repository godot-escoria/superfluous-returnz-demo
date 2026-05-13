@tool
extends Control

signal action_chosen(action)

enum Placement {
	NORMAL,
	TOP_OF_SCREEN,
	LEFT_OF_SCREEN,
	BOTTOM_OF_SCREEN,
	RIGHT_OF_SCREEN
}

@export var texture_normal: Texture2D:
	set = set_texture_normal
@export var texture_hover: Texture2D:
	set = set_texture_hover
@export var init_gap: float = 50.0:
	set = set_init_gap

@export var wobble_duration = 4.0
@export var wobble_gap = 20

	
@onready var north = $northbt
@onready var north_container = $north
@onready var north_label = $north/Label

@onready var east = $eastbt
@onready var east_container = $east
@onready var east_label = $east/MarginContainer/Label

@onready var south = $southbt
@onready var south_container = $south
@onready var south_label = $south/Label

@onready var west = $westbt
@onready var west_container = $west
@onready var west_label = $west/MarginContainer/Label


var texture_size: Vector2

@onready var initial_placements = {
	Placement.NORMAL: {
		north: Vector2(-texture_size.x/2, -texture_size.y - init_gap),
		east: Vector2(init_gap, -texture_size.y/2 ), 
		south: Vector2(-texture_size.x/2, init_gap), 
		west: Vector2(-texture_size.x - init_gap, -texture_size.y/2)
	},
	Placement.TOP_OF_SCREEN: {
		north: null,
		east: null, 
		south: null,
		west: null
	},
	Placement.RIGHT_OF_SCREEN: {
		north: null,
		east: null, 
		south: null,
		west: null
	},
	Placement.BOTTOM_OF_SCREEN: {
		north: null,
		east: null, 
		south: null,
		west: null
	},
	Placement.LEFT_OF_SCREEN: {
		north: null,
		east: null, 
		south: null,
		west: null
	}
}
var current_placement: Placement = Placement.NORMAL


# State machine that governs how the dialog manager behaves
#var state_machine = preload("res://components/sr-ui-simplemouse/patterns/state_machine/state_machine.gd").new()
var state = 0

var tween_north: Tween
var tween_east: Tween
var tween_south: Tween
var tween_west: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	north.mouse_entered.connect(_on_mouse_entered.bind(north))
	east.mouse_entered.connect(_on_mouse_entered.bind(east))
	south.mouse_entered.connect(_on_mouse_entered.bind(south))
	west.mouse_entered.connect(_on_mouse_entered.bind(west))
	north.mouse_exited.connect(_on_mouse_exited.bind(north))
	east.mouse_exited.connect(_on_mouse_exited.bind(east))
	south.mouse_exited.connect(_on_mouse_exited.bind(south))
	west.mouse_exited.connect(_on_mouse_exited.bind(west))
	
	north.pressed.connect(_on_button_pressed.bind(north))
	east.pressed.connect(_on_button_pressed.bind(east))
	south.pressed.connect(_on_button_pressed.bind(south))
	west.pressed.connect(_on_button_pressed.bind(west))
	
	north.texture_normal = texture_normal
	east.texture_normal = texture_normal
	south.texture_normal = texture_normal
	west.texture_normal = texture_normal
	north.texture_hover = texture_hover
	east.texture_hover = texture_hover
	south.texture_hover = texture_hover
	west.texture_hover = texture_hover
		
	_reset_positions(current_placement)
	
func spawn(placement: Placement, position: Vector2, verbs: Array[String] = ["", "", "", ""]):
	self.position = position
	north_label.text = verbs[0]
	east_label.text = verbs[1]
	south_label.text = verbs[2]
	west_label.text = verbs[3]
	_reset_positions(placement)
	show()
	$AnimationPlayer.play("show")
	await $AnimationPlayer.animation_finished
	wobble()

func despawn():
	$AnimationPlayer.play_backwards("show")
	await $AnimationPlayer.animation_finished
	if tween_north.is_running():
		tween_north.kill()
	if tween_east.is_running():
		tween_east.kill()
	if tween_south.is_running():
		tween_south.kill()
	if tween_west.is_running():
		tween_west.kill()
	hide()
	
func wobble():
	tween_north = create_tween()
	tween_north.set_loops()
	tween_north.set_ease(Tween.EASE_IN_OUT)
	tween_north.set_trans(Tween.TRANS_SINE)
	tween_north.tween_property(north, "position", Vector2(north.position.x, north.position.y + wobble_gap), wobble_duration)
	tween_north.parallel().tween_property(north_container, "position", Vector2(north_container.position.x, north_container.position.y + wobble_gap), wobble_duration)
	tween_north.tween_property(north, "position", Vector2(north.position.x, north.position.y - wobble_gap), wobble_duration)
	tween_north.parallel().tween_property(north_container, "position", Vector2(north_container.position.x, north_container.position.y - wobble_gap), wobble_duration)

	tween_east = create_tween()
	tween_east.set_loops()
	tween_east.set_ease(Tween.EASE_IN_OUT)
	tween_east.set_trans(Tween.TRANS_SINE)
	tween_east.tween_property(east, "position", Vector2(east.position.x - wobble_gap, east.position.y), wobble_duration)
	tween_east.parallel().tween_property(east_container, "position", Vector2(east_container.position.x - wobble_gap, east_container.position.y), wobble_duration)
	tween_east.tween_property(east, "position", Vector2(east.position.x + wobble_gap, east.position.y), wobble_duration) 
	tween_east.parallel().tween_property(east_container, "position", Vector2(east_container.position.x + wobble_gap, east_container.position.y), wobble_duration) 

	tween_south = create_tween()
	tween_south.set_loops()
	tween_south.set_ease(Tween.EASE_IN_OUT)
	tween_south.set_trans(Tween.TRANS_SINE)
	tween_south.tween_property(south, "position", Vector2(south.position.x, south.position.y - wobble_gap), wobble_duration)
	tween_south.parallel().tween_property(south_container, "position", Vector2(south_container.position.x, south_container.position.y - wobble_gap), wobble_duration)
	tween_south.tween_property(south, "position", Vector2(south.position.x, south.position.y + wobble_gap), wobble_duration) 
	tween_south.parallel().tween_property(south_container, "position", Vector2(south_container.position.x, south_container.position.y + wobble_gap), wobble_duration) 

	tween_west = create_tween()
	tween_west.set_loops()
	tween_west.set_ease(Tween.EASE_IN_OUT)
	tween_west.set_trans(Tween.TRANS_SINE)
	tween_west.tween_property(west, "position", Vector2(west.position.x + wobble_gap, west.position.y), wobble_duration)
	tween_west.parallel().tween_property(west_container, "position", Vector2(west_container.position.x + wobble_gap, west_container.position.y), wobble_duration)
	tween_west.tween_property(west, "position", Vector2(west.position.x - wobble_gap, west.position.y), wobble_duration) 
	tween_west.parallel().tween_property(west_container, "position", Vector2(west_container.position.x - wobble_gap, west_container.position.y), wobble_duration) 

func set_texture_normal(texture: Texture2D):
	texture_normal = texture
	texture_size = texture_normal.get_size()
	
func set_texture_hover(texture: Texture2D):
	texture_hover = texture

func set_init_gap(value: float):
	init_gap = value


func _reset_positions(placement: Placement):
	match placement:
		Placement.NORMAL:
			north.position = initial_placements[placement][north]
			north_container.position = north.position - Vector2(north_container.size.x/2 - north.size.x/2, north.size.y)
			
			east.position = initial_placements[placement][east]
			east_container.position = initial_placements[placement][east]
			
			south.position = initial_placements[placement][south]
			south_container.position = south.position + Vector2(north.size.x/2 - south_container.size.x/2, south.size.y)
			
			west.position = initial_placements[placement][west]
			west_container.position = west.position - Vector2(west_container.size.x - west.size.x, 0)
		_:
			#TODO
			pass

func _on_mouse_entered(button: TextureButton):
	pass
	
func _on_mouse_exited(button: TextureButton):
	pass

func _on_button_pressed(button: TextureButton):
	action_chosen.emit(button.get_node("back/Label"))
	print("clicked " + button.name)
