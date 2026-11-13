# Bureau (Sosage data/rooms/bureau.yaml)

:setup
	# Coming back from the Flu-G (bureau.yaml entree_passage_secret)
	if ESC_LAST_SCENE == "room_flug":
		teleport("sophie", "from_flug")
		set_angle("sophie", 270)

	# Puzzle state (declared once; `global` doesn't reset existing values)
	global painting_moved = false
	global safe_ashes = false
	global safe_code_ok = false
	global safe_open = false
	global usb_taken = false
	global usb_tries = 0
	global usb_plugged = false
	global usb_seen = false
	global trash_searched = false
	global bust_code_ok = false
	global bust_done = false
	global plant_moved = false
	global lock_open = false
	global bottle_taken = false
	global poker_taken = false
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

	# Rebuild the room from the puzzle state
	set_active("painting", !painting_moved)
	set_active("safe", painting_moved)
	if safe_open:
		set_state("safe", "open", true)
	set_active("usb_key", safe_open and !usb_taken)
	set_active("bottle", !bottle_taken)
	set_active("poker", !poker_taken)
	set_active("keyhole", plant_moved)
	if plant_moved:
		set_state("plant", "move_left", true)
	set_active("secret_passage", lock_open)
	if lock_open:
		set_state("secret_passage", "opened", true)


:ready
	play_snd("res://game/sounds/musics/02_sophie_mene_lenquete.ogg", _music)

	if !intro_done:
		inventory_add("phone")
		# entree_debut: emit indice_tableau, indice_coton_tige
		hint_painting = true
		hint_qtip = true
		accept_input("NONE")
		walk_block($sophie, "intro_start_point")
		say("sophie", "If I know Harpagon...")
		say("sophie", "... he's in his brand-new headquarters...")
		say("sophie", "... question is...")
		say("sophie", "... where is his new headquarters?")
		accept_input("ALL")
		intro_done = true
