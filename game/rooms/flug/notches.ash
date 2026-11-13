# Flu-G (Sosage data/objects/encoches.yaml), English texts from locale.yaml

:look | TK
	turn_to("sophie", "notches")
	say("sophie", "A lever is missing.")

:move | TK
	turn_to("sophie", "notches")
	say("sophie", "I should pull the levers, not the notches.")

:combine "phone" | TK
	turn_to("sophie", "notches")
	say("sophie", "That won't make a good lever.")

:combine "usb_key" | TK
	turn_to("sophie", "notches")
	say("sophie", "Too small for a lever.")

:combine "cotton_swab" | TK
	turn_to("sophie", "notches")
	say("sophie", "It's too small and too soft. Ahem.")

:combine "bottle" | TK
	turn_to("sophie", "notches")
	say("sophie", "It will never fit.")

:combine "poker"
	action("sophie", 0.2)
	wait(0.1)
	inventory_remove("poker")
	set_active("notches", false)
	set_state("poker_placed", "right", true)
	set_active("poker_placed", true)
	poker_placed = true
	poker_right = true
	hint_missing_lever = false
	hint_lever_way = true
