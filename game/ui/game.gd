extends ESCGame

# Mouse interface copied from Sosage (Superfluous Returnz):
# - hovering an object shows its name next to a 4-dots cursor;
# - clicking it opens a selector: Pick up (left), Look (right), Move (up),
#   Inventory (down, then choose an item to use on the object);
# - exits are clicked directly (arrow cursor);
# - the inventory slides up when the cursor reaches the bottom of the screen
#   or the "Inventory" tab; clicking an item offers Combine / Look / Use.
#
# Escoria verbs used by the scripts: look, take, move, use, and "combine" for
# item-on-something (":combine other_id" on either side).
#
# Per-object verb labels (Sosage's "label:" overrides, e.g. Sophie's
# Move = "Talk") go in the item's metadata "verb_labels", e.g.
# {"move": "Talk", "take": "Hug"}.

const InventoryUI = preload("res://game/ui/inventory/inventory_ui.gd")

const VERB_WALK = "walk"
const VERB_COMBINE = "combine"

# Default labels (Sosage init.yaml "default:" section, English locale)
const DEFAULT_LABELS = {
	"look": "Look",
	"move": "Move",
	"take": "Pick up",
	"inventory": "Inventory",
	"use": "Use",
	"combine": "Combine with",
}

enum State { IDLE, ACTION_CHOICE, OBJECT_CHOICE, INVENTORY_ACTION_CHOICE }

var _state: int = State.IDLE

# Object the selector was opened on, and the click that opened it
var _choice_target: String = ""
var _choice_event: InputEvent = null

# Inventory item picked with "Combine with", waiting for a target
var _source_item: String = ""

# Sprite currently highlighted under the cursor
var _highlighted: CanvasItem = null

var _highlight_material: ShaderMaterial = null

@onready var sosage: SosageInterface = $sosage
@onready var inventory_ui: InventoryUI = $ui/inventory_ui


func _ready():
	hide_ui()
	sosage.choice_made.connect(_on_choice_made)
	var shader := Shader.new()
	# Sosage highlight: white overlay at 50 % of the sprite alpha
	shader.code = "shader_type canvas_item;\n" \
		+ "void fragment() { vec4 c = texture(TEXTURE, UV) * COLOR;\n" \
		+ "COLOR = vec4(mix(c.rgb, vec3(1.0), 0.5), c.a); }"
	_highlight_material = ShaderMaterial.new()
	_highlight_material.shader = shader


func _enter_tree():
	initialize_esc_game()

	var room_selector_parent = $ui/HBoxContainer/VBoxContainer

	if ESCProjectSettingsManager.get_setting(ESCProjectSettingsManager.ENABLE_ROOM_SELECTOR) \
		and room_selector_parent.get_node_or_null("room_select") == null:

		room_selector_parent.add_child(
			preload(
				"res://addons/escoria-core/ui_library/tools/room_select" +\
				"/room_select.tscn"
			).instantiate()
		)


func _process(_delta: float) -> void:
	_update_inventory_mode()


# Sosage Control::idle_mouse() / inventory_mouse()
func _update_inventory_mode() -> void:
	if not $ui/inventory_ui.visible:
		return
	var interactive = escoria.inputs_manager.input_mode \
			!= escoria.inputs_manager.INPUT_NONE \
			and escoria.current_state == escoria.GameState.DEFAULT
	if not interactive:
		if _state == State.IDLE:
			inventory_ui.set_mode(InventoryUI.Mode.HIDDEN)
		return

	var p := sosage.mouse_position()
	match _state:
		State.IDLE:
			var bottom := p.y > SosageInterface.WORLD.y - InventoryUI.ACTIVE_ZONE / 5 \
				or (p.y > SosageInterface.WORLD.y - InventoryUI.ACTIVE_ZONE \
					and p.x < inventory_ui.tab_width())
			if inventory_ui.is_open():
				if p.y < inventory_ui.open_top():
					inventory_ui.set_mode(InventoryUI.Mode.TAB)
			elif bottom:
				inventory_ui.set_mode(InventoryUI.Mode.OPEN)
			else:
				inventory_ui.set_mode(InventoryUI.Mode.TAB)
		State.OBJECT_CHOICE, State.INVENTORY_ACTION_CHOICE:
			inventory_ui.set_mode(InventoryUI.Mode.OPEN)
		State.ACTION_CHOICE:
			inventory_ui.set_mode(InventoryUI.Mode.TAB)


## BACKGROUND ##

func left_click_on_bg(position: Vector2) -> void:
	if _state == State.OBJECT_CHOICE:
		_back_to_idle()
		return
	if _source_item != "":
		_clear_source()
		return
	if escoria.main.current_scene.player:
		escoria.action_manager.clear_current_action()
		escoria.action_manager.do(
			escoria.action_manager.ACTION.BACKGROUND_CLICK,
			[escoria.main.current_scene.player.global_id, position],
			true
		)


func right_click_on_bg(_position: Vector2) -> void:
	pass


func left_double_click_on_bg(position: Vector2) -> void:
	if _source_item != "" or _state != State.IDLE:
		return
	if escoria.main.current_scene.player:
		escoria.action_manager.clear_current_action()
		escoria.action_manager.do(
			escoria.action_manager.ACTION.BACKGROUND_CLICK,
			[escoria.main.current_scene.player.global_id, position, true],
			true
		)


## ITEM/HOTSPOT FOCUS ##

func element_focused(element_id: String) -> void:
	if _state != State.IDLE:
		return
	var obj = escoria.object_manager.get_object(element_id)
	if obj == null or not obj.node is ESCItem:
		return
	var item: ESCItem = obj.node
	_set_highlight(item)
	if item.is_exit and _source_item == "":
		var dir := _exit_direction(item)
		sosage.set_cursor(dir)
		sosage.show_cursor_label(tr(item.tooltip_name), dir)
	else:
		if _source_item == "":
			sosage.set_cursor("object")
		sosage.show_cursor_label(tr(item.tooltip_name), "object")


func element_unfocused() -> void:
	_set_highlight(null)
	if _state == State.IDLE:
		sosage.clear_label()
		if _source_item == "":
			sosage.set_cursor("default")


## ITEMS ##

func left_click_on_item(item_global_id: String, event: InputEvent) -> void:
	if _state == State.OBJECT_CHOICE:
		_back_to_idle()
		return
	if _state != State.IDLE:
		return
	var obj = escoria.object_manager.get_object(item_global_id)
	if obj == null:
		return
	var item = obj.node

	if _source_item != "":
		var source := _source_item
		_clear_source()
		_combine(source, item_global_id, event)
		return

	if item is ESCItem and item.is_exit:
		escoria.action_manager.clear_current_action()
		escoria.action_manager.do(
			escoria.action_manager.ACTION.ITEM_LEFT_CLICK,
			[item_global_id, event],
			true
		)
		return

	_choice_target = item_global_id
	_choice_event = event
	_state = State.ACTION_CHOICE
	_set_highlight(null)
	sosage.set_cursor("default")
	sosage.open_selector(sosage.mouse_position(), [
		["take", _verb_label(item, "take"), "left"],
		["look", _verb_label(item, "look"), "right"],
		["move", _verb_label(item, "move"), "up"],
		["inventory", _verb_label(item, "inventory"), "down"],
	])


func right_click_on_item(_item_global_id: String, _event: InputEvent) -> void:
	pass


func left_double_click_on_item(item_global_id: String, event: InputEvent) -> void:
	left_click_on_item(item_global_id, event)


## INVENTORY ##

func left_click_on_inventory_item(inventory_item_global_id: String, event: InputEvent) -> void:
	var id := inventory_item_global_id
	if _state == State.OBJECT_CHOICE:
		var target := _choice_target
		var target_event := _choice_event
		_back_to_idle()
		_combine(id, target, target_event)
		return
	if _state != State.IDLE:
		return
	if _source_item != "":
		if _source_item == id:
			return
		var source := _source_item
		_clear_source()
		_combine(source, id, event)
		return

	var button: Control = inventory_ui.get_button(id)
	var item = escoria.object_manager.get_object(id).node
	_choice_target = id
	_choice_event = event
	_state = State.INVENTORY_ACTION_CHOICE
	sosage.clear_label()
	# Interface::set_action_selector(INV_ACTION_SEL)
	var point := Vector2(
		button.get_global_rect().get_center().x if button else sosage.mouse_position().x,
		inventory_ui.open_top() - 0.75 * SosageLabel.HEIGHT
	)
	sosage.open_selector(point, [
		["combine", _verb_label(item, "combine"), "left"],
		["look", _verb_label(item, "look"), "right"],
		["use", _verb_label(item, "use"), "up"],
	])


func right_click_on_inventory_item(_inventory_item_global_id: String, _event: InputEvent) -> void:
	pass


func left_double_click_on_inventory_item(_inventory_item_global_id: String, _event: InputEvent) -> void:
	pass


func inventory_item_focused(inventory_item_global_id: String) -> void:
	if _state != State.IDLE and _state != State.OBJECT_CHOICE:
		return
	if inventory_item_global_id == _source_item:
		return
	var item: ESCItem = escoria.object_manager.get_object(inventory_item_global_id).node
	inventory_ui.set_item_active(inventory_item_global_id, true)
	var button: Control = inventory_ui.get_button(inventory_item_global_id)
	if button:
		# Interface::create_object_label(), inventory case
		var center := Vector2(
			button.get_global_rect().get_center().x,
			inventory_ui.open_top() - 2 * InventoryUI.LABEL_MARGIN
		)
		sosage.show_fixed_label(tr(item.tooltip_name), center)


func inventory_item_unfocused() -> void:
	for id in escoria.inventory_manager.items_in_inventory():
		inventory_ui.set_item_active(id, false)
	if _state == State.IDLE or _state == State.OBJECT_CHOICE:
		sosage.clear_label()


func open_inventory():
	inventory_ui.set_mode(InventoryUI.Mode.OPEN)


func close_inventory():
	inventory_ui.set_mode(InventoryUI.Mode.TAB)


func mousewheel_action(_direction: int):
	pass


## SELECTOR ##

func _on_choice_made(choice: String) -> void:
	var target := _choice_target
	var event := _choice_event
	var was_inventory := _state == State.INVENTORY_ACTION_CHOICE
	_state = State.IDLE
	_choice_target = ""
	_choice_event = null

	match choice:
		"":
			pass
		"inventory":
			# Choose an item to use on the target (Sosage OBJECT_CHOICE)
			_state = State.OBJECT_CHOICE
			_choice_target = target
			_choice_event = event
		"combine":
			_source_item = target
			var item = escoria.object_manager.get_object(target).node
			sosage.set_cursor("selected", _inventory_texture(item))
			inventory_ui.set_mode(InventoryUI.Mode.TAB)
		_:
			escoria.logger.info(self, "Sosage UI: '%s' on '%s'." % [choice, target])
			if not await _wait_for_default_state():
				return
			escoria.action_manager.clear_current_action()
			escoria.action_manager.set_current_action(choice)
			escoria.action_manager.do(
				escoria.action_manager.ACTION.ITEM_LEFT_CLICK,
				[target, event],
				true
			)
			if was_inventory:
				inventory_ui.set_mode(InventoryUI.Mode.TAB)


# Use `tool_id` (an inventory item) with `target_id`: the ESC event is
# ":combine target_id" on the tool, or ":combine tool_id" on the target.
func _combine(tool_id: String, target_id: String, event: InputEvent) -> void:
	var am = escoria.action_manager
	var tool = escoria.object_manager.get_object(tool_id)
	if tool == null or not escoria.object_manager.has(target_id):
		return
	if not VERB_COMBINE in tool.node.actions_requiring_target_object:
		tool.node.actions_requiring_target_object.append(VERB_COMBINE)
	escoria.logger.info(self, "Sosage UI: combine '%s' with '%s'." % [tool_id, target_id])
	if not await _wait_for_default_state():
		return
	am.clear_current_action()
	am.set_current_action(VERB_COMBINE)
	am.current_tool = tool
	am.set_action_input_state(am.ActionInputState.AWAITING_TARGET_ITEM)
	am.do(am.ACTION.ITEM_LEFT_CLICK, [target_id, event], true)
	inventory_ui.set_mode(InventoryUI.Mode.TAB)


# Escoria silently ignores actions requested while it is not in its DEFAULT
# state (e.g. while a line is still being said), so wait for it.
func _wait_for_default_state(timeout: float = 15.0) -> bool:
	var waited := 0.0
	while escoria.current_state != escoria.GameState.DEFAULT:
		await get_tree().process_frame
		waited += get_process_delta_time()
		if waited > timeout:
			escoria.logger.warn(self, "Sosage UI: action dropped, Escoria stayed busy.")
			return false
	return true


func _back_to_idle() -> void:
	_state = State.IDLE
	_choice_target = ""
	_choice_event = null
	sosage.close_selector()
	sosage.clear_label()


func _clear_source() -> void:
	_source_item = ""
	sosage.set_cursor("default")


## HELPERS ##

# Sosage "label:" overrides. Metadata "verb_labels" = {verb: label};
# "verb_labels_by_state" = {state: {verb: label}} wins for the current state.
func _verb_label(item: Node, verb: String) -> String:
	if item == null:
		return tr(DEFAULT_LABELS[verb])
	var labels: Dictionary = item.get_meta("verb_labels", {})
	var by_state: Dictionary = item.get_meta("verb_labels_by_state", {})
	if not by_state.is_empty() and "global_id" in item \
			and escoria.object_manager.has(item.global_id):
		var state: String = escoria.object_manager.get_object(item.global_id).state
		if by_state.has(state) and by_state[state].has(verb):
			return tr(by_state[state][verb])
	return tr(labels.get(verb, DEFAULT_LABELS[verb]))


# "goto_left" / "goto_right": metadata "goto" ("left"/"right") wins, then the
# old "_l_"/"_r_" naming, then the side of the screen the exit is on.
func _exit_direction(item: ESCItem) -> String:
	if item.has_meta("goto"):
		return "goto_right" if item.get_meta("goto") == "right" else "goto_left"
	if item.global_id.contains("_r_"):
		return "goto_right"
	if item.global_id.contains("_l_"):
		return "goto_left"
	var x: float = item.get_global_transform_with_canvas().origin.x
	return "goto_right" if x > SosageInterface.WORLD.x / 2 else "goto_left"


func _inventory_texture(item) -> Texture2D:
	if item is ESCItem and item.inventory_texture:
		return item.inventory_texture
	if item is TextureButton:
		return item.texture_normal
	return null


func _set_highlight(item) -> void:
	if is_instance_valid(_highlighted):
		_highlighted.material = null
	_highlighted = null
	if item == null:
		return
	for c in item.get_children():
		if c is Sprite2D and c.texture != null and c.visible:
			c.material = _highlight_material
			_highlighted = c
			return


func hide_ui():
	$ui/inventory_ui.visible = false
	$ui/HBoxContainer/VBoxContainer.visible = false
	sosage.clear_label()
	sosage.close_selector()


func show_ui():
	$ui/inventory_ui.visible = true
	$ui/HBoxContainer/VBoxContainer.visible = true


func hide_main_menu():
	show_ui()
	if get_node(main_menu).visible:
		get_node(main_menu).hide()

func show_main_menu():
	hide_ui()
	if not get_node(main_menu).visible:
		get_node(main_menu).reset()
		get_node(main_menu).show()

# The pause menu is Sophie's phone, shown over the game (Sosage "Exit" menu)
func unpause_game():
	if get_node(pause_menu).visible:
		get_node(pause_menu).hide()
		escoria.object_manager.get_object(ESCObjectManager.SPEECH).node.resume()
		show_ui()
		escoria.set_game_paused(false)

func pause_game():
	if not get_node(pause_menu).visible:
		hide_ui()
		_back_to_idle()
		_clear_source()
		get_node(pause_menu).reset()
		get_node(pause_menu).show()
		escoria.object_manager.get_object(ESCObjectManager.SPEECH).node.pause()
		escoria.set_game_paused(true)


func apply_custom_settings(custom_settings: Dictionary):
	if custom_settings.has("a_custom_setting"):
		escoria.logger.info(
			self,
			"custom setting value loaded: %s."
					% str(custom_settings["a_custom_setting"])
		)


func get_custom_data() -> Dictionary:
	return {
		"ui_type": "simplemouse"
	}


func _on_action_finished():
	pass


func _on_event_done(_return_code: int, _event_name: String):
	if _return_code == ESCExecution.RC_OK:
		escoria.action_manager.clear_current_action()
