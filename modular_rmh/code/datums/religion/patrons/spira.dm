// RMH EDIT: the pantheon of Spira (see the Spira project bible).
// Three tiers: the Primordials (Gaedon, Saelion), the Greater Gods (Sirokel, Naverae, Ragelia)
// and the Lesser Gods (Lunestra). Each god borrows the miracles, boon trait and devotion tasks of the
// Vanderlin god closest to their domain, through devotion_holder.

/datum/patron/spira
	abstract_type = /datum/patron/spira
	name = null
	profane_words = list()
	confess_lines = list()
	/// Dark patrons: bandits and oathbreakers serve them, paladins can't, and they only watch dungeon runs
	/// carrying their own faithful. See is_sinister_patron().
	var/sinister = FALSE

/datum/patron/spira/primordial
	abstract_type = /datum/patron/spira/primordial
	associated_faith = /datum/faith/spira/primordials
	preference_accessible = TRUE

/datum/patron/spira/greater
	abstract_type = /datum/patron/spira/greater
	associated_faith = /datum/faith/spira/greater
	preference_accessible = TRUE

/datum/patron/spira/lesser
	abstract_type = /datum/patron/spira/lesser
	associated_faith = /datum/faith/spira/lesser
	preference_accessible = TRUE

/// Things of the primordial chaos that are worshipped by some, but are not gods of Paradise. Never selectable.
/datum/patron/spira/chaos
	abstract_type = /datum/patron/spira/chaos
	associated_faith = /datum/faith/spira/primordials
	preference_accessible = FALSE
	sinister = TRUE

// ---------------- Primordials ----------------

/datum/patron/spira/primordial/gaedon
	name = "Gaedon"
	display_name = "Gaedon, the Firstborn"
	domain = "Ambition, Perfection and Progress"
	desc = "The primordial god who withstood the chaos and forced a stable world out of it: Paradise. \
	Proud and overbearing, he built the foundations of the world and its first servants, struck down Sirokel \
	for her theft and now lies imprisoned in his own creation. Though every mortal was made by Saelion, Gaedon finds \
	them interesting and full of potential, and grants his favor to the exceptional and to those who strive to improve \
	despite lacking skill or talent. He is shown as chains and golden shackles."
	worshippers = "Nobles, the ambitious, the talented and those who press on against all odds"
	flaws = "Arrogance, Tyranny, Wrath"
	sins = "Pessimism, Complacency, Fearing to advance or improve"
	boons = "When you critically fail an attack or a craft, you roll again."
	added_traits = list(TRAIT_AMBITION)
	devotion_holder = /datum/devotion/divine/malum
	confess_lines = list(
		"GAEDON WAS THE FIRST AND WILL BE THE LAST!",
		"HIS CHAINS HOLD THE WORLD TOGETHER!",
		"AMBITION REWARDS THE BRAVE!",
	)

/datum/patron/spira/primordial/saelion
	name = "Saelion"
	display_name = "Saelion, the Bluish Flame"
	domain = "Life, Light and Creation"
	desc = "A small being born from the chaos with a gift Gaedon never had: the power to create life. \
	Hidden and taught by Sirokel, he received her stolen essence and imprisoned his creator. \
	The faithful of Gaedon call him the usurper; everyone else calls him the patron of all life. \
	He is shown as a bluish flame."
	worshippers = "Most beings of the civilized world of Spira, above all the highest ranks of the Holy Church"
	flaws = "Recklessness, Vengefulness, Careless experiments"
	sins = "Wasting or scorning life, Senseless destruction of nature"
	boons = "Once per round, when you are about to die or bleed out, Saelion pulls you back to your feet."
	added_traits = list(TRAIT_WILL_TO_LIVE)
	devotion_holder = /datum/devotion/divine/dendor
	confess_lines = list(
		"WHAT LIVES, LIVES BY HIS GRACE!",
		"PRAISED BE THE BLUE FLAME, FOR ITS WARMTH GAVE US LIFE!",
		"HIS FLAME BURNS WITHIN EVERY HEART!",
	)

// ---------------- Greater Gods ----------------

/datum/patron/spira/greater/sirokel
	name = "Sirokel"
	display_name = "Sirokel, the Blue Star"
	domain = "Justice, the Stars and the Martyrs"
	desc = "The first servant of Gaedon, who made the stars with him. Behind her creator's back she stole the \
	primordial essence to give it to Saelion, and in his rage Gaedon tried to kill her, running her through the back \
	with a sword. Her blood is the font of all mortal magic. She is shown as a woman pierced by a sword, or as a blue star."
	worshippers = "The pious, the protectors and the just"
	flaws = "Defiance, Recklessness, Trusting too deeply"
	sins = "Cruelty, Abandoning the weak, Hoarding gifts that should be shared"
	boons = "At night, under the open sky, her blue star now and then shines for you, lifting your mood and easing your fatigue."
	added_traits = list(TRAIT_BLUE_STAR)
	devotion_holder = /datum/devotion/divine/astrata
	confess_lines = list(
		"SIROKEL SHIELDS THE JUST!",
		"HER BLOOD IS OUR MAGIC, HER MERCY OUR SHIELD!",
		"BY THE BLUE STAR, I WILL NOT YIELD!",
	)

/datum/patron/spira/greater/naverae
	name = "Naverae"
	display_name = "Naverae, the Silent Namer"
	domain = "Knowledge, Names, Wizards and Scholars"
	desc = "Born to help organize, Naverae named all things alongside Gaedon. He stood by his sister and \
	had his throat cut so he would never speak again of what he knew. Since then knowledge is preserved \
	in books, the only way he could share it. His followers wear a red bandage around the neck."
	worshippers = "Wizards, scholars, scribes and librarians"
	flaws = "Secrecy, Stubbornness, Bitterness"
	sins = "Burning books, Silencing truth, Hoarding knowledge"
	boons = "You learn, dream, and teach apprentices slightly better. Access to roles with magic."
	added_traits = list(TRAIT_TUTELAGE)
	devotion_holder = /datum/devotion/divine/noc
	confess_lines = list(
		"WHAT IS WRITTEN CANNOT BE SILENCED!",
		"NAVERAE KNOWS THE NAME OF ALL THINGS!",
		"THE RED BANDAGE BINDS MY TONGUE, NOT MY MIND!",
	)

/datum/patron/spira/greater/ragelia
	name = "Ragelia"
	display_name = "Ragelia, the Spear of Paradise"
	domain = "Warriors, Vigilance and Loyalty"
	desc = "Born to help Gaedon defend Paradise from the demons, and ever faithful to her creator. \
	She stood at his side in the war against Saelion and was allowed to live on to continue her duty. \
	She keeps constant watch over the defense of the world, and is shown by the symbol of her severed hand, \
	a sign of unconditional loyalty."
	worshippers = "Warriors, guards and watchmen"
	flaws = "Blind obedience, Harshness, Rigidity"
	sins = "Cowardice, Desertion, Doubt"
	boons = "You see more clearly in the dark, and rough terrain does not slow you down."
	added_traits = list(TRAIT_ALWAYS_VIGILANT)
	devotion_holder = /datum/devotion/divine/ravox
	confess_lines = list(
		"RAGELIA STANDS GUARD, AND SO DO I!",
		"KEEP FIGHTING, NO MATTER THE ODDS!",
		"LOYALTY UNTO THE END!",
	)

// ---------------- Lesser Gods ----------------

/datum/patron/spira/lesser/lunestra
	name = "Lunestra"
	display_name = "Lunestra, the Keeper of the Hourglass"
	domain = "Death, Rest and Souls"
	desc = "Not so much a goddess of death as its manager: a servant who took the lead in gathering souls and \
	bringing them to rest. She talks with the newly dead for a while, flipping an hourglass. If you are not \
	brought back before the sand runs out, it is time for your final rest."
	worshippers = "Gravetenders, mourners, undertakers and those who fear nothing"
	flaws = "Indifference, Bureaucracy, Impatience"
	sins = "Defiling the dead, Unnatural undeath, Cheating the hourglass"
	boons = "You may see the presence of a soul in a body."
	added_traits = list(TRAIT_SOUL_EXAMINE)
	devotion_holder = /datum/devotion/divine/necra
	confess_lines = list(
		"THE SAND RUNS FOR ALL OF US!",
		"LUNESTRA KEEPS THE LEDGER OF SOULS!",
		"WHEN THE HOURGLASS EMPTIES, I WILL REST!",
	)

/// Is this patron (instance or typepath) one of the dark gods?
/proc/is_sinister_patron(datum/patron/patron)
	if(!patron)
		return FALSE
	if(ispath(patron))
		if(ispath(patron, /datum/patron/inhumen))
			return TRUE
		if(ispath(patron, /datum/patron/spira))
			var/datum/patron/spira/spira_path = patron
			return initial(spira_path.sinister)
		return FALSE
	if(istype(patron, /datum/patron/inhumen))
		return TRUE
	if(istype(patron, /datum/patron/spira))
		var/datum/patron/spira/spira_patron = patron
		return spira_patron.sinister
	return FALSE

// RMH EDIT: deity symbols shown in the character creator's deity tiles
/datum/patron
	/// Icon file holding this deity's symbol (null = the generic glyph)
	var/symbol_icon
	/// Icon state of the symbol
	var/symbol_state
	/// Cached base64 PNG of the symbol for the UI
	var/symbol_b64

/// Base64 PNG of the deity's symbol, or null
/datum/patron/proc/get_symbol()
	if(!symbol_icon || !symbol_state)
		return null
	if(!symbol_b64)
		symbol_b64 = icon2base64(icon(symbol_icon, symbol_state, SOUTH, 1))
	return symbol_b64

/datum/patron/spira/primordial/saelion
	symbol_icon = 'modular_rmh/icons/ui/patron_symbols.dmi'
	symbol_state = "saelion"

/datum/patron/spira/primordial/gaedon
	symbol_icon = 'modular_rmh/icons/ui/patron_symbols.dmi'
	symbol_state = "gaedon"

/datum/patron/spira/greater/ragelia
	symbol_icon = 'modular_rmh/icons/ui/patron_symbols.dmi'
	symbol_state = "ragelia"
