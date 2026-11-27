/datum/attribute_holder/sheet/job/advclass/combat/adventurer_barbarian/gladiator
	raw_attribute_list = list(
		STAT_STRENGTH = 3,
		STAT_ENDURANCE = 1,
		STAT_CONSTITUTION = 2,
		STAT_INTELLIGENCE = -1,
		STAT_SPEED = -1,
		/datum/attribute/skill/combat/axesmaces = 30,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/polearms = 30,
		/datum/attribute/skill/combat/shields = 20,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/combat/unarmed = 20,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 20,
		/datum/attribute/skill/misc/swimming = 20,
		/datum/attribute/skill/misc/medicine = 10,
	)

/datum/job/advclass/combat/adventurer_barbarian/gladiator
	title = "Gladiator"
	tutorial = "Sold to the pits or drawn to them, you learned to swing what lesser fighters cannot lift, \
	and to wear bronze through the heat of the sand. The crowd is gone, but the rage stayed."
	outfit = /datum/outfit/adventurer_barbarian/gladiator
	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/combat/adventurer_barbarian/gladiator

	traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_NOPAINSTUN,
		TRAIT_DEADNOSE,
		TRAIT_MEDIUMARMOR,
		TRAIT_HEAVYARMOR,
	)

	spells = list(
		/datum/action/cooldown/spell/undirected/barbrage/gladiator,
	)

/datum/job/advclass/combat/adventurer_barbarian/gladiator/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	var/static/list/selectableweapon = list(
		"Great Axe" = /obj/item/weapon/greataxe/steel,
		"Greatsword" = /obj/item/weapon/sword/long/greatsword,
		"Goden" = /obj/item/weapon/mace/goden/steel,
		"Warhammer" = /obj/item/weapon/mace/goden/steel/warhammer,
		"Halberd" = /obj/item/weapon/polearm/halberd,
	)
	var/choice = spawned.select_equippable(player_client, selectableweapon, message = "Choose your weapon", title = "GLADIATOR")
	switch(choice)
		if("Great Axe", "Goden", "Warhammer")
			spawned.clamped_adjust_skillrank(/datum/attribute/skill/combat/axesmaces, 1, 4, TRUE)
		if("Greatsword")
			spawned.clamped_adjust_skillrank(/datum/attribute/skill/combat/swords, 1, 4, TRUE)
		if("Halberd")
			spawned.clamped_adjust_skillrank(/datum/attribute/skill/combat/polearms, 1, 4, TRUE)

/datum/outfit/adventurer_barbarian/gladiator
	name = "Gladiator"
	head = /obj/item/clothing/head/helmet/bronzegladiator
	neck = /obj/item/clothing/neck/gorget/bronze
	armor = /obj/item/clothing/armor/plate/full/bronze
	shirt = /obj/item/clothing/shirt/undershirt/colored/black
	wrists = /obj/item/clothing/wrists/bracers/leather/heavy
	gloves = /obj/item/clothing/gloves/chain/bronze
	pants = /obj/item/clothing/pants/chainlegs/kilt
	shoes = /obj/item/clothing/shoes/boots/leather/reinforced
	backr = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/leather/adventurers_subclasses

	backpack_contents = list(
		/obj/item/weapon/knife/hunting = 1,
		/obj/item/weapon/scabbard/knife = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/storage/belt/pouch/cloth/coins/poor = 1,
		/obj/item/reagent_containers/glass/bottle/stronghealthpot = 1,
	)
