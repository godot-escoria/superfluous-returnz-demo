# Bureau (Sosage data/objects/coffre_fort.yaml), English texts from locale.yaml

:look | TK
	turn_to("sophie", "safe")
	say("sophie", "I guess Harpagon only stores important items there.")

:move
	if safe_open:
		say("sophie", "To do what?")
	else:
		if safe_ashes:
			show_code("safe", "safe_code_ok", "ashes")
		else:
			show_code("safe", "safe_code_ok")
		if safe_code_ok:
			wait(0.1)
			say("sophie", "1989, his year of birth, of course... so secure!")
			set_state("safe", "open")
			safe_open = true
			hint_ashes = false
			hint_safe = false
			safe_ashes = true
			set_active("usb_key", true)

:combine "bottle" | TK
	turn_to("sophie", "safe")
	say("sophie", "The short circuit will be a last resort.")

:combine "poker" | TK
	turn_to("sophie", "safe")
	say("sophie", "The safe is reinforced, I won't be able to open it like that.")

:combine "cotton_swab" | TK
	turn_to("sophie", "safe")
	say("sophie", "It seems a little too soft to open a safe.")

:combine "ashes"
	action("sophie", 0.2)
	inventory_remove("ashes")
	safe_ashes = true
	hint_ashes = false
	hint_safe = true
	say("sophie", "The ashes stick to the keys!")
