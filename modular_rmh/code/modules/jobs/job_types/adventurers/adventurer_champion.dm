// RMH EDIT: Champion. The adventurer cleric and paladin merged into one miracle-worker with three ranks:
// Priest (light armour, weak arms, strong miracles), Cleric (medium on all three) and Paladin
// (heavy armour and arms, small miracles). Miracles come from the patron through devotion; no spell points.
// The kit depends on the patron, see champion_kits.dm.

/datum/job/adventurer_champion
	title = "Adventurer Champion"
	tutorial = "Champions carry the will of their god into the wilds: a priest who works great miracles, \
	a cleric who stands between blade and prayer, or a paladin clad in steel with a spark of the divine. \
	Your god chooses your colours and your arms; your path chooses how much of its power you hold."
	department_flag = ADVENTURERS
	faction = FACTION_NEUTRAL
	total_positions = 20
	spawn_positions = 20
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	display_order = JDO_ADVENTURER_CHAMPION

	allowed_patrons = list(
		/datum/patron/spira/primordial/gaedon,
		/datum/patron/spira/primordial/saelion,
		/datum/patron/spira/greater/sirokel,
		/datum/patron/spira/greater/naverae,
		/datum/patron/spira/greater/ragelia,
		/datum/patron/spira/lesser/lunestra,
	)

	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD, AGE_IMMORTAL)
	allowed_races = ALL_RACES_LIST
	advclass_cat_rolls = list(CAT_ADVENTURER_CHAMPION = 50)

	selection_color = JCOLOR_ADVENTURERS

	give_bank_account = TRUE
	exp_types_granted = list(EXP_TYPE_ADVENTURER, EXP_TYPE_COMBAT, EXP_TYPE_CLERIC, EXP_TYPE_MEDICAL)

	job_subclasses = list(
		/datum/job/advclass/combat/adventurer_champion/priest,
		/datum/job/advclass/combat/adventurer_champion/cleric,
		/datum/job/advclass/combat/adventurer_champion/paladin,
	)

/datum/job/adventurer_champion/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	if(!spawned || QDELETED(spawned))
		return
	to_chat(spawned, "<br><font color='#855b14'><span class='bold'>If I wanted to make amnas by selling my services, or completing quests, the Adventurers Guild would be a good place to start.</span></font><br>")

/// Shared parts of the three Champion ranks.
/datum/job/advclass/combat/adventurer_champion
	abstract_type = /datum/job/advclass/combat/adventurer_champion
	category_tags = list(CAT_ADVENTURER_CHAMPION)
	give_bank_account = TRUE
	languages = list(/datum/language/celestial)
	/// Which devotion profile this rank gets: one of the CHAMPION_RANK_* values.
	var/champion_rank

/datum/job/advclass/combat/adventurer_champion/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	if(!spawned || QDELETED(spawned))
		return
	spawned.add_spell(/datum/action/cooldown/spell/undirected/protection_evil_good, source = src)
	// The devotion is made once, here. The miracles it grants come from the patron.
	var/holder = spawned.patron?.devotion_holder
	if(!holder)
		return
	var/datum/devotion/devotion = new holder()
	devotion.make_champion(champion_rank)
	devotion.grant_to(spawned)
