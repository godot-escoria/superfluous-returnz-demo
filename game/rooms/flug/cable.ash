# Flu-G (Sosage data/objects/cable.yaml), English texts from locale.yaml

:look | TK
	turn_to("sophie", "cable")
	say("sophie", "It's a bare wire connected to the Suit-o-Matic.")

:move | TK
	turn_to("sophie", "cable")
	say("sophie", "It's a cable, not a flush.")

:combine "bottle"
	accept_input("NONE")
	turn_to("sophie", "cable")
	wait(0.2)
	say("sophie", "Uhhh...")
	turn_to("sophie", "car")
	wait(0.5)
	turn_to("sophie", "cable")
	wait(0.5)
	turn_to("sophie", "car")
	wait(0.5)
	say("sophie", "Kids...")
	say("sophie", "... don't try this at home.")
	turn_to("sophie", "cable")
	wait(1)
	action("sophie", 0.2)
	show_item("sophie", false)
	play_snd("res://game/sounds/effects/zap.ogg")
	anim_block("anim_sophie_shock", "play")
	anim("anim_superflu_hanging", "stop")
	anim("anim_superflu_stuck", "play")
	show_item("sophie", true)
	set_state("suit_door", "none")
	anim("anim_suit_door", "play")
	wait(0.3)
	shake(10, 0.3)
	stop_snd("_music")
	play_snd("res://game/sounds/effects/costumomatic_porte_claque.ogg")
	wait(0.6)
	set_state("suit_door", "open")
	wait(0.3)
	anim("anim_superflu_stuck", "stop")
	anim("anim_superflu_fall2", "play")
	wait(0.6)
	play_snd("res://game/sounds/effects/chute.ogg")
	wait(3.9)
	play_snd("res://game/sounds/musics/05_theme_dharpagon.ogg", _music)
	set_active("superflu_target", false)
	superflu_free = true
	set_active("superflu", true)
	wait(0.7)
	say("superflu", "Ahem...")
	walk_to_pos_block("superflu", 1588, 946)
	turn_to("sophie", "superflu")
	turn_to("superflu", "sophie")
	say("superflu", "Thanks, Sophie. I owe you a big flavor, as they say.")
	say("sophie", "Do they say that?")
	say("superflu", "What would you say?")
	say("sophie", "Uhhh...")
	say("superflu", "Whatever. Ready for new adventures?")
	accept_input("ALL")
	?!
		- "Do they involve super-teenage super-villains?" [!end_said_a]
			end_said_a = true
			say("sophie", "Do they involve super-teenage super-villains?")
			say("superflu", "I wish I could guarantee you that they don't... I really wish I could...")
			say("sophie", "That's what I feared...")
		- "Will they be totally superfluous?" [!end_said_b]
			end_said_b = true
			say("sophie", "Will they be totally superfluous?")
			say("superflu", "I don't want to brag, but I think it's kind of my trademark.")
		- "Will they be made by a talented artist?" [!end_said_c]
			end_said_c = true
			say("sophie", "Will they be made by a talented artist?")
			say("sophie", "With colorful graphics reminiscent of the comic book “The Adventures of Superfluous” by the same author?")
			say("sophie", "With a blockbuster-like soundtrack?")
			say("sophie", "Using a vintage game engine reminiscent of the golden age of LucasArts?")
			say("sophie", "Sprinkled with a clever mix of devastating humor and twisted puzzles?")
			say("superflu", "That says it in a nutshell.")
			say("superflu", "However, I'd appreciate if you did not break the fourth wall right from the introduction sequence...")
		- "Does my system have the required configuration?" [!end_said_g]
			end_said_g = true
			say("sophie", "Does my system have the required configuration?")
			say("superflu", "Let's see. What is your operating system?")
			?!
				- "MS-DOS, old school cool."
					say("sophie", "MS-DOS, old school cool.")
					break
				- "Windows 3.1, state-of-the-art."
					say("sophie", "Windows 3.1, state-of-the-art.")
					break
				- "An operating system of a down, WAKE UP!"
					say("sophie", "An operating system of a down, WAKE UP!")
					break
				- "I have a Macintosh, is it okay?"
					say("sophie", "I have a Macintosh, is it okay?")
					break
			say("superflu", "Mmh, sure. What's your video display controller?")
			?!
				- "CGA. Purple and cyan, that's dope."
					say("sophie", "CGA. Purple and cyan, that's dope.")
					break
				- "EGA, it's nicer."
					say("sophie", "EGA, it's nicer.")
					break
				- "VGA, it's much nicer."
					say("sophie", "VGA, it's much nicer.")
					break
				- "I've got a blue screen of death, the blue is gorgeous."
					say("sophie", "I've got a blue screen of death, the blue is gorgeous.")
					break
			say("superflu", "Alright... What's your sound card?")
			?!
				- "PC Speaker, I like the beeps."
					say("sophie", "PC Speaker, I like the beeps.")
					break
				- "Sound Blaster, the sound card of monsters."
					say("sophie", "Sound Blaster, the sound card of monsters.")
					break
				- "Sound Blaster Pro, the same but for giant monsters."
					say("sophie", "Sound Blaster Pro, the same but for giant monsters.")
					break
				- "AdLib, when in doubt, this one always works."
					say("sophie", "AdLib, when in doubt, this one always works.")
					break
				- "I have an iTunes gift card, is it compatible?"
					say("sophie", "I have an iTunes gift card, is it compatible?")
					break
			say("superflu", "Very well. Look, it's a bit light, but it should be okay.")
			say("superflu", "So, ready for the adventure?")
		- "Do I get a risk premium?" [!end_said_d]
			end_said_d = true
			say("sophie", "Do I get a risk premium?")
			say("superflu", "I thought you were doing this job out of passion, you break my heart.")
			say("sophie", "Oh I'm ultra-passionate.")
			say("sophie", "However, I do have rent to pay.")
			say("superflu", "Of course, if you don't make any effort...")
			say("superflu", "I, for one, am offering you fabulous adventures! Worth all the bonuses.")
		- "When do we eat?" [!end_said_e]
			end_said_e = true
			say("sophie", "When do we eat?")
			say("superflu", "When we're hungry, silly billy.")
			say("sophie", "Silly billy?")
			say("superflu", "Sorry, I got carried away.")
			say("superflu", "Apart from that, ready for the adventure?")
		- "I'm ready. Let's go!"
			say("sophie", "I'm ready. Let's go!")
			say("superflu", "Let's go.")
			done
	# flug.yaml "fin": they leave in the Fluousmobile
	accept_input("NONE")
	walk_to_pos("sophie", 1971, 842)
	walk_to_pos("superflu", 2747, 987)
	transition("fade_black", "out", 2.5)
	stop_snd("_music")
	show_end_text("Well done! You have completed\nthis demo of Superfluous\nReturnz! Thanks for playing\nand see you soon for new\nadventures!")
	accept_input("ALL")
	show_menu("main")
