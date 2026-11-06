/datum/attribute_holder/sheet/job/advclass/combat/adventurer_fighter/warrior
	raw_attribute_list = list(
		STAT_STRENGTH = 2,
		STAT_ENDURANCE = 1,
		STAT_CONSTITUTION = 2,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/axesmaces = 20,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/bows = 10,
		/datum/attribute/skill/combat/crossbows = 10,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 20
	)

/datum/job/advclass/combat/adventurer_fighter/warrior
	title = "Warrior" // RMH EDIT: the base fighter subclass
	tutorial = "On the Sword Coast, steel speaks louder than promises. \
	Warriors are mercenaries, caravan guards, militia veterans, \
	and hardened survivors of countless skirmishes."

	outfit = /datum/outfit/adventurer_fighter/warrior
	category_tags = list(CAT_ADVENTURER_FIGHTER)
	give_bank_account = TRUE

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/combat/adventurer_fighter/warrior


	traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
	)

	spells = list(
		/datum/action/cooldown/spell/undirected/second_wind,
	)


// ------------------------------------------------------------
// RMH EDIT: the Warrior picks a weapon kit and an armor kit when spawning. The chosen weapon's skill goes to Expert.

/datum/outfit/adventurer_fighter/warrior
	name = "Warrior"
	belt = /obj/item/storage/belt/leather
	beltl = /obj/item/flashlight/flare/torch/lantern
	beltr = /obj/item/storage/belt/pouch/cloth/coins/poor

/datum/job/advclass/combat/adventurer_fighter/warrior/after_spawn(mob/living/carbon/human/H, client/player_client)
	. = ..()

	// Armor goes on first so the shields and weapons find their slots afterwards
	var/static/list/armor_kits = list(
		"Maille & Leather" = list(
			/obj/item/clothing/armor/leather,
			/obj/item/clothing/armor/chainmail/iron,
			/obj/item/clothing/wrists/bracers/ironjackchain,
			/obj/item/clothing/pants/trou/leather/splint,
			/obj/item/clothing/shoes/boots/leather,
			/obj/item/clothing/gloves/leather,
			/obj/item/clothing/neck/chaincoif/iron,
			/obj/item/clothing/head/helmet/kettle/iron,
		),
		"Breastplate & Gambeson" = list(
			/obj/item/clothing/armor/cuirass/iron,
			/obj/item/clothing/armor/gambeson,
			/obj/item/clothing/neck/gorget,
			/obj/item/clothing/pants/trou/leather,
			/obj/item/clothing/shoes/boots/leather,
		),
	)
	H.select_equippable(player_client, armor_kits, message = "Choose Your Armor", title = "Warrior")
	if(QDELETED(H))
		return

	var/static/list/weapon_kits = list(
		"Short Sword & Iron Shield" = list(/obj/item/weapon/sword/short, /obj/item/weapon/shield/tower/buckleriron),
		"Longsword & Wrestling" = list(/obj/item/weapon/sword/long),
		"Battle Axe & Wood Shield" = list(/obj/item/weapon/axe/battle, /obj/item/weapon/shield/wood),
		"Mace & Iron Shield" = list(/obj/item/weapon/mace, /obj/item/weapon/shield/tower/buckleriron),
	)
	var/weaponchoice = H.select_equippable(player_client, weapon_kits, message = "Choose Your Martial Training", title = "Warrior")
	if(QDELETED(H) || !weaponchoice)
		return

	switch(weaponchoice)
		if("Short Sword & Iron Shield")
			H.adjust_skillrank_up_to(/datum/attribute/skill/combat/swords, SKILL_RANK_EXPERT, TRUE)
		if("Longsword & Wrestling")
			H.adjust_skillrank_up_to(/datum/attribute/skill/combat/swords, SKILL_RANK_EXPERT, TRUE)
			H.adjust_skillrank(/datum/attribute/skill/combat/wrestling, 1, TRUE)
		if("Battle Axe & Wood Shield", "Mace & Iron Shield")
			H.adjust_skillrank_up_to(/datum/attribute/skill/combat/axesmaces, SKILL_RANK_EXPERT, TRUE)
