# Flu-G (Sosage data/objects/levier2.yaml), English texts from locale.yaml

:look | TK
	turn_to("sophie", "lever2")
	say("sophie", "It's a lever. It moves from left to right and vice versa.")

:move | TK<levers_done>
	if levers_done:
		turn_to("sophie", "lever2")
		say("sophie", "The levers are well oriented, no need to move them.")
	else:
		action("sophie", 0.2)
		wait(0.1)
		if lever2_right:
			set_state("lever2", "left")
			lever2_right = false
		else:
			set_state("lever2", "right")
			lever2_right = true
		# nb_leviers reaches 5: 11010 top to bottom (right, right, left, right,
		# left), the poker being the third lever
		if poker_placed and lever1_right and lever2_right and !poker_right and lever3_right and !lever4_right:
			levers_done = true
			hint_lever_way = false
			if computer_state == "on" and bulb_placed and levers_done:
				hint_flug_ok = true
			set_state("suit_lamp", "on")
			play_snd("res://game/sounds/effects/ding.ogg")
