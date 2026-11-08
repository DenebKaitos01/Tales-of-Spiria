// RMH EDIT: Ironclad (from Azure Peak). A fighter who trusts heavy iron armor and big weapons:
// tough and strong rather than sharp or quick, Journeyman across the combat skills.

/datum/attribute_holder/sheet/job/advclass/combat/adventurer_fighter/ironclad
	raw_attribute_list = list(
		STAT_STRENGTH = 2,
		STAT_ENDURANCE = 2,
		STAT_CONSTITUTION = 2,
		STAT_INTELLIGENCE = -1,
		STAT_PERCEPTION = -1,
		STAT_SPEED = -1,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/axesmaces = 30,
		/datum/attribute/skill/combat/whipsflails = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/bows = 10,
		/datum/attribute/skill/combat/crossbows = 10,
		/datum/attribute/skill/misc/swimming = 10,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 20
	)

/datum/job/advclass/combat/adventurer_fighter/ironclad
	title = "Ironclad"
	tutorial = "You put your trust in durable armor and a heavy weapon. \
	The best offense is a good defense: let them break their blades on your iron."

	outfit = /datum/outfit/adventurer_fighter/ironclad
	category_tags = list(CAT_ADVENTURER_FIGHTER)
	give_bank_account = TRUE

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/combat/adventurer_fighter/ironclad

	traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_HEAVYARMOR,
		TRAIT_STEELHEARTED,
	)

	spells = list(
		/datum/action/cooldown/spell/undirected/second_wind,
		/datum/action/cooldown/spell/undirected/bulwark,
	)

/datum/outfit/adventurer_fighter/ironclad
	name = "Ironclad"
	backr = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/leather/adventurers_subclasses // needle, cloth and a health potion, like the other adventurers
	beltl = /obj/item/flashlight/flare/torch/lantern
	beltr = /obj/item/storage/belt/pouch/cloth/coins/poor
	backpack_contents = list(/obj/item/repair_kit/poor_armorkit = 1)

/datum/job/advclass/combat/adventurer_fighter/ironclad/after_spawn(mob/living/carbon/human/H, client/player_client)
	. = ..()

	// Armor goes on first so the shields and weapons find their slots afterwards
	var/static/list/armor_kits = list(
		"Iron Full Plate" = list(
			/obj/item/clothing/armor/plate/full/iron,
			/obj/item/clothing/armor/gambeson,
			/obj/item/clothing/neck/bevor/iron,
			/obj/item/clothing/wrists/bracers/iron,
			/obj/item/clothing/gloves/plate/iron,
			/obj/item/clothing/pants/platelegs/iron,
			/obj/item/clothing/shoes/boots/armor,
			/obj/item/clothing/head/helmet/heavy/ironplate,
		),
		"Half-Plate & Hauberk" = list(
			/obj/item/clothing/armor/plate/iron,
			/obj/item/clothing/armor/chainmail/hauberk/iron,
			/obj/item/clothing/neck/bevor/iron,
			/obj/item/clothing/wrists/bracers/iron,
			/obj/item/clothing/gloves/chain/iron,
			/obj/item/clothing/pants/chainlegs/iron,
			/obj/item/clothing/shoes/boots/armor/ironmaille,
			/obj/item/clothing/head/helmet/visored/sallet/iron,
		),
		"Breastplate, Hauberk & Kilt" = list(
			/obj/item/clothing/armor/cuirass/iron,
			/obj/item/clothing/armor/chainmail/hauberk/iron,
			/obj/item/clothing/neck/gorget,
			/obj/item/clothing/wrists/bracers/iron,
			/obj/item/clothing/gloves/chain/iron,
			/obj/item/clothing/pants/chainlegs/kilt/iron,
			/obj/item/clothing/shoes/boots/armor/ironmaille,
			/obj/item/clothing/head/helmet/kettle/slit/iron,
		),
	)
	H.select_equippable(player_client, armor_kits, message = "Choose Your Armor", title = "Ironclad")
	if(QDELETED(H))
		return

	var/static/list/weapon_kits = list(
		"Executioner's Sword" = list(/obj/item/weapon/sword/long/exe),
		"Greataxe" = list(/obj/item/weapon/greataxe),
		"Warclub" = list(/obj/item/weapon/mace/goden),
		"Lucerne" = list(/obj/item/weapon/polearm/eaglebeak/lucerne),
		"Warhammer & Kite Shield" = list(/obj/item/weapon/mace/warhammer, /obj/item/weapon/shield/tower/metal),
		"Flail & Kite Shield" = list(/obj/item/weapon/flail, /obj/item/weapon/shield/tower/metal),
	)
	H.select_equippable(player_client, weapon_kits, message = "Choose Your Weapon", title = "Ironclad")
