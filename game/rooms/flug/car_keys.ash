# Flu-G (Sosage data/objects/clef_flumobile.yaml), English texts from locale.yaml

:look | TK
	face("sophie", "car_keys")
	say("sophie", "Have you noticed that we say “the keys to the car” even though there's only one of them?")

:take
	action("sophie", 0.5)
	inventory_add("car_keys")
	set_active("car_keys", false)
	car_keys_taken = true
	hint_car_keys = false

:use | TK
	say("sophie", "I should probably point it at the car.")
