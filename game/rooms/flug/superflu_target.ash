# Flu-G (Sosage data/objects/superflu_target.yaml), English texts from locale.yaml

:look | TK
	turn_to("sophie", "superflu_target")
	say("sophie", "He's Harpagon Lonion, aka Superfluous, my boss...")

:move | TK
	turn_to("sophie", "superflu_target")
	?!
		- "How did you manage to get stuck like that?"
			say("sophie", "How did you manage to get stuck like that?")
			say("superflu", "I just wanted to test the Suit-o-Matic!")
			say("superflu", "The cape got stuck in the mechanism, please try to open!")
		- "The Suit-o-Matic door is locked!"
			say("sophie", "The Suit-o-Matic door is locked!")
			say("superflu", "It's an electronic opening!")
			?!
				- "The problem is, your computer just blew up..."
					say("sophie", "The problem is, your computer just blew up...")
					say("superflu", "Gosh!")
					say("sophie", "You don't say.")
					say("superflu", "And can't you fiddle with something?")
				- "My electronics skills are limited."
					say("sophie", "My electronics skills are limited.")
					say("superflu", "Try something! Anything!")
					say("superflu", "Bypass that damn junk!")
				- "I'll see what I can do, don't move."
					say("sophie", "I'll see what I can do, don't move.")
					say("superflu", "Where the hell do you want me to go?!")
					done
		- "What if I hadn't found the Fluouscave?"
			say("sophie", "What if I hadn't found the Fluouscave?")
			say("sophie", "You would have been stuck there...")
			say("sophie", "... and be found two weeks later, because of the smell...")
			say("sophie", "... perhaps half-eaten by bats...")
			say("sophie", "... did you think about that?")
			say("superflu", "As a matter of fact, I did not, but thanks for putting this image in my head...")
		- "I'll get you out of there! Don't move."
			say("sophie", "I'll get you out of there! Don't move.")
			say("superflu", "Where the hell do you want me to go?!")
			done

:take | TK
	turn_to("sophie", "superflu_target")
	say("sophie", "No.")
