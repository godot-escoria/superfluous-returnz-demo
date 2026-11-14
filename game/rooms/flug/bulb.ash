# Flu-G (Sosage data/objects/ampoule.yaml), English texts from locale.yaml

:look | TK
	face("sophie", "bulb")
	say("sophie", "It's a new bulb.")

:take
	action("sophie", 0.5)
	inventory_add("bulb")
	set_active("bulb", false)
	bulb_taken = true

:use | TK
	say("sophie", "I don't want to cut my fingers!")
