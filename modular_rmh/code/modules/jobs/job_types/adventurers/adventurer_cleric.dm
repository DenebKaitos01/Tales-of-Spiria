/datum/job/adventurer_cleric
	title = "Adventurer Cleric"
	tutorial = "Clerics are representatives of the gods they worship, wielding potent divine magic for good or ill. \
	ALLOWED PATRONS: Garl Glittergold, Helm, Mystra, Oghma, Tempus, Tymora, Silvanus, Jergal, Bahamut, Corellon Larethian, \
	Eilistraee, Ilmater, Lathander, Mielikki, Moradin, Selune, Tyr, Yondalla, Sune, Sharess, Torm, Milil, Deneir, \
	Mask, Vlaakith, Lolth, Shar, Gruumsh, Laduguer, Talos, Tiamat, Malar, Maglubiyet, Umberlee, Loviatar, Asmodeus. \
	DRAWS DIVINE POWER FROM AN ACTUAL DEITY OF ALL ALIGNMENTS AND DOMAINS."
	department_flag = ADVENTURERS
	faction = FACTION_NEUTRAL
	total_positions = 20
	spawn_positions = 20
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	display_order = JDO_ADVENTURER_CLERIC

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
	advclass_cat_rolls = list(CAT_ADVENTURER_CLERIC = 50)

	selection_color = JCOLOR_ADVENTURERS

	give_bank_account = TRUE
	exp_types_granted = list(EXP_TYPE_ADVENTURER, EXP_TYPE_COMBAT, EXP_TYPE_CLERIC, EXP_TYPE_MEDICAL)

	magic_user = TRUE
	spell_points = 30
	attunements_max = 10
	attunements_min = 5

	job_subclasses = list(
		/datum/job/advclass/combat/adventurer_cleric/death_domain,
		/datum/job/advclass/combat/adventurer_cleric/ironmaiden,
		/datum/job/advclass/combat/adventurer_cleric/life_domain,
		/datum/job/advclass/combat/adventurer_cleric/light_domain,
		/datum/job/advclass/combat/adventurer_cleric/war_domain,
	)

/datum/job/adventurer_cleric/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	if(!spawned || QDELETED(spawned))
		return
	to_chat(spawned, "<br><font color='#855b14'><span class='bold'>If I wanted to make amnas by selling my services, or completing quests, the Adventurers Guild would be a good place to start.</span></font><br>")
	spawned.add_spell(/datum/action/cooldown/spell/undirected/protection_evil_good, source = src)
	var/holder = spawned.patron?.devotion_holder
	if(holder)
		var/datum/devotion/devotion = new holder()
		devotion.make_cleric()
		devotion.grant_to(spawned)

