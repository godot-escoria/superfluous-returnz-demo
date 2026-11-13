# Flu-G (Sosage data/rooms/flug.yaml)

:setup
	# Puzzle state (declared once; `global` doesn't reset existing values)
	global flug_door_open = true
	global car_keys_taken = false
	global car_state = "locked"
	global bulb_taken = false
	global bulb_placed = false
	global computer_state = "error"
	global lever1_right = true
	global lever2_right = true
	global lever3_right = false
	global lever4_right = true
	global poker_placed = false
	global poker_right = true
	global levers_done = false
	global suit_exploded = false
	global superflu_free = false
	global hanging_talk_done = false
	global end_said_a = false
	global end_said_b = false
	global end_said_c = false
	global end_said_d = false
	global end_said_e = false
	global end_said_g = false
	global flug_visited = false
	# Hint Hotline topics (Sosage emit/receive "indice_*")
	global hint_painting = false
	global hint_ashes = false
	global hint_safe = false
	global hint_usb = false
	global hint_qtip = false
	global hint_bust = false
	global hint_computer = false
	global hint_car_keys = false
	global hint_socket = false
	global hint_missing_lever = false
	global hint_lever_way = false
	global hint_flug_ok = false
	global hint_cable = false

	# entree_porte: Sophie comes in looking right
	set_angle("sophie", 90)

	# Rebuild the room from the puzzle state
	if flug_door_open:
		set_state("door", "open", true)
	else:
		set_state("door", "closed", true)
	set_active("hallway", flug_door_open)
	set_active("car_keys", !flug_door_open and !car_keys_taken)
	set_state("car", car_state, true)
	set_active("bulb", car_state == "open" and !bulb_taken)
	set_state("computer", computer_state, true)
	set_active("socket", !bulb_placed)
	if lever1_right:
		set_state("lever1", "right", true)
	else:
		set_state("lever1", "left", true)
	if lever2_right:
		set_state("lever2", "right", true)
	else:
		set_state("lever2", "left", true)
	if lever3_right:
		set_state("lever3", "right", true)
	else:
		set_state("lever3", "left", true)
	if lever4_right:
		set_state("lever4", "right", true)
	else:
		set_state("lever4", "left", true)
	set_active("notches", !poker_placed)
	set_active("poker_placed", poker_placed)
	if poker_right:
		set_state("poker_placed", "right", true)
	else:
		set_state("poker_placed", "left", true)
	if suit_exploded:
		set_state("suit_lamp", "broken", true)
	elif levers_done:
		set_state("suit_lamp", "on", true)
	else:
		set_state("suit_lamp", "off", true)
	if superflu_free:
		set_state("suit_door", "open", true)
	else:
		set_state("suit_door", "closed", true)
	set_active("cable", suit_exploded)
	# Superflu is only seen once he falls out of the Suit-o-Matic. Escoria saves
	# "active" (= visible), so use it rather than show_item.
	set_active("superflu", superflu_free)
	set_active("superflu_target", suit_exploded and !superflu_free)


:ready
	# entree_porte "first_time": emit indice_ordinateur_flug, indice_douille,
	# indice_manque_levier
	if !flug_visited:
		flug_visited = true
		hint_computer = true
		hint_socket = true
		hint_missing_lever = true
	if suit_exploded:
		play_snd("res://game/sounds/musics/04_flug_phase_2.ogg", _music)
		anim("anim_superflu_hanging", "play")
	else:
		play_snd("res://game/sounds/musics/03_flug_phase_1.ogg", _music)
		# The Suit-o-Matic's button blinks (entree_porte: play bouton_costumomatic)
		anim("anim_button", "play")

