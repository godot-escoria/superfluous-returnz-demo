# Bureau (Sosage data/objects/ordinateur_bureau.yaml), English texts from locale.yaml

:look
	if usb_plugged:
		if !usb_seen:
			say("sophie", "These are the plans for Superfluous HQ that Harpagon is working on right now.")
			usb_seen = true
		show_window("plan_qg")
	else:
		say("sophie", "Harpagon's session is open, but I don't see anything of interest.")

:move
	say("sophie", "I don't see anything interesting to do there.")

:combine "usb_key"
	action("sophie", 0.2)
	if usb_tries == 0:
		usb_tries = 1
		hint_usb = true
		say("sophie", "Damn, wrong way.")
	elif usb_tries == 1:
		usb_tries = 2
		say("sophie", "Damn, wrong way AGAIN!")
	else:
		inventory_remove("usb_key")
		usb_plugged = true
		hint_usb = false
		say("sophie", "Alright, I plugged the key in the right direction. There's just a PDF on it.")

:combine "cotton_swab" | TK
	turn_to("sophie", "computer")
	say("sophie", "There is no Q-tip port on this computer.")

:combine "small_key" | TK
	turn_to("sophie", "computer")
	say("sophie", "There is no lock on the computer.")

:combine "poker" | TK
	turn_to("sophie", "computer")
	say("sophie", "A revolutionary hacking technique? No.")

:combine "bottle" | TK
	turn_to("sophie", "computer")
	say("sophie", "Tripping the computer, of course, a good idea...")
