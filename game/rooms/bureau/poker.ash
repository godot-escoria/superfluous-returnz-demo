# Bureau (Sosage data/objects/tisonnier.yaml), English texts from locale.yaml

:look | TK
	say("sophie", "It's used to stir the ashes... I guess it could be a good lever.")

:take
	action("sophie", 0.5)
	inventory_add("poker")
	set_active("poker", false)
	poker_taken = true
	inventory_add("ashes")
	say("sophie", "Yuck, I have a lot of ashes on my hand.")

:use | TK
	say("sophie", "It's covered in ashes, it's a waste of time.")

:combine "ashes" | TK
	say("sophie", "The poker is already covered in ashes.")
