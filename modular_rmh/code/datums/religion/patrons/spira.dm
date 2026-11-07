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
	domain = "Ambition, Foundations, the First of All Things"
	desc = "The primordial god who withstood the chaos and forced a stable world out of it: Paradise. \
	Arrogant and tyrannical, he built the foundations of the world and its first servants, struck down Sirokel \
	for her theft and now lies imprisoned in his own creation. He is shown as chains and golden shackles."
	worshippers = "The ambitious, builders, tyrants and those who would rule"
	flaws = "Arrogance, Tyranny, Wrath"
	sins = "Ingratitude, Theft from one's master, Submitting to the usurper"
	boons = "You recover more energy when sleeping."
	added_traits = list(TRAIT_BETTER_SLEEP)
	devotion_holder = /datum/devotion/divine/malum
	sinister = TRUE
	confess_lines = list(
		"GAEDON WAS FIRST, AND GAEDON WILL BE LAST!",
		"NO CHAIN HOLDS THE FIRSTBORN FOREVER!",
		"ALL THAT STANDS WAS BUILT BY HIS HAND!",
	)

/datum/patron/spira/primordial/saelion
	name = "Saelion"
	display_name = "Saelion, the Blue Flame"
	domain = "Life, Creation, Nature and Beasts"
	desc = "A small being born from the chaos with a gift Gaedon never had: the power to create life. \
	Hidden and taught by Sirokel, he received her stolen essence and imprisoned his creator. \
	The faithful of Gaedon call him the usurper; everyone else calls him the patron of all life. \
	He is shown as a bluish flame."
	worshippers = "Druids, hunters, farmers, healers and every living thing"
	flaws = "Recklessness, Vengefulness, Careless experiments"
	sins = "Wasting life, Despoiling the wild, Cruelty to beasts"
	boons = "You are immune to kneestingers."
	added_traits = list(TRAIT_KNEESTINGER_IMMUNITY)
	devotion_holder = /datum/devotion/divine/dendor
	confess_lines = list(
		"THE BLUE FLAME BURNS IN ALL THAT LIVES!",
		"SAELION GAVE US LIFE!",
		"WHAT LIVES, LIVES BY HIS GRACE!",
	)

// ---------------- Greater Gods ----------------

/datum/patron/spira/greater/sirokel
	name = "Sirokel"
	display_name = "Sirokel, the Pierced Star"
	domain = "Mercy, Protection of the Just, the Stars and the Source of Magic"
	desc = "The first servant of Gaedon, who made the stars with him. She stole her creator's essence to give it \
	to Saelion and was run through the back for it. Her blood is the font of all magic lent to mortals. \
	She is shown as a woman pierced by a sword, or as a blue star."
	worshippers = "The merciful, healers, protectors, mages and the just"
	flaws = "Defiance, Recklessness, Trusting too deeply"
	sins = "Cruelty, Abandoning the weak, Hoarding gifts that should be shared"
	boons = "Your stamina regeneration delay is lowered during daytime."
	added_traits = list(TRAIT_APRICITY)
	devotion_holder = /datum/devotion/divine/astrata
	confess_lines = list(
		"SIROKEL SHIELDS THE JUST!",
		"HER BLOOD IS OUR MAGIC, HER MERCY OUR SHIELD!",
		"BY THE PIERCED STAR, I WILL NOT YIELD!",
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
	display_name = "Ragelia, the Guardian of Paradise"
	domain = "War, Vigilance and Loyalty"
	desc = "Born to help fight, Ragelia battled entropy and the THINGS of the primordial chaos alongside Gaedon. \
	He spared Saelion only at Sirokel's request, sided with his creator in the war and was allowed to live on \
	as the guardian of Paradise. His order is one of blind loyalty and constant vigilance against evil."
	worshippers = "Warriors, guards, sellswords and watchmen"
	flaws = "Blind obedience, Harshness, Rigidity"
	sins = "Cowardice, Desertion, Letting the chaos in"
	boons = "Your used weapons dull slower."
	added_traits = list(TRAIT_SHARPER_BLADES)
	devotion_holder = /datum/devotion/divine/ravox
	confess_lines = list(
		"RAGELIA STANDS GUARD, AND SO DO I!",
		"NOTHING FROM THE CHAOS PASSES!",
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
