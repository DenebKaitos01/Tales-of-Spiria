/datum/attribute_holder/sheet/job/advclass/combat/adventurer_barbarian/martial_artist
	raw_attribute_list = list(
		STAT_STRENGTH = 2,
		STAT_PERCEPTION = -1,
		STAT_ENDURANCE = 2,
		STAT_CONSTITUTION = 1,
		STAT_INTELLIGENCE = -1,
		STAT_SPEED = 2,
		/datum/attribute/skill/combat/unarmed = 50,
		/datum/attribute/skill/combat/wrestling = 40,
		/datum/attribute/skill/combat/knives = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/swimming = 30,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/craft/cooking = 10,
	)

/datum/job/advclass/combat/adventurer_barbarian/martial_artist
	title = "Martial Artist"
	tutorial = "No blade, no shield, no armour worth the name. Your fists were hardened on stone and bone, \
	your hide on wind and frost, and your rage makes both strike faster."
	outfit = /datum/outfit/adventurer_barbarian/martial_artist
	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/combat/adventurer_barbarian/martial_artist

	traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_NOPAINSTUN,
		TRAIT_DEADNOSE,
		TRAIT_BLINDFIGHTING,
		TRAIT_CIVILIZEDBARBARIAN,
	)

	spells = list(
		/datum/action/cooldown/spell/undirected/barbrage/martial,
	)

/datum/outfit/adventurer_barbarian/martial_artist
	name = "Martial Artist"
	cloak = /obj/item/clothing/cloak/raincloak/furcloak/colored/brown
	armor = /obj/item/clothing/armor/regenerating/skin/barbarian
	wrists = /obj/item/clothing/wrists/bracers/leather
	gloves = /obj/item/clothing/gloves/knuckles
	pants = /obj/item/clothing/pants/trou/leather/advanced
	shoes = /obj/item/clothing/shoes/boots/leather/advanced
	backr = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/leather/adventurers_subclasses

	backpack_contents = list(
		/obj/item/weapon/knife/hunting = 1,
		/obj/item/weapon/scabbard/knife = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/storage/belt/pouch/cloth/coins/poor = 1,
		/obj/item/clothing/gloves/bandages = 1,
		/obj/item/reagent_containers/glass/bottle/stronghealthpot = 1,
	)
