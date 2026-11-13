# Flu-G (Sosage data/objects/douille.yaml), English texts from locale.yaml

:look | TK
	turn_to("sophie", "socket")
	say("sophie", "A lightbulb is missing here.")

:move | TK
	turn_to("sophie", "socket")
	say("sophie", "I don't want to get a shock.")

:combine "cotton_swab" | TK
	turn_to("sophie", "socket")
	say("sophie", "It would be better to put a light bulb.")

:combine "phone" | TK
	turn_to("sophie", "socket")
	say("sophie", "I should rather put in a light bulb there.")

:combine "poker" | TK
	turn_to("sophie", "socket")
	say("sophie", "A light bulb would be better...")

:combine "bottle" | TK
	turn_to("sophie", "socket")
	say("sophie", "A light bulb would be more appropriate...")

:combine "bulb"
	action("sophie", 0.4)
	wait(0.2)
	inventory_remove("bulb")
	set_active("socket", false)
	bulb_placed = true
	hint_socket = false
	if computer_state == "on" and bulb_placed and levers_done:
		hint_flug_ok = true
