# Bureau (Sosage data/objects/corbeille.yaml), English texts from locale.yaml

:look | TK
	face("sophie", "trashbin")
	say("sophie", "It's a small office trash can, Harpagon will throw absolutely anything in it.")

:move | TK
	face("sophie", "trashbin")
	say("sophie", "I don't want to overthrow it.")

:take
	if trash_searched:
		say("sophie", "There is nothing left in it.")
	else:
		say("sophie", "There is just a Q-tip inside.")
		crouch("sophie", true)
		wait(0.2)
		say("sophie", "Alright, it looks clean, I'll take it.")
		action("sophie", 0.2)
		wait(0.2)
		crouch("sophie", false)
		inventory_add("cotton_swab")
		trash_searched = true

:combine "phone" | TK
	face("sophie", "trashbin")
	say("sophie", "I'm not gonna throw away my phone!")

:combine "usb_key" | TK
	face("sophie", "trashbin")
	say("sophie", "I'm not going to throw it away...")

:combine "cotton_swab" | TK
	face("sophie", "trashbin")
	say("sophie", "I'm gonna keep it for now.")

:combine "ashes" | TK
	face("sophie", "trashbin")
	say("sophie", "I'm gonna keep them, just in case.")

:combine "poker" | TK
	face("sophie", "trashbin")
	say("sophie", "I need it.")

:combine "small_key" | TK
	face("sophie", "trashbin")
	say("sophie", "I'm not going to throw it away...")

:combine "bottle" | TK
	face("sophie", "trashbin")
	say("sophie", "It is not airtight, it would make a mess...")
