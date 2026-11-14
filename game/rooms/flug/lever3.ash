# Flu-G (Sosage data/objects/levier3.yaml), English texts from locale.yaml

:look | TK
	face("sophie", "lever3")
	say("sophie", "It's a lever. It moves from left to right and vice versa.")

:move | TK<levers_done>
	if levers_done:
		face("sophie", "lever3")
		say("sophie", "The levers are well oriented, no need to move them.")
	else:
		action("sophie", 0.2)
		wait(0.1)
		if lever3_right:
			set_state("lever3", "left")
			lever3_right = false
		else:
			set_state("lever3", "right")
			lever3_right = true
		# nb_leviers reaches 5: 11010 top to bottom (right, right, left, right,
		# left), the poker being the third lever
		if poker_placed and lever1_right and lever2_right and !poker_right and lever3_right and !lever4_right:
			levers_done = true
			hint_lever_way = false
			if computer_state == "on" and bulb_placed and levers_done:
				hint_flug_ok = true
			set_state("suit_lamp", "on")
			play_snd("res://game/sounds/effects/ding.ogg")
