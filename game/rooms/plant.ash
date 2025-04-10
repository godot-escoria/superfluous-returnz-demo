
:use
	if (!plant_moved):
		set_state($plant, "move_left")
		plant_moved = true
		force_event_flag("plant", "use", "TK")
	else:
		turn_to("sophie", "plant")
		say("sophie", "I'm not going to spend my time moving it...")
