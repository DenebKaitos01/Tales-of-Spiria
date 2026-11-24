// RMH EDIT: the three Champion ranks. Their kit comes from the patron (champion_kits.dm).

// --- Priest: light armour, weak arms, the strongest miracles ---

/datum/attribute_holder/sheet/job/advclass/combat/adventurer_champion/priest
	raw_attribute_list = list(
		STAT_STRENGTH = -1,
		STAT_INTELLIGENCE = 2,
		STAT_PERCEPTION = 2,
		STAT_CONSTITUTION = 1,
		STAT_ENDURANCE = 1,
		/datum/attribute/skill/magic/holy = 50,
		/datum/attribute/skill/misc/reading = 40,
		/datum/attribute/skill/misc/medicine = 30,
		/datum/attribute/skill/labor/mathematics = 20,
		/datum/attribute/skill/misc/athletics = 20,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/swimming = 10,
		/datum/attribute/skill/misc/sewing = 10,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/combat/wrestling = 10,
		/datum/attribute/skill/combat/unarmed = 10,
		/datum/attribute/skill/combat/axesmaces = 10,
		/datum/attribute/skill/combat/polearms = 10,
		/datum/attribute/skill/combat/whipsflails = 10,
	)

/datum/job/advclass/combat/adventurer_champion/priest
	title = "Priest"
	tutorial = "You carry no steel worth the name, but your god listens when you speak. \
	You start with the full grace of your patron, your devotion refills on its own, and your miracles mend, restore and raise."
	outfit = /datum/outfit/adventurer_champion/priest
	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/combat/adventurer_champion/priest
	champion_rank = CHAMPION_RANK_PRIEST

	traits = list(
		TRAIT_HOLY,
	)

	spells = list(
		/datum/action/cooldown/spell/undirected/touch/orison,
		/datum/action/cooldown/spell/healing,
		/datum/action/cooldown/spell/healing/greater,
		/datum/action/cooldown/spell/diagnose/holy,
		/datum/action/cooldown/spell/cure_rot,
		/datum/action/cooldown/spell/attach_bodypart,
		/datum/action/cooldown/spell/revive,
		/datum/action/cooldown/spell/status/guidance,
	)

// --- Cleric: medium armour and arms, middling miracles ---

/datum/attribute_holder/sheet/job/advclass/combat/adventurer_champion/cleric
	raw_attribute_list = list(
		STAT_STRENGTH = 1,
		STAT_INTELLIGENCE = 1,
		STAT_PERCEPTION = 1,
		STAT_CONSTITUTION = 2,
		STAT_ENDURANCE = 1,
		/datum/attribute/skill/magic/holy = 30,
		/datum/attribute/skill/misc/reading = 30,
		/datum/attribute/skill/misc/medicine = 20,
		/datum/attribute/skill/labor/mathematics = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/swimming = 10,
		/datum/attribute/skill/craft/cooking = 10,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/axesmaces = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/whipsflails = 30,
		/datum/attribute/skill/combat/shields = 20,
	)

/datum/job/advclass/combat/adventurer_champion/cleric
	title = "Cleric"
	tutorial = "Half shield, half prayer. You wear mail, fight well enough to hold a line, \
	and call on your god for healing and holy fire when the line starts to break."
	outfit = /datum/outfit/adventurer_champion/cleric
	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/combat/adventurer_champion/cleric
	champion_rank = CHAMPION_RANK_CLERIC

	traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_HOLY,
	)

	spells = list(
		/datum/action/cooldown/spell/undirected/touch/orison,
		/datum/action/cooldown/spell/healing,
		/datum/action/cooldown/spell/diagnose/holy,
		/datum/action/cooldown/spell/status/guidance,
		/datum/action/cooldown/spell/sacred_flame,
		/datum/action/cooldown/spell/undirected/blade_ward,
	)

// --- Paladin: heavy armour and arms, small miracles ---

/datum/attribute_holder/sheet/job/advclass/combat/adventurer_champion/paladin
	raw_attribute_list = list(
		STAT_STRENGTH = 2,
		STAT_CONSTITUTION = 2,
		STAT_ENDURANCE = 2,
		STAT_SPEED = -1,
		/datum/attribute/skill/magic/holy = 20,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 10,
		/datum/attribute/skill/misc/riding = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/axesmaces = 40,
		/datum/attribute/skill/combat/swords = 40,
		/datum/attribute/skill/combat/polearms = 40,
		/datum/attribute/skill/combat/whipsflails = 30,
		/datum/attribute/skill/combat/shields = 40,
	)

/datum/job/advclass/combat/adventurer_champion/paladin
	title = "Paladin"
	tutorial = "Steel first, faith behind it. You wear plate, master your god's chosen weapon \
	and hold a small spark of the divine: enough to steady an ally or burn a foe, never to raise the dead."
	outfit = /datum/outfit/adventurer_champion/paladin
	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/combat/adventurer_champion/paladin
	champion_rank = CHAMPION_RANK_PALADIN

	traits = list(
		TRAIT_HEAVYARMOR,
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_HOLY,
	)

	spells = list(
		/datum/action/cooldown/spell/undirected/touch/orison,
		/datum/action/cooldown/spell/healing,
		/datum/action/cooldown/spell/sacred_flame,
		/datum/action/cooldown/spell/undirected/blade_ward,
	)
