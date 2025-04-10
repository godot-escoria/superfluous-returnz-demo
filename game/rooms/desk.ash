:setup
	if ESC_LAST_SCENE == "garage":
		teleport("player", "garage_exit")
		# Set player look left
		set_angle("player", 270)

	
	global plant_moved = false


:ready
	play_snd("res://game/sounds/musics/02_sophie_mene_lenquete.ogg", _music)
	
	if plant_moved:
		force_event_flag("plant", "use", "TK")

	global intro_done = true
	if !intro_done:
		accept_input("NONE")
		walk_block($sophie, "intro_start_point")
		say("sophie", "If I know Harpagon...")
		say("sophie", "... he's in his brand-new headquarters...")
		say("sophie", "... question is...")
		say("sophie", "... where is his new headquarters?")
		accept_input("ALL")
