// RMH EDIT: Battlemaster. The most balanced fighter: steady stats with a sharper mind for feints, a solid
// mix of mail training and leather, and techniques that keep their guard, feints and specials flowing.

/datum/attribute_holder/sheet/job/advclass/combat/adventurer_fighter/battlemaster
	raw_attribute_list = list(
		STAT_STRENGTH = 1,
		STAT_ENDURANCE = 1,
		STAT_CONSTITUTION = 1,
		STAT_INTELLIGENCE = 2,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/axesmaces = 30,
		/datum/attribute/skill/combat/shields = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/polearms = 20,
		/datum/attribute/skill/combat/whipsflails = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/bows = 10,
		/datum/attribute/skill/combat/crossbows = 10,
		/datum/attribute/skill/misc/athletics = 30,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/reading = 20,
		/datum/attribute/skill/misc/riding = 20
	)

/datum/job/advclass/combat/adventurer_fighter/battlemaster
	title = "Battlemaster"
	tutorial = "Neither the strongest nor the fastest, but the one who always knows what comes next. \
	Battlemasters read the fight, feint, bait and guard, and turn every opening into the next one."

	outfit = /datum/outfit/adventurer_fighter/battlemaster
	category_tags = list(CAT_ADVENTURER_FIGHTER)
	give_bank_account = TRUE

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/combat/adventurer_fighter/battlemaster

	traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_SOLID_FOUNDATIONS,
	)

	spells = list(
		/datum/action/cooldown/spell/undirected/second_wind,
		/datum/action/cooldown/spell/undirected/action_surge,
	)

/datum/outfit/adventurer_fighter/battlemaster
	name = "Battlemaster"
	head = /obj/item/clothing/head/helmet/kettle/iron
	neck = /obj/item/clothing/neck/chaincoif/iron
	armor = /obj/item/clothing/armor/leather/advanced
	shirt = /obj/item/clothing/armor/gambeson/light
	wrists = /obj/item/clothing/wrists/bracers/leather
	gloves = /obj/item/clothing/gloves/leather/advanced
	pants = /obj/item/clothing/pants/trou/leather/advanced
	shoes = /obj/item/clothing/shoes/boots/leather/advanced
	backr = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/leather/adventurers_subclasses // needle, cloth and a health potion
	beltl = /obj/item/flashlight/flare/torch/lantern
	beltr = /obj/item/storage/belt/pouch/cloth/coins/poor
	backpack_contents = list(/obj/item/repair_kit/poor_armorkit = 1)

/datum/job/advclass/combat/adventurer_fighter/battlemaster/after_spawn(mob/living/carbon/human/H, client/player_client)
	. = ..()
	var/static/list/weapon_kits = list(
		"Longsword" = list(/obj/item/weapon/sword/long),
		"Axe" = list(/obj/item/weapon/axe/iron),
		"Mace" = list(/obj/item/weapon/mace),
	)
	var/weaponchoice = H.select_equippable(player_client, weapon_kits, message = "Choose Your Weapon", title = "Battlemaster")
	if(QDELETED(H) || !weaponchoice)
		return
	if(weaponchoice == "Longsword")
		H.adjust_skillrank_up_to(/datum/attribute/skill/combat/swords, SKILL_RANK_EXPERT, TRUE)
	else
		H.adjust_skillrank_up_to(/datum/attribute/skill/combat/axesmaces, SKILL_RANK_EXPERT, TRUE)

	var/static/list/shield_kits = list(
		"Iron Buckler" = list(/obj/item/weapon/shield/tower/buckleriron),
		"Wooden Shield" = list(/obj/item/weapon/shield/wood),
		"No Shield" = list(),
	)
	H.select_equippable(player_client, shield_kits, message = "Choose Your Shield", title = "Battlemaster")
