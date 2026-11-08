// RMH EDIT: the Ironclad's tools.
// - Giant's Might (TRAIT_GIANT_MIGHT): kicks and shoves send people a tile further, shoves land more often,
//   and a fully charged smash sends the target flying - a giant's strength without the giant's size.
// - Immovable (TRAIT_IMMOVABLE): can't be knocked down by being kicked or shoved into things, nor by being
//   kicked while exhausted.
// - Charge: a 5 tile rush in the facing direction that shoves everyone in the way aside.

#define CHARGE_DISTANCE 5

/datum/action/cooldown/spell/undirected/ironclad_charge
	name = "Charge"
	desc = "Lower your shoulder and rush up to 5 tiles ahead, shoving aside everyone in your way. \
	Those who can't be moved stop you."
	button_icon_state = "bcry"
	sound = 'sound/combat/shove.ogg'

	antimagic_flags = NONE

	associated_skill = /datum/attribute/skill/misc/athletics
	associated_stat = STAT_STRENGTH

	charge_required = FALSE
	has_visual_effects = FALSE
	cooldown_time = 30 SECONDS
	spell_type = SPELL_STAMINA
	spell_cost = 30

/datum/action/cooldown/spell/undirected/ironclad_charge/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return
	var/mob/living/L = owner
	if(!isliving(L) || L.body_position == LYING_DOWN || L.buckled || L.incapacitated(IGNORE_GRAB))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/undirected/ironclad_charge/cast(mob/living/cast_on)
	. = ..()
	cast_on.visible_message(span_danger("[cast_on] lowers [cast_on.p_their()] shoulder and charges!"), span_danger("I charge!"))
	INVOKE_ASYNC(src, PROC_REF(do_charge), cast_on, cast_on.dir)

/datum/action/cooldown/spell/undirected/ironclad_charge/proc/do_charge(mob/living/charger, charge_dir)
	for(var/i in 1 to CHARGE_DISTANCE)
		if(QDELETED(charger) || charger.stat || charger.body_position == LYING_DOWN)
			return
		var/turf/next = get_step(charger, charge_dir)
		if(!next || next.density)
			break
		for(var/mob/living/victim in next)
			if(victim == charger || victim.stat == DEAD)
				continue
			shove_aside(charger, victim, next, charge_dir)
		var/turf/before = get_turf(charger)
		charger.Move(next, charge_dir)
		if(get_turf(charger) == before) // something held fast
			break
		new /obj/effect/temp_visual/decoy/fading/halfsecond(before, charger)
		sleep(1)
	if(!QDELETED(charger))
		charger.changeNext_move(CLICK_CD_MELEE)

/datum/action/cooldown/spell/undirected/ironclad_charge/proc/shove_aside(mob/living/charger, mob/living/victim, turf/at, charge_dir)
	playsound(victim, 'sound/combat/shove.ogg', 80, TRUE)
	if(HAS_TRAIT(victim, TRAIT_IMMOVABLE))
		victim.visible_message(span_warning("[victim] doesn't budge as [charger] slams into [victim.p_them()]!"))
		return
	var/list/escape_dirs = list(turn(charge_dir, 90), turn(charge_dir, -90), charge_dir)
	if(prob(50))
		escape_dirs.Swap(1, 2)
	for(var/push_dir in escape_dirs)
		var/turf/dest = get_step(at, push_dir)
		if(!dest || dest.density)
			continue
		victim.Move(dest, push_dir)
		if(get_turf(victim) != at)
			break
	victim.OffBalance(2 SECONDS)
	victim.visible_message(span_danger("[charger] barrels into [victim], shoving [victim.p_them()] aside!"), span_userdanger("[charger] barrels into me!"))
	log_combat(charger, victim, "charged into")

#undef CHARGE_DISTANCE

/// RMH EDIT: Giant's Might - a fully charged smash sends the target flying
/mob/living/proc/giant_smash_launch(mob/living/user, obj/item/weapon)
	if(!user || !weapon || !HAS_TRAIT(user, TRAIT_GIANT_MIGHT) || stat == DEAD || user == src)
		return
	var/datum/intent/used = user.used_intent
	if(!used || used.blade_class != BCLASS_SMASH)
		return
	if(used.get_chargetime() && user.client?.chargedprog < 100) // charged intents must be fully wound up
		return
	if(HAS_TRAIT(src, TRAIT_IMMOVABLE) || mob_size >= MOB_SIZE_LARGE || anchored || buckled)
		return
	var/tiles = clamp(3 + floor((GET_MOB_ATTRIBUTE_VALUE(user, STAT_STRENGTH) - 10) / 2), 2, 6)
	var/turf/edge = get_edge_target_turf(src, get_dir(user, src))
	if(!istype(edge))
		return
	visible_message(span_danger("[user]'s smash sends [src] flying!"), span_userdanger("[user]'s smash sends me flying!"))
	safe_throw_at(edge, tiles, 2, user, spin = FALSE, force = move_force, callback = CALLBACK(src, TYPE_PROC_REF(/mob/living, handle_knockback), get_turf(src)))
