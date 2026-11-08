// RMH EDIT: Azure Peak's repair rework (Azure-Peak PR #8476), adapted to RMH's hammer, needle and kits.
//
// Hammers and needles have two repair methods, swapped by using the tool in hand:
// - Expedient (default): one action that scales with skill and never fails.
//     No skill 20% of max integrity, Novice 25%, Apprentice 34%, Journeyman 50%, Expert+ 100%.
//     Each expedient repair of clothing/armor wears its max integrity down by 2%, unless the repairer got lucky
//     (Fortune, Intelligence and skill), works on an anvil (hammer) or fancy/folding table (needle), knows the
//     armor's class (Mail/Plate Training, Fast Reflexes for light armor), or the damage was minor (90%+).
//     An Expert or better restores the max integrity instead.
// - Safe: slow, small steady repairs that never wear the item down.
// Lost max integrity comes back with an Expert repair, a repair kit or the Ameliorate.

#define REPAIR_TYPE_SEW "sew"
#define REPAIR_TYPE_HAMMER "hammer"
#define REPAIR_METHOD_EXPEDIENT "fast"
#define REPAIR_METHOD_SAFE "slow"
#define REPAIR_STAGE_ONE 1
#define REPAIR_STAGE_TWO 2
#define REPAIR_STAGE_THREE 3
#define REPAIR_STAGE_FINAL 4
#define REPAIR_STAGE_DING 5
#define REPAIR_STAGE_INTEGLOSS 6

/obj/item
	/// A repair is being performed with this tool
	var/repair_busy = FALSE
	/// Expedient or safe repairs (hammers and needles)
	var/repair_method = REPAIR_METHOD_EXPEDIENT
	/// The max integrity this item had before repairs started wearing it down (0 = never worn down)
	var/true_max_integrity = 0

/// The max integrity the item can be restored to
/obj/item/proc/get_true_max_integ()
	return true_max_integrity || max_integrity

/// Restores the max integrity lost to repairs, and optionally fully repairs the item
/obj/item/proc/restore_max_integ(fully_restore = TRUE)
	if(true_max_integrity)
		max_integrity = true_max_integrity
	if(fully_restore && uses_integrity)
		repair_damage(max_integrity)
		if(obj_broken)
			atom_fix()

/obj/item/proc/has_lost_max_integ()
	return isclothing(src) && (floor(get_true_max_integ()) - floor(max_integrity)) >= 5

/// Skill level 0-6 of the user in the given skill
/proc/repair_skill_level(mob/living/user, skill)
	if(!skill)
		return 0
	return clamp(floor(GET_MOB_SKILL_VALUE(user, skill) / 10), 0, 6)

/obj/item/proc/on_repair_surface()
	return ontable() || istype(loc, /obj/machinery/anvil) || (locate(/obj/machinery/anvil) in loc)

/obj/item/proc/repair_effect_check(mob/living/user)
	return user && Adjacent(user)

// ---------------- Effects ----------------

/obj/effect/temp_visual/repair_fx
	icon = 'icons/effects/effects_repair.dmi'
	randomdir = FALSE
	layer = ABOVE_MOB_LAYER
	plane = ABOVE_LIGHTING_PLANE

/obj/effect/temp_visual/repair_fx/Initialize(mapload, customdur, customstate)
	if(customdur)
		duration = customdur
	if(customstate)
		icon_state = customstate
	. = ..()

/obj/item/proc/play_repair_vfx(istate, timer)
	if(istate && timer)
		new /obj/effect/temp_visual/repair_fx(get_turf(src), timer, istate)

/obj/item/proc/perform_repair_effect(mob/living/user, stage, repair_type)
	if(!repair_effect_check(user))
		return
	switch(repair_type)
		if(REPAIR_TYPE_SEW)
			if(stage in list(REPAIR_STAGE_ONE, REPAIR_STAGE_TWO, REPAIR_STAGE_THREE))
				play_repair_vfx("sewrepair_[stage]", 0.7 SECONDS)
				addtimer(CALLBACK(src, PROC_REF(play_repair_sfx), stage, repair_type), 0.2 SECONDS)
		if(REPAIR_TYPE_HAMMER)
			switch(stage)
				if(REPAIR_STAGE_ONE)
					play_repair_vfx("hamrepair_1", 0.9 SECONDS)
					addtimer(CALLBACK(src, PROC_REF(play_repair_sfx), stage, repair_type), 0.5 SECONDS)
				if(REPAIR_STAGE_TWO)
					play_repair_vfx("hamrepair_2", 0.8 SECONDS)
					addtimer(CALLBACK(src, PROC_REF(play_repair_sfx), stage, repair_type), 0.4 SECONDS)
				if(REPAIR_STAGE_THREE)
					playsound(src, 'sound/repair/hammer_windup.ogg', 100, TRUE)
					play_repair_vfx("hamrepair_3", 0.8 SECONDS)
					addtimer(CALLBACK(src, PROC_REF(play_repair_sfx), stage, repair_type), 0.3 SECONDS)
	switch(stage)
		if(REPAIR_STAGE_FINAL)
			play_repair_vfx("repair_perfect", 0.8 SECONDS)
			play_repair_sfx(stage)
		if(REPAIR_STAGE_DING)
			play_repair_vfx("repair_bling", 0.8 SECONDS)
			play_repair_sfx(stage)
		if(REPAIR_STAGE_INTEGLOSS)
			play_repair_vfx("integloss[prob(50) ? "_2" : ""]", 0.6 SECONDS)
			play_repair_sfx(stage, repair_type)

/obj/item/proc/play_repair_sfx(stage, repair_type)
	var/sfx
	if(stage == REPAIR_STAGE_FINAL || stage == REPAIR_STAGE_DING)
		sfx = pick('sound/repair/repair_perfect_1.ogg', 'sound/repair/repair_perfect_2.ogg', 'sound/repair/repair_perfect_3.ogg')
	else if(repair_type == REPAIR_TYPE_SEW)
		switch(stage)
			if(REPAIR_STAGE_ONE)
				sfx = 'sound/repair/sew_repair_novice.ogg'
			if(REPAIR_STAGE_TWO)
				sfx = 'sound/repair/sew_repair_apprentice.ogg'
			if(REPAIR_STAGE_THREE)
				sfx = 'sound/repair/sew_repair_expert.ogg'
			if(REPAIR_STAGE_INTEGLOSS)
				sfx = pick('sound/repair/leather_integloss_1.ogg', 'sound/repair/leather_integloss_2.ogg', 'sound/repair/leather_integloss_3.ogg', 'sound/repair/leather_integloss_4.ogg')
	else if(repair_type == REPAIR_TYPE_HAMMER)
		switch(stage)
			if(REPAIR_STAGE_ONE)
				sfx = 'sound/repair/hammer_novice_1.ogg'
			if(REPAIR_STAGE_TWO)
				sfx = 'sound/repair/hammer_apprentice_1.ogg'
			if(REPAIR_STAGE_THREE)
				sfx = 'sound/repair/hammer_expert_1.ogg'
			if(REPAIR_STAGE_INTEGLOSS)
				sfx = pick('sound/repair/metal_integloss_1.ogg', 'sound/repair/metal_integloss_2.ogg')
	if(sfx)
		playsound(src, sfx, 100, TRUE)

// ---------------- Expedient repair ----------------

/// `src` is the tool. Returns the integrity repaired.
/obj/item/proc/do_special_repair(obj/item/attacked_item, mob/living/user, repair_type)
	var/skill = (repair_type == REPAIR_TYPE_SEW) ? attacked_item.sewrepair : attacked_item.anvilrepair
	if(!skill || repair_busy)
		return 0
	if(attacked_item.get_integrity() >= attacked_item.max_integrity)
		return 0

	repair_busy = TRUE
	var/user_skill = repair_skill_level(user, skill)
	var/stage_count = min(user_skill, REPAIR_STAGE_FINAL)

	// Only clothing and armor wear down; weapons have their own attrition.
	var/integ_decay = isclothing(attacked_item) ? (attacked_item.max_integrity * 0.02) : 0

	user.visible_message(span_notice("[user] is preparing to repair [attacked_item]..."), span_notice("I am preparing to repair [attacked_item], I should remain still."))
	if(!do_after(user, 3 SECONDS - (user_skill * (1 SECONDS / 6)), attacked_item))
		repair_busy = FALSE
		return 0

	var/repair_percent = 0.2
	var/maxclamp = 60
	switch(stage_count)
		if(REPAIR_STAGE_ONE)
			repair_percent = 0.25
			maxclamp = 75
		if(REPAIR_STAGE_TWO)
			repair_percent = 0.34
			maxclamp = 100
		if(REPAIR_STAGE_THREE)
			repair_percent = 0.5
			maxclamp = 200
		if(REPAIR_STAGE_FINAL)
			repair_percent = 1
			maxclamp = 999
	var/repaired_integ = min(attacked_item.max_integrity * repair_percent, maxclamp)

	// Will the max integrity survive this repair?
	var/fortune = GET_MOB_ATTRIBUTE_VALUE(user, STAT_FORTUNE)
	var/intel = GET_MOB_ATTRIBUTE_VALUE(user, STAT_INTELLIGENCE)
	var/keep_lucky = prob(max(0, ((fortune - 10) * 10) + ((intel - 10) * 3) + (stage_count * 15))) // makes a 'Ding!'
	var/keep_quiet = FALSE // a reliable circumstance: no 'Ding!'
	var/reason = ""

	if(isclothing(attacked_item))
		var/obj/item/clothing/C = attacked_item
		if(repair_type == REPAIR_TYPE_SEW && C.armor_class == AC_LIGHT && HAS_TRAIT(user, TRAIT_DODGEEXPERT))
			reason = "I know this kind of armor well."
			keep_quiet = TRUE
		else if(repair_type == REPAIR_TYPE_HAMMER && ((C.armor_class == AC_MEDIUM && HAS_TRAIT(user, TRAIT_MEDIUMARMOR)) || (C.armor_class == AC_HEAVY && HAS_TRAIT(user, TRAIT_HEAVYARMOR))))
			reason = "I know this kind of armor well."
			keep_quiet = TRUE
	if(repair_type == REPAIR_TYPE_SEW && ((locate(/obj/structure/table/wood/fancy) in attacked_item.loc) || (locate(/obj/structure/table/wood/folding) in attacked_item.loc)))
		reason = "The work surface was favorable."
		keep_quiet = TRUE
	if(repair_type == REPAIR_TYPE_HAMMER && (istype(attacked_item.loc, /obj/machinery/anvil) || (locate(/obj/machinery/anvil) in attacked_item.loc)))
		reason = "The anvil made it easy."
		keep_quiet = TRUE
	if(!integ_decay)
		keep_quiet = TRUE
	if((attacked_item.get_integrity() / attacked_item.max_integrity) >= 0.9)
		reason = "The damage was not severe enough."
		keep_quiet = TRUE
	if(keep_lucky && !keep_quiet)
		reason = "I got lucky!"
	if(stage_count == REPAIR_STAGE_FINAL) // Experts restore the max integrity anyway
		keep_lucky = FALSE
		keep_quiet = FALSE

	var/root_mult = (repair_type == REPAIR_TYPE_SEW) ? 0.7 SECONDS : 0.8 SECONDS
	var/root_time = root_mult * stage_count
	if(stage_count)
		user.Immobilize(root_time)
		user.changeNext_move(root_time)
		for(var/i in 1 to stage_count)
			if(!attacked_item.repair_effect_check(user))
				break
			if(i == 1)
				attacked_item.perform_repair_effect(user, i, repair_type)
			else if(do_after(user, root_mult, attacked_item, progress = FALSE))
				attacked_item.perform_repair_effect(user, i, repair_type)
			else
				break
	else if(repair_type == REPAIR_TYPE_SEW)
		playsound(get_turf(attacked_item), 'sound/foley/sewflesh.ogg', 100, TRUE, -2)
	else
		playsound(get_turf(attacked_item), pick('sound/repair/hammer_noskill_1.ogg', 'sound/repair/hammer_noskill_2.ogg', 'sound/repair/hammer_noskill_3.ogg'), 100, TRUE)

	if(!attacked_item.repair_effect_check(user))
		repair_busy = FALSE
		return 0

	var/keep_integ = keep_lucky || keep_quiet
	if(stage_count < REPAIR_STAGE_FINAL)
		if(keep_lucky && !keep_quiet)
			attacked_item.perform_repair_effect(user, REPAIR_STAGE_DING, repair_type)
		else if(!keep_integ)
			addtimer(CALLBACK(attacked_item, PROC_REF(perform_repair_effect), user, REPAIR_STAGE_INTEGLOSS, repair_type), 0.4 SECONDS)

	. = finalize_repair(attacked_item, user, skill, stage_count, repaired_integ, keep_integ, integ_decay, reason)
	repair_busy = FALSE

/obj/item/proc/finalize_repair(obj/item/attacked_item, mob/living/user, skill, stage_count, repaired_integ, keep_integ, integ_decay, reason)
	if(!keep_integ && stage_count != REPAIR_STAGE_FINAL && integ_decay)
		if(!attacked_item.true_max_integrity)
			attacked_item.true_max_integrity = attacked_item.max_integrity
		attacked_item.max_integrity = max(1, attacked_item.max_integrity - integ_decay)
		if(attacked_item.get_integrity() > attacked_item.max_integrity)
			attacked_item.update_integrity(attacked_item.max_integrity)

	var/before = attacked_item.get_integrity()
	attacked_item.repair_damage(repaired_integ)
	var/actual = attacked_item.get_integrity() - before

	var/result
	if(stage_count == REPAIR_STAGE_FINAL)
		result = "It's done perfectly!"
	else if(keep_integ)
		result = "It's left the same."
	else
		result = "It wears down a little bit."
	user.visible_message(span_info("[user] repairs [attacked_item]! [result]"), span_info("I repair [attacked_item]! [result][reason ? " ([reason])" : ""]"))

	if(attacked_item.obj_broken && attacked_item.get_integrity() >= attacked_item.max_integrity)
		attacked_item.atom_fix()

	if(stage_count == REPAIR_STAGE_FINAL)
		attacked_item.perform_repair_effect(user, REPAIR_STAGE_FINAL, REPAIR_TYPE_SEW)
		attacked_item.restore_max_integ()

	user.mind?.add_sleep_experience(skill, GET_MOB_ATTRIBUTE_VALUE(user, STAT_INTELLIGENCE) * 0.25 * (1 + stage_count))
	return actual

// ---------------- Safe repair ----------------

/obj/item/proc/do_safe_repair(obj/item/attacked_item, mob/living/user, repair_type)
	var/skill = (repair_type == REPAIR_TYPE_SEW) ? attacked_item.sewrepair : attacked_item.anvilrepair
	if(!skill || repair_busy)
		return
	if(attacked_item.get_integrity() >= attacked_item.max_integrity)
		return
	repair_busy = TRUE
	var/per_step = max(0.5, repair_skill_level(user, skill)) * (attacked_item.max_integrity * 0.01)
	while(attacked_item.get_integrity() < attacked_item.max_integrity)
		if(!do_after(user, 1.1 SECONDS, attacked_item))
			break
		attacked_item.repair_damage(per_step)
		user.visible_message(span_info("[user] slowly and steadily repairs [attacked_item]..."))
		user.mind?.add_sleep_experience(skill, GET_MOB_ATTRIBUTE_VALUE(user, STAT_INTELLIGENCE) * 0.1)
		if(repair_type == REPAIR_TYPE_SEW)
			playsound(get_turf(attacked_item), 'sound/foley/sewflesh.ogg', 100, TRUE, -2)
		else
			playsound(get_turf(attacked_item), pick('sound/repair/hammer_repair_simple_1.ogg', 'sound/repair/hammer_repair_simple_2.ogg', 'sound/repair/hammer_repair_simple_3.ogg', 'sound/repair/hammer_repair_simple_4.ogg', 'sound/repair/hammer_repair_simple_5.ogg'), 100, TRUE)
	if(attacked_item.obj_broken && attacked_item.get_integrity() >= attacked_item.max_integrity)
		attacked_item.atom_fix()
	repair_busy = FALSE

/obj/item/proc/toggle_repair_method(mob/user)
	if(repair_method == REPAIR_METHOD_EXPEDIENT)
		repair_method = REPAIR_METHOD_SAFE
		to_chat(user, span_notice("I will now repair slowly and safely."))
	else
		repair_method = REPAIR_METHOD_EXPEDIENT
		to_chat(user, span_notice("I will now repair with great speed, but risk wearing the item down slightly."))
	user.playsound_local(get_turf(user), 'sound/misc/click.ogg', 100, TRUE)

/obj/item/proc/repair_method_examine()
	if(repair_method == REPAIR_METHOD_EXPEDIENT)
		return span_notice("It is set to repair quickly, with some risk. Use it in hand to change this.")
	return span_notice("It is set to repair slowly, but safely. Use it in hand to change this.")

// ---------------- Hammer ----------------

/obj/item/weapon/hammer/attack_self(mob/user, list/modifiers)
	if(force_wielded) // sledgehammers keep their normal use
		return ..()
	toggle_repair_method(user)
	return TRUE

/obj/item/weapon/hammer/examine(mob/user)
	. = ..()
	if(!force_wielded)
		. += repair_method_examine()

/obj/item/weapon/hammer/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isitem(interacting_with) || isbodypart(interacting_with) || !isliving(user) || !user.mind || user.cmode)
		return ..()
	var/obj/item/attacked_item = interacting_with
	if(!attacked_item.anvilrepair || !attacked_item.max_integrity)
		return ..()
	if(!attacked_item.on_repair_surface())
		to_chat(user, span_warning("I should put [attacked_item] on a table or an anvil first."))
		return ITEM_INTERACT_BLOCKING
	if(attacked_item.get_integrity() >= attacked_item.max_integrity)
		to_chat(user, span_warning("There is nothing to further repair on [attacked_item]."))
		return ITEM_INTERACT_BLOCKING
	if(repair_method == REPAIR_METHOD_SAFE)
		do_safe_repair(attacked_item, user, REPAIR_TYPE_HAMMER)
		return ITEM_INTERACT_SUCCESS
	var/repaired = do_special_repair(attacked_item, user, REPAIR_TYPE_HAMMER)
	if(repaired && uses_integrity && max_integrity) // fast repairs wear the hammer a little
		var/before = get_integrity() / max_integrity
		take_damage(floor(repaired / 25), BRUTE)
		var/after = get_integrity() / max_integrity
		if(before > 0.5 && after <= 0.5)
			balloon_alert(user, "hammer chips...")
		if(before > 0.25 && after <= 0.25)
			balloon_alert(user, "hammer breaking!")
	return ITEM_INTERACT_SUCCESS

// ---------------- Needle ----------------

/obj/item/needle
	/// Integrity repaired before one strand of thread is used up
	var/repair_integ_per_use = 300

/obj/item/needle/attack_self(mob/user, list/modifiers)
	toggle_repair_method(user)
	return TRUE

/obj/item/needle/examine(mob/user)
	. = ..()
	if(can_repair)
		. += repair_method_examine()

/obj/item/needle/sew_item(obj/item/I, mob/living/user)
	if(!(I.obj_flags & CAN_BE_HIT) && !istype(I, /obj/item/storage))
		return NONE
	if(!I.ontable() || !I.sewrepair)
		return NONE
	if(!I.uses_integrity)
		to_chat(user, span_warning("[I] can't be repaired!"))
		return NONE
	if(stringamt < 1 && !infinite)
		to_chat(user, span_warning("[src] has no thread left!"))
		return ITEM_INTERACT_BLOCKING
	if(!can_repair)
		to_chat(user, span_warning("[src] cannot be used to repair [I]!"))
		return ITEM_INTERACT_BLOCKING
	if(I.get_integrity() >= I.max_integrity)
		to_chat(user, span_warning("There is nothing to further repair on [I]."))
		return NONE
	if(repair_method == REPAIR_METHOD_SAFE)
		do_safe_repair(I, user, REPAIR_TYPE_SEW)
		if(prob(25))
			use(1)
		return ITEM_INTERACT_SUCCESS
	var/repaired = do_special_repair(I, user, REPAIR_TYPE_SEW)
	if(repaired)
		use_for_repairs(repaired, user)
	return ITEM_INTERACT_SUCCESS

/obj/item/needle/proc/use_for_repairs(integ, mob/living/user)
	if(!integ || infinite)
		return
	repair_integ_per_use -= integ
	while(repair_integ_per_use <= 0 && stringamt > 0)
		repair_integ_per_use += initial(repair_integ_per_use)
		use(1)
		balloon_alert(user, stringamt > 0 ? "thread used..." : "thread used up!")

// ---------------- Repair kits: they now only restore lost max integrity ----------------

/obj/item/repair_kit/attack_atom(atom/attacked_atom, mob/living/user)
	if(!isclothing(attacked_atom) || !isliving(user) || !user.mind || user.cmode)
		return ..()
	. = TRUE
	var/obj/item/attacked_item = attacked_atom
	if(for_armor && attacked_item.sewrepair && !attacked_item.anvilrepair)
		to_chat(user, span_warning("[src] is only for armor!"))
		return
	if(for_clothing && attacked_item.anvilrepair && !attacked_item.sewrepair)
		to_chat(user, span_warning("[src] is only for clothing!"))
		return
	if(attacked_item.get_integrity() < attacked_item.max_integrity)
		to_chat(user, span_warning("[attacked_item] needs to be repaired first."))
		return
	if(!attacked_item.has_lost_max_integ())
		to_chat(user, span_warning("[attacked_item] is already in top shape."))
		return
	if(!attacked_item.ontable())
		to_chat(user, span_warning("I should put [attacked_item] on a table first."))
		return
	playsound(loc, attacked_item.anvilrepair ? 'sound/repair/ameliorate_metal.ogg' : 'sound/repair/ameliorate_leather.ogg', 100, TRUE, -2)
	if(!do_after(user, 2 SECONDS, attacked_item))
		return
	attacked_item.restore_max_integ()
	user.visible_message(span_info("[user] restores [attacked_item] to its full strength with [src]."))
	amount_repair -= 1
	if(amount_repair <= 0)
		to_chat(user, span_warning("There is nothing left of [src]."))
		qdel(src)

// ---------------- Examine ----------------

/obj/item/clothing/examine(mob/user)
	. = ..()
	if(has_lost_max_integ())
		. += span_warning("It has lost some of its strength to hasty repairs. An Expert's repair, a repair kit or an Ameliorate can restore it.")

// ---------------- The Ameliorate ----------------

/obj/machinery/ameliorate
	name = "ameliorate"
	desc = "A mixture of artifice and smithing, made easy enough to use for anyone. It clears up the dents and small tears left \
	in armor by hasty repairs, restoring its full strength.\n\n<b>Place fully repaired armor on it and work it with an empty hand.</b>"
	icon = 'modular_rmh/icons/obj/ameliorate.dmi'
	icon_state = "ameliorate"
	max_integrity = 300
	density = TRUE
	anchored = TRUE
	var/in_use = FALSE

/obj/machinery/ameliorate/attackby(obj/item/I, mob/living/user, params)
	if(user.cmode || (I.item_flags & ABSTRACT))
		return ..()
	if(in_use)
		to_chat(user, span_warning("It's currently being used!"))
		return TRUE
	user.transferItemToLoc(I, drop_location(), silent = FALSE)
	return TRUE

/obj/machinery/ameliorate/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(in_use)
		return
	var/found = FALSE
	for(var/obj/item/I in loc)
		if(!isclothing(I))
			continue
		found = TRUE
		if(I.get_integrity() < I.max_integrity)
			to_chat(user, span_warning("[I] still needs repairs before being ameliorated!"))
			continue
		if(!I.has_lost_max_integ())
			to_chat(user, span_warning("[I] does not need any amelioration. It is fine."))
			continue
		in_use = TRUE
		playsound(src, I.anvilrepair ? 'sound/repair/ameliorate_metal.ogg' : 'sound/repair/ameliorate_leather.ogg', 100, TRUE)
		if(!do_after(user, 1 SECONDS, src))
			break
		I.restore_max_integ()
		visible_message(span_info("<b>[I] gets ameliorated and restored to its full strength!</b>"))
	in_use = FALSE
	if(!found)
		to_chat(user, span_warning("There is no armor or clothing on [src]."))

/datum/blueprint_recipe/structure/ameliorate
	name = "Ameliorate"
	desc = "A smithing workstation anyone can use to restore armor worn down by hasty repairs."
	result_type = /obj/machinery/ameliorate
	required_materials = list(
		/obj/item/ingot/iron = 2,
		/obj/item/ingot/steel = 1,
	)
	construct_tool = /obj/item/weapon/hammer
	skillcraft = /datum/attribute/skill/craft/blacksmithing
	craftdiff = 2
	build_time = 6 SECONDS
	category = "Structures"

#undef REPAIR_TYPE_SEW
#undef REPAIR_TYPE_HAMMER
#undef REPAIR_METHOD_EXPEDIENT
#undef REPAIR_METHOD_SAFE
#undef REPAIR_STAGE_ONE
#undef REPAIR_STAGE_TWO
#undef REPAIR_STAGE_THREE
#undef REPAIR_STAGE_FINAL
#undef REPAIR_STAGE_DING
#undef REPAIR_STAGE_INTEGLOSS
