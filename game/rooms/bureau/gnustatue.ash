# Bureau (Sosage data/objects/buste_gnu.yaml), English texts from locale.yaml

:look | TK
	turn_to("sophie", "gnustatue")
	say("sophie", "Gonzague von Gnu, “fluctuat nec privatur”, undoubtedly a celebrity.")

:move
	action("sophie", 0.4)
	say("sophie", "It is glued to the fireplace.")

:combine "cotton_swab"
	if bust_done:
		say("sophie", "I got what I wanted, I'm going to leave it alone now.")
	else:
		hint_qtip = false
		hint_bust = true
		show_code("gnu_bust", "bust_code_ok")
		if bust_code_ok:
			bust_done = true
			hint_bust = false
			wait(0.2)
			say("sophie", "Here, a small key just fell out of the nostril!")
			action("sophie", 0.2)
			inventory_add("small_key")

:combine "poker" | TK
	turn_to("sophie", "gnustatue")
	say("sophie", "I should avoid damaging the works of art...")
