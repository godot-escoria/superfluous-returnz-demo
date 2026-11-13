# Bureau (Sosage data/objects/clef_usb.yaml), English texts from locale.yaml

:look | TK
	turn_to("sophie", "usb_key")
	say("sophie", "It must contain something important for Harpagon to keep it in a safe.")

:take
	action("sophie", 0.5)
	inventory_add("usb_key")
	set_active("usb_key", false)
	usb_taken = true

:use | TK
	say("sophie", "I have to plug it in somewhere first.")

:combine "cotton_swab" | TK
	turn_to("sophie", "usb_key")
	say("sophie", "The USB stick is already clean.")
