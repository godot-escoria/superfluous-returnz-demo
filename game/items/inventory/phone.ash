# Telephone (Sosage data/objects/telephone.yaml), English texts from locale.yaml

:look | TK
	say("sophie", "It's for making calls, taking pictures or accessing the menu.")

:use | TK
	# telephone.yaml: use -> trigger "Exit" (the phone menu)
	open_phone()

:combine "usb_key" | TK
	say("sophie", "The phone's USB port is too small.")

:combine "poker" | TK
	say("sophie", "I'm not going to break my phone open...")

:combine "ashes" | TK
	say("sophie", "I'd rather keep it clean.")

:combine "bottle" | TK
	say("sophie", "And blow it? No thanks.")


# Phone book: data/actions/numero_indices.yaml (state "prelude") and
# dialogs/hints_prelude.yaml. The hint_* globals stand for Sosage's
# emit/receive "indice_*" signals.
:call_hints | TK
	# play: ["telephone", -1]: the phone stays at her ear for the whole call,
	# also while she talks
	set_animations("sophie", "res://game/characters/sophie_phone_animations.tres")
	action("sophie", 0, "idle")
	say("hinter", "Hint hotline, what can I do for your service?")
	?!
		- "I'm not sure where to start..." [hint_painting]
			say("sophie", "I'm not sure where to start...")
			say("hinter", "Maybe you should take a look at this lovely painting.")
			?!
				- "I need a bigger hint."
					say("sophie", "I need a bigger hint.")
					say("hinter", "You should try the available actions possible with the painting.")
					?!
						- "I really can't find... what is the solution?"
							say("sophie", "I really can't find... what is the solution?")
							say("hinter", "Move the painting.")
							done
						- "Thanks, that's enough for me!"
							say("sophie", "Thanks, that's enough for me!")
							say("hinter", "Good luck then!")
							done
				- "Thanks, that's enough for me!"
					say("sophie", "Thanks, that's enough for me!")
					say("hinter", "Good luck then!")
					done
		- "I can't find the code for the safe." [hint_ashes]
			say("sophie", "I can't find the code for the safe.")
			say("hinter", "The used keys are probably greasy, try to reveal them with something that sticks.")
			?!
				- "I need a bigger hint."
					say("sophie", "I need a bigger hint.")
					say("hinter", "You have to use some kind of powder.")
					?!
						- "I really can't find... what is the solution?"
							say("sophie", "I really can't find... what is the solution?")
							say("hinter", "Use the ashes on the chest.")
							done
						- "Thanks, that's enough for me!"
							say("sophie", "Thanks, that's enough for me!")
							say("hinter", "Good luck then!")
							done
				- "Thanks, that's enough for me!"
					say("sophie", "Thanks, that's enough for me!")
					say("hinter", "Good luck then!")
					done
		- "Even with the ash, I STILL can't find the code for the safe." [hint_safe]
			say("sophie", "Even with the ash, I STILL can't find the code for the safe.")
			say("hinter", "It's probably something easy to remember for Harpagon.")
			?!
				- "I need a bigger hint."
					say("sophie", "I need a bigger hint.")
					say("hinter", "Look on the documents, you may find something personal about Harpagon.")
					?!
						- "I really can't find... what is the solution?"
							say("sophie", "I really can't find... what is the solution?")
							say("hinter", "The code is Harpagon's year of birth, 1989.")
							done
						- "Thanks, that's enough for me!"
							say("sophie", "Thanks, that's enough for me!")
							say("hinter", "Good luck then!")
							done
				- "Thanks, that's enough for me!"
					say("sophie", "Thanks, that's enough for me!")
					say("hinter", "Good luck then!")
					done
		- "I cannot put the USB stick in the computer." [hint_usb]
			say("sophie", "I cannot put the USB stick in the computer.")
			say("hinter", "Putting a USB stick in the right direction often requires several tries. Try again!")
			?!
				- "I need a bigger hint."
					say("sophie", "I need a bigger hint.")
					say("hinter", "Wrong way once, wronge way twice...")
					?!
						- "I really can't find... what is the solution?"
							say("sophie", "I really can't find... what is the solution?")
							say("hinter", "Insert the USB stick three times in a row, third time's a charm.")
							done
						- "Thanks, that's enough for me!"
							say("sophie", "Thanks, that's enough for me!")
							say("hinter", "Good luck then!")
							done
				- "Thanks, that's enough for me!"
					say("sophie", "Thanks, that's enough for me!")
					say("hinter", "Good luck then!")
					done
		- "What should I do with the gnu bust?" [hint_qtip]
			say("sophie", "What should I do with the gnu bust?")
			say("hinter", "Find an object to insert into his large nostrils.")
			?!
				- "I need a bigger hint."
					say("sophie", "I need a bigger hint.")
					say("hinter", "You need a small elongated object.")
					?!
						- "I really can't find... what is the solution?"
							say("sophie", "I really can't find... what is the solution?")
							say("hinter", "Use the Q-tip from the basket with the bust.")
							done
						- "Thanks, that's enough for me!"
							say("sophie", "Thanks, that's enough for me!")
							say("hinter", "Good luck then!")
							done
				- "Thanks, that's enough for me!"
					say("sophie", "Thanks, that's enough for me!")
					say("hinter", "Good luck then!")
					done
		- "How should I use the gnu bust?" [hint_bust]
			say("sophie", "How should I use the gnu bust?")
			say("hinter", "A technical document should give numbers to the ears and nostrils.")
			?!
				- "I need a bigger hint."
					say("sophie", "I need a bigger hint.")
					say("hinter", "Take a good look at the face drawn on the blueprint of the Fluouscave, there are numbers.")
					?!
						- "I really can't find... what is the solution?"
							say("sophie", "I really can't find... what is the solution?")
							say("hinter", "Press the left ear, the right ear, then the left nostril twice.")
							done
						- "Thanks, that's enough for me!"
							say("sophie", "Thanks, that's enough for me!")
							say("hinter", "Good luck then!")
							done
				- "Thanks, that's enough for me!"
					say("sophie", "Thanks, that's enough for me!")
					say("hinter", "Good luck then!")
					done
		- "The computer is crashed." [hint_computer]
			say("sophie", "The computer is crashed.")
			say("hinter", "Generally, what is the basic manipulation to fix this?")
			?!
				- "I need a bigger hint."
					say("sophie", "I need a bigger hint.")
					say("hinter", "When in doubt, reboot?")
					?!
						- "I really can't find... what is the solution?"
							say("sophie", "I really can't find... what is the solution?")
							say("hinter", "Have you turning it off and on again?")
							done
						- "Thanks, that's enough for me!"
							say("sophie", "Thanks, that's enough for me!")
							say("hinter", "Good luck then!")
							done
				- "Thanks, that's enough for me!"
					say("sophie", "Thanks, that's enough for me!")
					say("hinter", "Good luck then!")
					done
		- "I can't find the car keys." [hint_car_keys]
			say("sophie", "I can't find the car keys.")
			say("hinter", "They're probably hanging somewhere, behind something.")
			?!
				- "I need a bigger hint."
					say("sophie", "I need a bigger hint.")
					say("hinter", "Some objects can hide things, try to move, open or close something.")
					?!
						- "I really can't find... what is the solution?"
							say("sophie", "I really can't find... what is the solution?")
							say("hinter", "Close the door, the keys are hanging behind.")
							done
						- "Thanks, that's enough for me!"
							say("sophie", "Thanks, that's enough for me!")
							say("hinter", "Good luck then!")
							done
				- "Thanks, that's enough for me!"
					say("sophie", "Thanks, that's enough for me!")
					say("hinter", "Good luck then!")
					done
		- "What should I do with the control board behind the computer?" [hint_socket]
			say("sophie", "What should I do with the control board behind the computer?")
			say("hinter", "A bulb is missing, try to find a new one.")
			?!
				- "I need a bigger hint."
					say("sophie", "I need a bigger hint.")
					say("hinter", "In which large object can you also find light bulbs?")
					?!
						- "I really can't find... what is the solution?"
							say("sophie", "I really can't find... what is the solution?")
							say("hinter", "There is a light bulb in the trunk of the car.")
							done
						- "Thanks, that's enough for me!"
							say("sophie", "Thanks, that's enough for me!")
							say("hinter", "Good luck then!")
							done
				- "Thanks, that's enough for me!"
					say("sophie", "Thanks, that's enough for me!")
					say("hinter", "Good luck then!")
					done
		- "A lever is missing." [hint_missing_lever]
			say("sophie", "A lever is missing.")
			say("hinter", "You can probably replace it with something similar.")
			?!
				- "I need a bigger hint."
					say("sophie", "I need a bigger hint.")
					say("hinter", "You have to insert a long metal object.")
					?!
						- "I really can't find... what is the solution?"
							say("sophie", "I really can't find... what is the solution?")
							say("hinter", "Insert the poker into the notch.")
							done
						- "Thanks, that's enough for me!"
							say("sophie", "Thanks, that's enough for me!")
							say("hinter", "Good luck then!")
							done
				- "Thanks, that's enough for me!"
					say("sophie", "Thanks, that's enough for me!")
					say("hinter", "Good luck then!")
					done
		- "Which way should I put the levers?" [hint_lever_way]
			say("sophie", "Which way should I put the levers?")
			say("hinter", "The positions are probably on a technical document. Something with 5 items?")
			?!
				- "I need a bigger hint."
					say("sophie", "I need a bigger hint.")
					say("hinter", "There are numbers at the top left of the Fluouscave blueprint.")
					?!
						- "I really can't find... what is the solution?"
							say("sophie", "I really can't find... what is the solution?")
							say("hinter", "The numbers 11010 match the positions, from top to bottom: right, right, left, right, left.")
							done
						- "Thanks, that's enough for me!"
							say("sophie", "Thanks, that's enough for me!")
							say("hinter", "Good luck then!")
							done
				- "Thanks, that's enough for me!"
					say("sophie", "Thanks, that's enough for me!")
					say("hinter", "Good luck then!")
					done
		- "I do not know what to do." [hint_flug_ok]
			say("sophie", "I do not know what to do.")
			say("hinter", "Everything looks good, you just have to turn it all on!")
			done
		- "How can I open the door?" [hint_cable]
			say("sophie", "How can I open the door?")
			say("hinter", "Try to create a short circuit.")
			?!
				- "I need a bigger hint."
					say("sophie", "I need a bigger hint.")
					say("hinter", "In life, you should avoid putting water in contact with electricity. In a silly video game, on the other hand...")
					?!
						- "I really can't find... what is the solution?"
							say("sophie", "I really can't find... what is the solution?")
							say("hinter", "Use the bottle of water with the cable.")
							done
						- "Thanks, that's enough for me!"
							say("sophie", "Thanks, that's enough for me!")
							say("hinter", "Good luck then!")
							done
				- "Thanks, that's enough for me!"
					say("sophie", "Thanks, that's enough for me!")
					say("hinter", "Good luck then!")
					done
		- "I don't need any hint at the moment."
			say("sophie", "I don't need any hint at the moment.")
			say("hinter", "Good luck then!")
			done
	set_animations("sophie", "res://game/characters/sophie_animations.tres")
	action("sophie", 0, "idle")


# data/actions/numero_harpagon.yaml
:call_harpagon | TK
	if ESC_CURRENT_SCENE == "room_flug" and suit_exploded:
		say("sophie", "I don't need to call Harpagon, I know where he is.")
	else:
		say("sophie", "I'll try to call Harpagon...")
		action("sophie", 3, "phone")
		if ESC_CURRENT_SCENE == "room_flug":
			wait(1)
			say("superflu", "* Ring ring *")
			say("sophie", "Looks like the phone is in the Suit-o-Matic!")
		else:
			say("sophie", "No one answered.")
