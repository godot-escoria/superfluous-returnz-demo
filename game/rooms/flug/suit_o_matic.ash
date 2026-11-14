# Flu-G (Sosage data/objects/costumomatic.yaml), English texts from locale.yaml

:look | TK
	face("sophie", "suit_o_matic")
	say("sophie", "The famous “Suit-o-Matic”... yet another bizarre invention from Harpagon!")

:move
	action("sophie", 0.5)
	say("sophie", "It's locked. It looks like an electronic opening.")

:combine "poker" | TK
	face("sophie", "suit_o_matic")
	say("sophie", "This is an armored door, I will never be able to open it like that.")

:combine "car_keys" | TK
	face("sophie", "suit_o_matic")
	say("sophie", "It's rather a car key, isn't it?")
