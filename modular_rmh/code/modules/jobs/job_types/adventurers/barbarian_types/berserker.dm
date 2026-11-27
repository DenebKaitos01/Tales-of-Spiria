/datum/attribute_holder/sheet/job/advclass/combat/adventurer_barbarian/berserker
	raw_attribute_list = list(
		STAT_STRENGTH = 3,
		STAT_PERCEPTION = -1,
		STAT_ENDURANCE = 1,
		STAT_CONSTITUTION = 2,
		STAT_INTELLIGENCE = -2,
		STAT_SPEED = 1,
		/datum/attribute/skill/combat/axesmaces = 40,
		/datum/attribute/skill/combat/swords = 30,
		/datum/attribute/skill/combat/unarmed = 30,
		/datum/attribute/skill/combat/wrestling = 30,
		/datum/attribute/skill/combat/shields = 20,
		// Feeds the length of Bloodrage (15 seconds per rank).
		/datum/attribute/skill/magic/holy = 30,
		/datum/attribute/skill/misc/athletics = 40,
		/datum/attribute/skill/misc/climbing = 40,
		/datum/attribute/skill/misc/swimming = 40,
		/datum/attribute/skill/misc/sneaking = 20,
		/datum/attribute/skill/misc/medicine = 10,
		/datum/attribute/skill/craft/tanning = 20,
		/datum/attribute/skill/labor/butchering = 20,
		/datum/attribute/skill/craft/cooking = 10,
	)

/datum/job/advclass/combat/adventurer_barbarian/berserker
	title = "Berserker"
	tutorial = "Violence is both a means and an end. You keep the old slaughter-rites of the primordial chaos: \
	blood answers blood, and when your fury breaks loose your allies feel it too."
	outfit = /datum/outfit/adventurer_barbarian/berserker
	attribute_sheet = /datum/attribute_holder/sheet/job/advclass/combat/adventurer_barbarian/berserker

	traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_STRONGBITE,
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_NOPAINSTUN,
		TRAIT_DUALWIELDER,
		TRAIT_DEADNOSE,
		TRAIT_BLINDFIGHTING,
	)

	spells = list(
		/datum/action/cooldown/spell/undirected/barbrage/berserker,
		/datum/action/cooldown/spell/undirected/bloodrage/berserker,
		/datum/action/cooldown/spell/undirected/berserker_call,
		/datum/action/cooldown/spell/projectile/blood_net/berserker,
	)

/datum/job/advclass/combat/adventurer_barbarian/berserker/after_spawn(mob/living/carbon/human/spawned, client/player_client)
	. = ..()
	var/static/list/selectableweapon = list(
		"Great Axe" = /obj/item/weapon/greataxe/steel,
		"Twin Axes" = list(/obj/item/weapon/axe/iron, /obj/item/weapon/axe/iron),
		"Sword and Shield" = list(/obj/item/weapon/sword/arming, /obj/item/weapon/shield/wood),
	)
	var/choice = spawned.select_equippable(player_client, selectableweapon, message = "Choose your weapon", title = "BERSERKER")
	switch(choice)
		if("Great Axe", "Twin Axes")
			spawned.clamped_adjust_skillrank(/datum/attribute/skill/combat/axesmaces, 1, 5, TRUE)
		if("Sword and Shield")
			spawned.clamped_adjust_skillrank(/datum/attribute/skill/combat/swords, 1, 4, TRUE)

/datum/outfit/adventurer_barbarian/berserker
	name = "Berserker"
	head = /obj/item/clothing/head/helmet/horned
	mask = /obj/item/clothing/face/skullmask
	neck = /obj/item/clothing/neck/chaincoif/iron
	cloak = /obj/item/clothing/cloak/raincloak/furcloak/colored/brown
	armor = /obj/item/clothing/armor/leather/hide
	wrists = /obj/item/clothing/wrists/bracers/leather
	gloves = /obj/item/clothing/gloves/leather/advanced
	pants = /obj/item/clothing/pants/trou/leather/advanced
	shoes = /obj/item/clothing/shoes/boots/leather/advanced
	backr = /obj/item/storage/backpack/satchel
	belt = /obj/item/storage/belt/leather/adventurers_subclasses

	backpack_contents = list(
		/obj/item/weapon/knife/hunting = 1,
		/obj/item/weapon/scabbard/knife = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
		/obj/item/storage/belt/pouch/cloth/coins/poor = 1,
		/obj/item/rope/chain = 1,
		/obj/item/reagent_containers/glass/bottle/stronghealthpot = 1,
	)

// ---------------- Slaughter-rites ----------------
// The berserker's own copies of the chaos miracles: paid in stamina, not devotion, and needing no patron.

/datum/action/cooldown/spell/undirected/bloodrage/berserker
	desc = "Shake off whatever holds you down and rise with unbound strength for a short while. \
	The longer you have kept the rites, the longer it lasts."
	spell_type = SPELL_STAMINA
	antimagic_flags = NONE
	spell_cost = 40

/datum/action/cooldown/spell/undirected/berserker_call
	name = "Call to Slaughter"
	desc = "Bellow for blood: you and the allies around you gain strength, endurance and constitution."
	button_icon_state = "call_to_slaughter"
	sound = 'sound/magic/timestop.ogg'

	spell_type = SPELL_STAMINA
	antimagic_flags = NONE
	associated_skill = /datum/attribute/skill/magic/holy
	invocation = "LAMBS TO THE SLAUGHTER!"
	invocation_type = INVOCATION_SHOUT

	charge_required = FALSE
	cooldown_time = 5 MINUTES
	spell_cost = 30

/datum/action/cooldown/spell/undirected/berserker_call/cast(atom/cast_on)
	. = ..()
	for(var/mob/living/carbon/target in viewers(3, get_turf(owner)))
		if(!owner.faction_check_atom(target))
			continue
		if(target.mob_biotypes & MOB_UNDEAD)
			continue
		target.apply_status_effect(/datum/status_effect/buff/call_to_slaughter)

/datum/action/cooldown/spell/projectile/blood_net/berserker
	desc = "Hurl a snare of blood and guts torn from a trophy in your hand. Like a net, may it catch your prey! \
	You need viscera in your hand to use this."
	spell_type = SPELL_STAMINA
	antimagic_flags = NONE
	spell_cost = 20
