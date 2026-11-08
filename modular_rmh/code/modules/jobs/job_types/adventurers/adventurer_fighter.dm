/datum/job/adventurer_fighter
	title = "Adventurer Fighter"
	tutorial = "Fighters have mastered the art of combat, wielding weapons with unmatched skill and wearing armour like a second skin."
	department_flag = ADVENTURERS
	faction = FACTION_NEUTRAL
	total_positions = 20
	spawn_positions = 20
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	display_order = JDO_ADVENTURER_FIGHTER

	allowed_ages = list(AGE_ADULT, AGE_MIDDLEAGED, AGE_OLD, AGE_IMMORTAL)
	allowed_races = ALL_RACES_LIST
	advclass_cat_rolls = list(CAT_ADVENTURER_FIGHTER = 50)

	selection_color = JCOLOR_ADVENTURERS

	give_bank_account = TRUE
	exp_types_granted = list(EXP_TYPE_ADVENTURER, EXP_TYPE_COMBAT)

	// RMH EDIT: fighter subclasses pruned to one base class; new ones derive from it with small bonuses
	job_subclasses = list(
		/datum/job/advclass/combat/adventurer_fighter/warrior,
		/datum/job/advclass/combat/adventurer_fighter/ironclad,
		/datum/job/advclass/combat/adventurer_fighter/dragoon,
		/datum/job/advclass/combat/adventurer_fighter/battlemaster,
	)

/datum/job/adventurer_fighter/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	to_chat(spawned, "<br><font color='#855b14'><span class='bold'>If I wanted to make amnas by selling my services, or completing quests, the Adventurers Guild would be a good place to start.</span></font><br>")

