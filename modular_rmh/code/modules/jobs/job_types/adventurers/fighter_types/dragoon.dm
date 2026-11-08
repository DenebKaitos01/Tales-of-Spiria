// RMH EDIT: Dragoon. A spear fighter in lighter armor who leaps across the battlefield: dashing thrusts,
// strike-and-leap retreats, high jumps and acrobatic landings.

/datum/attribute_holder/sheet/job/advclass/combat/adventurer_fighter/dragoon
	raw_attribute_list = list(
		STAT_ENDURANCE = 1,
		STAT_CONSTITUTION = 1,
		STAT_SPEED = 2,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/wrestling = 20,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/combat/swords = 20,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/axesmaces = 10,
		/datum/attribute/skill/combat/bows = 10,
		/datum/attribute/skill/combat/crossbows = 10,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 30,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/reading = 10,
		/datum/attribute/skill/misc/riding = 30
	)

/datum/job/advclass/combat/adventurer_fighter/dragoon
	title = "Dragoon"
	tutorial = "A spear, light armor and legs that never stop. Dragoons dive into the fray with a full thrust \
	and are gone again in a single leap, striking from heights others can't reach."

	outfit = /datum/outfit/adventurer_fighter/dragoon
	category_tags = list(CAT_ADVENTURER_FIGHTER)
	give_bank_account = TRUE

	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/combat/adventurer_fighter/dragoon

	traits = list(
		TRAIT_MEDIUMARMOR,
		TRAIT_STEELHEARTED,
		TRAIT_ACROBAT,
	)

	spells = list(
		/datum/action/cooldown/spell/undirected/second_wind,
		/datum/action/cooldown/spell/dragoon_full_thrust,
		/datum/action/cooldown/spell/undirected/dragoon_elusive_jump,
	)

/datum/outfit/adventurer_fighter/dragoon
	name = "Dragoon"
	head = /obj/item/clothing/head/helmet/kettle/iron
	neck = /obj/item/clothing/neck/chaincoif/iron
	cloak = /obj/item/clothing/cloak/raincloak
	armor = /obj/item/clothing/armor/leather
	shirt = /obj/item/clothing/armor/gambeson/light
	wrists = /obj/item/clothing/wrists/bracers/leather
	gloves = /obj/item/clothing/gloves/leather
	pants = /obj/item/clothing/pants/trou/leather
	shoes = /obj/item/clothing/shoes/boots/leather
	backr = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/leather/adventurers_subclasses // needle, cloth and a health potion
	beltl = /obj/item/flashlight/flare/torch/lantern
	beltr = /obj/item/storage/belt/pouch/cloth/coins/poor

/datum/job/advclass/combat/adventurer_fighter/dragoon/after_spawn(mob/living/carbon/human/H, client/player_client)
	. = ..()
	var/static/list/weapon_kits = list(
		"Spear" = list(/obj/item/weapon/polearm/spear),
		"Billhook" = list(/obj/item/weapon/polearm/spear/billhook),
	)
	H.select_equippable(player_client, weapon_kits, message = "Choose Your Spear", title = "Dragoon")
	if(QDELETED(H))
		return
	H.adjust_skillrank_up_to(/datum/attribute/skill/combat/polearms, SKILL_RANK_EXPERT, TRUE)
