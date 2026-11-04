/obj/item/broom
	item_weight = 548 GRAMS
	name = "broom"
	desc = "A broom, made from a bundle of twigs. Sweeps dirt, blood, ash, glass and debris off the floor."
	icon = 'icons/roguetown/weapons/tools.dmi'
	icon_state = "broom"
	possible_item_intents = list(/datum/intent/use)
	gripped_intents = list(/datum/intent/use, /datum/intent/mace/strike/wood)
	force = 2
	throwforce = 1
	firefuel = 10 MINUTES
	resistance_flags = FLAMMABLE
	slot_flags = ITEM_SLOT_BACK
	smeltresult = /obj/item/fertilizer/ash

/obj/item/broom/apply_components()
	AddElement(/datum/element/walking_stick)
	AddComponent(/datum/component/two_handed, force_unwielded=2, force_wielded=4, wield_callback = CALLBACK(src, PROC_REF(on_wield)), unwield_callback = CALLBACK(src, PROC_REF(on_unwield)))

/obj/item/broom/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list("shrink" = 0.6,"sx" = -6,"sy" = -1,"nx" = 8,"ny" = 0,"wx" = -4,"wy" = 0,"ex" = 2,"ey" = 1,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = -38,"sturn" = 37,"wturn" = 32,"eturn" = -23,"nflip" = 0,"sflip" = 8,"wflip" = 8,"eflip" = 0)
			if("wielded")
				return list("shrink" = 0.6,"sx" = 4,"sy" = -2,"nx" = -3,"ny" = -2,"wx" = -5,"wy" = -1,"ex" = 3,"ey" = -2,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 7,"sturn" = -7,"wturn" = 16,"eturn" = -22,"nflip" = 8,"sflip" = 0,"wflip" = 8,"eflip" = 0)
			if("onback")
				return list("shrink" = 0.5,"sx" = -1,"sy" = 2,"nx" = 0,"ny" = 2,"wx" = 2,"wy" = 1,"ex" = 0,"ey" = 1,"nturn" = 0,"sturn" = 0,"wturn" = 70,"eturn" = 15,"nflip" = 1,"sflip" = 1,"wflip" = 1,"eflip" = 1,"northabove" = 1,"southabove" = 0,"eastabove" = 0,"westabove" = 0)

/**
 * Handles registering the sweep proc when the broom is wielded
 *
 * Arguments:
 * * source - The source of the on_wield proc call
 * * user - The user which is wielding the broom
 */
/obj/item/broom/on_wield(obj/item/source, mob/user)
	. = ..()
	to_chat(user, span_notice("You brace the [src] against the ground in a firm sweeping stance."))
	RegisterSignal(user, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(walk_sweep))

/**
 * Handles unregistering the sweep proc when the broom is unwielded
 *
 * Arguments:
 * * source - The source of the on_unwield proc call
 * * user - The user which is unwielding the broom
 */
/obj/item/broom/on_unwield(obj/item/source, mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_MOVABLE_PRE_MOVE)

// RMH EDIT START: sweeping ported from Azure Peak

/obj/item/broom
	/// A strong (3x3) sweep is under way
	var/sweeping = FALSE

/obj/item/broom/get_mechanics_examine(mob/user)
	. = ..()
	. += span_info("Click the floor with the USE intent to sweep it. Sweeping is faster with higher Cooking skill.")
	. += span_info("With the STRONG right-click intent you sweep the whole 3x3 area around that tile, gathering the clutter into its center.")
	. += span_info("Wield it and walk to sweep the tiles you step off.")

/obj/item/broom/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(user.cmode || !istype(user.used_intent, /datum/intent/use))
		return NONE
	if(istype(interacting_with, /obj/structure/spider/stickyweb))
		interacting_with.take_damage(200, BRUTE, "blunt", FALSE)
		playsound(loc, "smashlimb", 50, FALSE)
		return ITEM_INTERACT_SUCCESS
	var/turf/target_turf = get_turf(interacting_with)
	if(!isopenturf(target_turf) || istype(target_turf, /turf/open/water) || istype(target_turf, /turf/open/lava))
		return NONE
	if(istype(user.rmb_intent, /datum/rmb_intent/strong))
		INVOKE_ASYNC(src, PROC_REF(sweep_strong), target_turf, user)
		return ITEM_INTERACT_SUCCESS
	INVOKE_ASYNC(src, PROC_REF(sweep_tile), target_turf, user)
	return ITEM_INTERACT_SUCCESS

/// Deciseconds one sweep takes; faster with Cooking skill
/obj/item/broom/proc/sweep_time(mob/living/user)
	return max(40 - (GET_MOB_SKILL_VALUE_OLD(user, /datum/attribute/skill/craft/cooking) * 15), 5)

/obj/item/broom/proc/sweep_alive(mob/living/user)
	return !QDELETED(user) && user.stat == CONSCIOUS

/obj/item/broom/proc/sweep_tile(turf/target_turf, mob/living/user)
	if(!do_after(user, sweep_time(user), target = target_turf))
		return
	perform_sweep(target_turf, user, target_turf)

/// Swept away for good
/obj/item/broom/proc/is_sweep_trash(obj/thing)
	return istype(thing, /obj/effect/decal/cleanable/dirt) \
		|| istype(thing, /obj/effect/decal/cleanable/debris) \
		|| istype(thing, /obj/effect/decal/remains/human) \
		|| istype(thing, /obj/item/paper/crumpled) \
		|| istype(thing, /obj/item/fertilizer/ash) \
		|| istype(thing, /obj/item/natural/glass/shard)

/// Gathered into the center tile by a strong sweep
/obj/item/broom/proc/is_clutter(atom/movable/thing)
	return istype(thing, /obj/item/natural/stone) \
		|| istype(thing, /obj/item/paper/crumpled) \
		|| istype(thing, /obj/item/grown/log/tree/stick) \
		|| istype(thing, /obj/item/fertilizer/ash) \
		|| istype(thing, /obj/item/organ) \
		|| istype(thing, /obj/item/bodypart) \
		|| istype(thing, /obj/item/natural/glass/shard) \
		|| istype(thing, /obj/item/natural/cloth) \
		|| istype(thing, /obj/item/natural/fibers) \
		|| istype(thing, /obj/item/natural/silk) \
		|| istype(thing, /obj/item/alch/bone) \
		|| istype(thing, /obj/item/natural/bundle) \
		|| istype(thing, /obj/item/ammo_casing)

/obj/item/broom/proc/sweep_strong(turf/center, mob/living/user)
	if(!center || !sweep_alive(user) || sweeping)
		return
	sweeping = TRUE
	var/list/tiles = list()
	for(var/turf/open/tile in range(1, center))
		if(tile == center || istype(tile, /turf/open/lava) || istype(tile, /turf/open/water))
			continue
		tiles += tile
	// Sweep each surrounding tile in a random order, then come back to the center
	while(length(tiles))
		var/turf/tile = pick_n_take(tiles)
		if(!move_to_sweep(tile, user) || !do_after(user, sweep_time(user), target = tile) || !sweep_alive(user))
			sweeping = FALSE
			return
		perform_sweep(tile, user, center)
	if(move_to_sweep(center, user) && do_after(user, sweep_time(user), target = center) && sweep_alive(user))
		perform_sweep(center, user, center)
	sweeping = FALSE

/obj/item/broom/proc/move_to_sweep(turf/target, mob/living/user)
	var/stuck = 0
	while(user.loc != target)
		if(!sweep_alive(user))
			return FALSE
		var/turf/old_turf = get_turf(user)
		step_to(user, target)
		sleep(1)
		if(get_turf(user) != old_turf)
			playsound(user, "clothwipe", 100, TRUE)
			stuck = 0
			continue
		if(++stuck >= 2)
			return FALSE
	return TRUE

/obj/item/broom/proc/perform_sweep(turf/target_turf, mob/living/user, turf/center)
	user.visible_message(span_notice("[user] dutifully sweeps \the [target_turf]."), span_notice("I dutifully sweep \the [target_turf]."))
	sweep_smoke(target_turf)
	playsound(user, "clothwipe", 100, TRUE)
	gather_clutter(target_turf, user, center)
	clean_turf(target_turf)
	user.nobles_seen_servant_work()

/// Removes trash and washes blood and grime off the tile
/obj/item/broom/proc/clean_turf(turf/target_turf)
	if(!target_turf)
		return
	for(var/obj/thing in target_turf.contents)
		if(thing.loc == target_turf && is_sweep_trash(thing))
			qdel(thing)
	target_turf.wash(CLEAN_WASH)
	for(var/obj/effect/decal/cleanable/stain in target_turf)
		stain.wash(CLEAN_WASH)

/obj/item/broom/proc/gather_clutter(turf/target_turf, mob/living/user, turf/center)
	if(!target_turf || !center || target_turf == center)
		return
	var/moved = 0
	for(var/atom/movable/thing in target_turf)
		if(moved >= 10)
			break
		if(QDELETED(thing) || thing.anchored || !is_clutter(thing))
			continue
		thing.forceMove(center)
		moved++
	if(moved)
		user.visible_message(span_notice("[user] gathers the clutter into \the [center]."), span_notice("I gather the clutter into \the [center]."))

/obj/item/broom/proc/sweep_smoke(turf/target_turf)
	if(!target_turf)
		return
	new /obj/effect/temp_visual/broom_sparkles(target_turf)
	var/matrix/small = matrix()
	small.Scale(0.3, 0.3)
	for(var/side in list(-1, 1))
		var/obj/effect/temp_visual/broom_dust/dust = new(target_turf)
		dust.transform = small
		animate(dust, pixel_x = 12 * side, pixel_y = 6, transform = matrix(), time = 4, easing = EASE_OUT)
		animate(pixel_x = 24 * side, pixel_y = 0, alpha = 0, transform = matrix() * 1.15, time = 4, easing = SINE_EASING)

/obj/effect/temp_visual/broom_sparkles
	icon = 'icons/effects/effects.dmi'
	icon_state = "shieldsparkles"
	duration = 2 SECONDS

/obj/effect/temp_visual/broom_sparkles/Initialize(mapload)
	. = ..()
	animate(src, alpha = 0, time = 2 SECONDS)

/obj/effect/temp_visual/broom_dust
	icon = 'icons/effects/effects.dmi'
	icon_state = "smoke"
	duration = 0.8 SECONDS

/// Walking with the broom wielded sweeps the tile we step off, without the wait
/obj/item/broom/proc/walk_sweep(mob/living/user)
	SIGNAL_HANDLER
	var/turf/old_turf = get_turf(user)
	if(!old_turf || user.cmode)
		return
	var/found = FALSE
	for(var/obj/thing in old_turf)
		if(is_sweep_trash(thing))
			found = TRUE
			break
	if(!found && !(locate(/obj/effect/decal/cleanable) in old_turf))
		return
	clean_turf(old_turf)
	playsound(user, "clothwipe", 60, TRUE)
	user.nobles_seen_servant_work()
// RMH EDIT END
