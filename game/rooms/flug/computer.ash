# Flu-G (Sosage data/objects/ordinateur_flug.yaml), English texts from locale.yaml

:look | TK
	turn_to("sophie", "computer")
	if computer_state == "error":
		say("sophie", "System error...")
	elif computer_state == "off":
		say("sophie", "Maybe I should turn it back on.")
	elif computer_state == "on":
		say("sophie", "Everything seems to be working on that side.")
	else:
		say("sophie", "The screen blew up...")

:move | TK<suit_exploded>
	if computer_state == "error":
		action("sophie", 0.2)
		set_state("computer", "off")
		computer_state = "off"
	elif computer_state == "off":
		action("sophie", 0.2)
		set_state("computer", "on")
		computer_state = "on"
		hint_computer = false
		if computer_state == "on" and bulb_placed and levers_done:
			hint_flug_ok = true
		say("sophie", "“Have you tried turning it off and on again?” It always works!")
	elif computer_state == "on":
		turn_to("sophie", "computer")
		say("sophie", "The system looks operational, I have nothing else to do there, the Suit-o-Matic must be controlled elsewhere.")
	else:
		turn_to("sophie", "computer")
		say("sophie", "The screen blew up...")

:combine "usb_key" | TK
	turn_to("sophie", "computer")
	say("sophie", "There is no USB port on this computer.")

:combine "bottle" | TK
	turn_to("sophie", "computer")
	say("sophie", "This computer has enough problems like this...")
