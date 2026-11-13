# Flu-G (Sosage data/objects/bouton_rouge.yaml), English texts from locale.yaml

:look | TK
	turn_to("sophie", "red_button")
	say("sophie", "You just want to press it...")

:move | TK<suit_exploded>
	if suit_exploded:
		turn_to("sophie", "red_button")
		say("sophie", "The computer is broken, it's no longer useful.")
	elif computer_state != "on":
		action("sophie", 0.4)
		wait(0.1)
		play_snd("res://game/sounds/effects/bip2.ogg")
		say("sophie", "Nothing happens, the computer is crashed.")
	else:
		action("sophie", 0.4)
		wait(0.1)
		play_snd("res://game/sounds/effects/bip2.ogg")
		wait(0.2)
		anim("anim_flash1", "play")
		play_snd("res://game/sounds/effects/zap.ogg")
		# activer_lumieres
		wait(0.75)
		if !bulb_placed:
			say("sophie", "Looks like a light bulb is missing.")
		else:
			anim("anim_flash2", "play")
			play_snd("res://game/sounds/effects/zap.ogg")
			wait(0.5)
			anim("anim_flash3", "play")
			play_snd("res://game/sounds/effects/zap.ogg")
			if !levers_done:
				say("sophie", "It's working, but the Suit-o-Matic is off.")
			else:
				# activer_costumomatic "active": the Suit-o-Matic blows up
				accept_input("NONE")
				wait(0.57)
				anim("anim_flash4", "play")
				play_snd("res://game/sounds/effects/zap.ogg")
				wait(0.6)
				stop_snd("_music")
				shake(20, 1)
				anim("anim_flash5", "play")
				play_snd("res://game/sounds/effects/costumomatic_crash.ogg")
				wait(1.7)
				play_snd("res://game/sounds/musics/04_flug_phase_2.ogg", _music)
				shake(10, 1)
				play_snd("res://game/sounds/effects/baboum.ogg")
				anim("anim_boum1", "play")
				play_snd("res://game/sounds/effects/boum.ogg")
				set_state("computer", "broken")
				computer_state = "broken"
				wait(0.2)
				anim("anim_boum2", "play")
				set_state("suit_lamp", "broken")
				wait(0.3)
				anim("anim_button", "stop")
				anim_block("anim_cable", "play")
				set_active("cable", true)
				anim_block("anim_superflu_fall1", "play")
				suit_exploded = true
				hint_flug_ok = false
				hint_cable = true
				set_active("superflu_target", true)
				anim("anim_superflu_hanging", "play")
				say("superflu", "AAaaaahhhh!")
				say("sophie", "Mr. Lonion?")
				walk_block("sophie", "superflu_target")
				turn_to("sophie", "superflu_target")
				say("superflu", "Sophie?")
				say("sophie", "What on Earth are you doing upside down?")
				say("superflu", "I'm doing bench press...")
				say("superflu", "OF COURSE NOT! What do you reckon? I'm stuck!")
				say("superflu", "Get me out of here!")
				accept_input("ALL")
