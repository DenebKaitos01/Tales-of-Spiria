// RMH EDIT: Azure Peak's unarmed combat.
// Knuckles are worn in the gloves slot and multiply punches like any other glove (unarmed_bonus), instead of
// being a held weapon. While worn they keep the hands from fighting with held weapons (TRAIT_WEAPONLESS).
// Expert Pugilists (TRAIT_CIVILIZEDBARBARIAN) hit harder bare-handed and parry far better with knuckles,
// bandages or bracers.

/obj/item/clothing/gloves/knuckles
	name = "steel knuckles"
	desc = "A mean looking pair of steel knuckles."
	icon = 'icons/roguetown/weapons/32/fists_claws.dmi'
	icon_state = "steelknuckle"
	item_weight = 200 GRAMS
	w_class = WEIGHT_CLASS_SMALL
	max_integrity = INTEGRITY_STRONG
	blocksound = PLATEHIT
	blade_dulling = DULLING_BASH
	break_sound = 'sound/foley/breaksound.ogg'
	drop_sound = 'sound/foley/dropsound/armor_drop.ogg'
	anvilrepair = /datum/attribute/skill/craft/weapon_repair
	sewrepair = null
	melting_material = /datum/material/steel
	melt_amount = 75
	unarmed_bonus = 1.6

/obj/item/clothing/gloves/knuckles/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Worn on the hands: punches deal [unarmed_bonus * 100]% damage.")
	. += span_info("Improves unarmed parrying; Expert Pugilists parry far better with these.")
	. += span_warning("While worn, I cannot fight with weapons or hold a shield.")

/obj/item/clothing/gloves/knuckles/mob_can_equip(mob/living/M, mob/living/equipper, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if((slot & ITEM_SLOT_GLOVES) && (locate(/obj/item/weapon/shield) in M.held_items))
		if(!disable_warning)
			to_chat(M, span_warning("I can't wear [src] while holding a shield."))
		return FALSE
	return ..()

/obj/item/clothing/gloves/knuckles/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	if(slot & ITEM_SLOT_GLOVES)
		ADD_TRAIT(user, TRAIT_WEAPONLESS, REF(src))
		if(!initial)
			to_chat(user, span_warning("[src] strengthen my fists, but I can no longer fight with weapons."))
	else
		REMOVE_TRAIT(user, TRAIT_WEAPONLESS, REF(src))

/obj/item/clothing/gloves/knuckles/dropped(mob/user, silent = FALSE)
	. = ..()
	if(HAS_TRAIT_FROM(user, TRAIT_WEAPONLESS, REF(src)))
		REMOVE_TRAIT(user, TRAIT_WEAPONLESS, REF(src))
		to_chat(user, span_notice("Free of [src], my fingers can wield weapons again."))

/obj/item/clothing/gloves/knuckles/psydon
	name = "exotic knuckles"
	desc = "A simple piece of harm molded in a holy mixture of steel and silver, finished with three stumps - Psydon's crown - to crush the heretics' garments and armor into smithereens."
	icon = 'icons/roguetown/weapons/32/psydonite.dmi'
	icon_state = "psyknuckle"
	max_integrity = INTEGRITY_STRONG + 50
	unarmed_bonus = 1.7

/obj/item/clothing/gloves/knuckles/eora
	name = "close caress"
	desc = "Some times call for a more intimate approach."
	icon = 'icons/roguetown/weapons/32/patron.dmi'
	icon_state = "eoraknuckle"
	unarmed_bonus = 1.75

/// Bonus to an unarmed parry from what is worn on the hands and wrists
/mob/living/proc/get_unarmed_parry_bonus()
	return 0

/mob/living/carbon/human/get_unarmed_parry_bonus()
	var/equipped = istype(gloves, /obj/item/clothing/gloves/knuckles) || istype(gloves, /obj/item/clothing/gloves/bandages) || istype(wear_wrists, /obj/item/clothing/wrists/bracers)
	if(!equipped)
		return 0
	var/unarmed_skill = GET_MOB_SKILL_VALUE(src, /datum/attribute/skill/combat/unarmed)
	// An Expert Pugilist parries with them as well as with a held weapon; anyone else gets half of that
	return HAS_TRAIT(src, TRAIT_CIVILIZEDBARBARIAN) ? unarmed_skill : round(unarmed_skill / 2)
