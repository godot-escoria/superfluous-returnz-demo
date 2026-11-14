# Flu-G (Sosage data/objects/porte.yaml), English texts from locale.yaml

:look | TK
	face("sophie", "door")
	say("sophie", "It's a door. Fascinating...")

:move
	action("sophie", 0.2)
	if flug_door_open:
		play_snd("res://game/sounds/effects/fermeture_porte.ogg")
		set_state("door", "closed")
		set_active("hallway", false)
		set_active("car_keys", !car_keys_taken)
		flug_door_open = false
	else:
		play_snd("res://game/sounds/effects/ouverture_porte.ogg")
		set_state("door", "open")
		set_active("hallway", true)
		set_active("car_keys", false)
		flug_door_open = true
