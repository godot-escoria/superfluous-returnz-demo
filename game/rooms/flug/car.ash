# Flu-G (Sosage data/objects/flumobile.yaml), English texts from locale.yaml

:look | TK
	turn_to("sophie", "car")
	say("sophie", "That's a Twingo... well, that's the “Fluousmobile”, it seems.")

:move
	if car_state == "locked":
		action("sophie", 0.5)
		# activer_indice_clef_flumobile
		if !car_keys_taken:
			hint_car_keys = true
		say("sophie", "It's locked.")
	elif car_state == "closed":
		action("sophie", 0.7)
		wait(0.4)
		play_snd("res://game/sounds/effects/coffre.ogg")
		wait(0.3)
		set_state("car", "open")
		car_state = "open"
		set_active("bulb", !bulb_taken)
	else:
		action("sophie", 0.7)
		wait(0.4)
		play_snd("res://game/sounds/effects/coffre.ogg")
		wait(0.3)
		set_state("car", "closed")
		car_state = "closed"
		set_active("bulb", false)

:take | TK
	turn_to("sophie", "car")
	say("sophie", "I'm not leaving without Harpagon!")

:combine "cotton_swab" | TK
	turn_to("sophie", "car")
	say("sophie", "A key would be better.")

:combine "poker" | TK
	turn_to("sophie", "car")
	say("sophie", "I'm not going to break into the boss's car...")

:combine "bottle" | TK
	turn_to("sophie", "car")
	say("sophie", "It's clean enough as it is.")

:combine "car_keys" | TK
	turn_to("sophie", "car")
	action("sophie", 0.5)
	if car_state == "locked":
		wait(0.25)
		play_snd("res://game/sounds/effects/deverrouillage_voiture.ogg")
		wait(0.25)
		set_state("car", "closed")
		car_state = "closed"
		say("sophie", "Alright, it's unlocked.")
	elif car_state == "closed":
		wait(0.25)
		play_snd("res://game/sounds/effects/deverrouillage_voiture.ogg")
		wait(0.25)
		set_state("car", "locked")
		car_state = "locked"
		say("sophie", "I locked it back.")
	else:
		say("sophie", "It doesn't work, I have to close the trunk first.")
