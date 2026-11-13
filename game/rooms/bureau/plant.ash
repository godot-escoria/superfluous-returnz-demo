# Bureau (Sosage data/objects/plante.yaml), English texts from locale.yaml

:look | TK
	turn_to("sophie", "plant")
	say("sophie", "It's a yucca... it's pretty and it doesn't require too much care.")

:move | TK<plant_moved>
	if !plant_moved:
		action("sophie", 0.4)
		wait(0.2)
		set_state("plant", "move_left")
		set_active("keyhole", true)
		plant_moved = true
	else:
		turn_to("sophie", "plant")
		say("sophie", "I'm not going to spend my time moving it...")

:combine "bottle"
	action("sophie", 1)
	say("sophie", "There, the plant is watered.")
