# Bureau (Sosage data/objects/bouteille.yaml), English texts from locale.yaml

:look | TK
	say("sophie", "I can never get him to use a gourd... Harpagon loves his disposable plastic!")

:move | TK
	turn_to("sophie", "bottle")
	say("sophie", "And spill it on the keyboard? No thanks.")

:take
	action("sophie", 0.5)
	inventory_add("bottle")
	set_active("bottle", false)
	bottle_taken = true

:use | TK
	say("sophie", "I'm not thirsty.")

:combine "ashes" | TK
	say("sophie", "To make a slop?")
