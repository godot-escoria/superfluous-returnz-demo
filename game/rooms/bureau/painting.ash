# Bureau (Sosage data/objects/tableau.yaml), English texts from locale.yaml

:look | TK
	face("sophie", "painting")
	say("sophie", "Contemporary art. Some people like this...")

:move
	action("sophie", 0.2)
	play_snd("res://game/sounds/effects/ouverture_tableau.ogg")
	set_active("painting", false)
	set_active("safe", true)
	painting_moved = true
	hint_painting = false
	hint_ashes = true
	say("sophie", "The safe behind the painting, classic!")

:combine "bottle" | TK
	face("sophie", "painting")
	say("sophie", "I don't want to damage it.")

:combine "poker" | TK
	face("sophie", "painting")
	say("sophie", "The painting doesn't seem attached, I can probably move it without the poker.")

:combine "ashes" | TK
	face("sophie", "painting")
	say("sophie", "Let's avoid spoiling the artwork of the boss.")
