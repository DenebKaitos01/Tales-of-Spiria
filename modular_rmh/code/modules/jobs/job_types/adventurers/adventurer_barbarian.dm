GLOBAL_VAR_INIT(adventurer_hugbox_duration, 30 SECONDS)
GLOBAL_VAR_INIT(adventurer_hugbox_duration_still, 3 MINUTES)

// RMH EDIT: Barbarian rework. Every barbarian rages; the path chooses how.
// Martial Artist (bare-handed, tanned hide), Gladiator (great weapons, bronze plate, no hide)
// and Berserker (tanned hide, the slaughter-rites of the primordial chaos).

/datum/job/adventurer_barbarian
	title = "Adventurer Barbarian"
	tutorial = "The strong embrace the wild that hides inside - keen instincts, primal physicality, and most of all, an unbridled, unquenchable rage."
	department_flag = ADVENTURERS
	faction = FACTION_NEUTRAL
	total_positions = 20
	spawn_positions = 20
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	display_order = JDO_ADVENTURER_BARBARIAN

	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD, AGE_IMMORTAL)
	allowed_races = ALL_RACES_LIST
	advclass_cat_rolls = list(CAT_ADVENTURER_BARBARIAN = 50)

	selection_color = JCOLOR_ADVENTURERS

	give_bank_account = TRUE

	exp_types_granted = list(EXP_TYPE_ADVENTURER, EXP_TYPE_COMBAT)

	job_subclasses = list(
		/datum/job/advclass/combat/adventurer_barbarian/martial_artist,
		/datum/job/advclass/combat/adventurer_barbarian/gladiator,
		/datum/job/advclass/combat/adventurer_barbarian/berserker,
	)

/datum/job/adventurer_barbarian/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	to_chat(spawned, "<br><font color='#855b14'><span class='bold'>If I wanted to make amnas by selling my services, or completing quests, the Adventurers Guild would be a good place to start.</span></font><br>")

/// Shared parts of the three barbarian paths.
/datum/job/advclass/combat/adventurer_barbarian
	abstract_type = /datum/job/advclass/combat/adventurer_barbarian
	category_tags = list(CAT_ADVENTURER_BARBARIAN)
	give_bank_account = TRUE

// ---------------- Tanned hide ----------------
// As in Azure Peak, the hide is worn in the chest armour slot: it cannot be taken off,
// it leaves no room for other body armour, and it is destroyed if it ever leaves the body.

/datum/armor/skin/barbarian
	blunt = 30
	slash = 30
	stab = 30
	piercing = 20
	fire = 0
	acid = 0

/obj/item/clothing/armor/regenerating/skin/barbarian
	name = "tanned hide"
	desc = "Skin thickened by wind, cold and a hundred old wounds. It mends itself in time, but it is no match for proper mail."
	slot_flags = ITEM_SLOT_ARMOR
	armor_type = /datum/armor/skin/barbarian
	max_integrity = 200
	repair_time = 30 SECONDS

// ---------------- Rage, one flavour per path ----------------
// The base rage is +1 STR, +2 END, -2 PER, -2 INT for 30 seconds, followed by a falter.

/datum/status_effect/buff/barbrage/martial
	effectedstats = list(STAT_STRENGTH = 1, STAT_ENDURANCE = 2, STAT_SPEED = 2, STAT_PERCEPTION = -2, STAT_INTELLIGENCE = -2)

/datum/status_effect/buff/barbrage/gladiator
	effectedstats = list(STAT_STRENGTH = 2, STAT_ENDURANCE = 2, STAT_PERCEPTION = -2, STAT_INTELLIGENCE = -2)

/datum/status_effect/buff/barbrage/berserker
	effectedstats = list(STAT_STRENGTH = 2, STAT_ENDURANCE = 3, STAT_CONSTITUTION = -2, STAT_PERCEPTION = -2, STAT_INTELLIGENCE = -2)

/datum/action/cooldown/spell/undirected/barbrage/martial
	desc = "Enter a state of martial fervor: quicker fists and feet, at the cost of a clear head."
	rage_effect = /datum/status_effect/buff/barbrage/martial

/datum/action/cooldown/spell/undirected/barbrage/gladiator
	desc = "Enter a state of martial fervor: heavier blows, at the cost of a clear head."
	rage_effect = /datum/status_effect/buff/barbrage/gladiator

/datum/action/cooldown/spell/undirected/barbrage/berserker
	desc = "Give in to the slaughter: great strength and endurance, but heedless of your own body."
	rage_effect = /datum/status_effect/buff/barbrage/berserker
