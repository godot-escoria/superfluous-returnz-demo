# Bureau (Sosage data/objects/petite_serrure.yaml), English texts from locale.yaml

:look | TK
	face("sophie", "keyhole")
	say("sophie", "It's a very small lock that was hidden behind the plant.")

:move | TK
	face("sophie", "keyhole")
	if lock_open:
		say("sophie", "It's already unlocked.")
	else:
		say("sophie", "With what?")

:combine "bottle" | TK
	face("sophie", "keyhole")
	say("sophie", "A key would be better.")

:combine "phone" | TK
	face("sophie", "keyhole")
	say("sophie", "It's a little too big.")

:combine "cotton_swab" | TK
	face("sophie", "keyhole")
	say("sophie", "Lock picking with a Q-tip is not really efficient.")

:combine "usb_key" | TK
	face("sophie", "keyhole")
	say("sophie", "This is a wrong type of key...")

:combine "poker" | TK
	face("sophie", "keyhole")
	if lock_open:
		say("sophie", "It's already unlocked.")
	else:
		say("sophie", "The lock is much too small to be hooked like this.")

:combine "small_key"
	action("sophie", 0.4)
	inventory_remove("small_key")
	face("sophie", "secret_passage")
	wait(0.2)
	set_active("secret_passage", true)
	play_snd("res://game/sounds/effects/passage_secret.ogg")
	set_state("secret_passage", "open")
	lock_open = true
	wait(1)
