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
	title = "Blade Dancer" // RMH EDIT: the base fighter subclass, formerly "Warrior"
	tutorial = "Steel is a dance, and you never miss a step. Blade Dancers are duelists and sellswords who \
	build momentum with every blow, until they move so fast they leave their own shadow behind."

	outfit = /datum/outfit/adventurer_fighter/warrior
	category_tags = list(CAT_ADVENTURER_FIGHTER)
	give_bank_account = TRUE

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/combat/adventurer_fighter/warrior


	traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_MOMENTUM,
	)

	spells = list(
		/datum/action/cooldown/spell/undirected/second_wind,
	)


// ------------------------------------------------------------
// RMH EDIT: the Blade Dancer picks an armor kit and a blade when spawning. Swords go to Expert.

/datum/outfit/adventurer_fighter/warrior
	name = "Blade Dancer"
	backr = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/leather/adventurers_subclasses // needle, cloth and a health potion, like the other adventurers
	beltl = /obj/item/flashlight/flare/torch/lantern
	beltr = /obj/item/storage/belt/pouch/cloth/coins/poor
	backpack_contents = list(/obj/item/repair_kit/poor_armorkit = 1)

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
			/obj/item/clothing/wrists/bracers/iron,
			/obj/item/clothing/gloves/leather/advanced,
			/obj/item/clothing/pants/trou/leather/advanced,
			/obj/item/clothing/shoes/boots/leather/advanced,
		),
	)
	H.select_equippable(player_client, armor_kits, message = "Choose Your Armor", title = "Blade Dancer")
	if(QDELETED(H))
		return

	var/static/list/weapon_kits = list(
		"Twin Longswords" = list(/obj/item/weapon/sword/long, /obj/item/weapon/sword/long),
		"Twin Sabres" = list(/obj/item/weapon/sword/sabre, /obj/item/weapon/sword/sabre),
	)
	var/weaponchoice = H.select_equippable(player_client, weapon_kits, message = "Choose Your Blades", title = "Blade Dancer")
	if(QDELETED(H) || !weaponchoice)
		return

	H.adjust_skillrank_up_to(/datum/attribute/skill/combat/swords, SKILL_RANK_EXPERT, TRUE)
	ADD_TRAIT(H, TRAIT_DUALWIELDER, JOB_TRAIT) // a blade in each hand
