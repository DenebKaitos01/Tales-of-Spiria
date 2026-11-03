//By DREAMKEEP, Vide Noir https://github.com/EaglePhntm.
//GRAPHICS & SOUNDS INCLUDED:
//DARKEST DUNGEON (STRESS, RELIEF, AFFLICTION)
/**
 * Show an appearance over the head of this mob.
 *
 * Arguments
 * * icon - icon file to use.
 * * icon_state - icon_state to use.
 * * duration - how long to show the icon for.
 * * layer - layer to use.
 * * public - If True all clients can see the icon.
 * * sound - If set, play this when we show the icon.
 * * can_see_cb - Callback to test if someone can see and hear even if not public.
 */
/mob/living/proc/show_overhead_indicator(icon, icon_state, duration, layer = ABOVE_ALL_MOB_LAYER, plane = FLOAT_PLANE, y_offset = 12, public = FALSE, sound = null, datum/callback/can_see_cb = null)
	if(!icon_exists_or_scream(icon, icon_state))
		return

	var/mutable_appearance/appearance = mutable_appearance(icon, icon_state, layer, plane, appearance_flags = RESET_COLOR)
	appearance.pixel_y = y_offset

	if(public && sound)
		playsound(src, sound, 15, FALSE, extrarange = -1, ignore_walls = FALSE)
	else if(sound)
		playsound_local(src, sound, 15, FALSE)

	if(client)
		flick_overlay(appearance, client, duration)

	for(var/mob/viewer as anything in viewers(src))
		var/client/client = viewer.client
		if(!client)
			continue
		if(public)
			flick_overlay(appearance, client, duration)
		else if(can_see_cb)
			var/can_see = can_see_cb.Invoke(src, viewer)
			if(can_see)
				playsound_local(viewer, sound, 15, FALSE)
				flick_overlay(appearance, client, duration)

/mob/living/carbon/human/show_overhead_indicator(icon, icon_state, duration = 3 SECONDS, layer = ABOVE_ALL_MOB_LAYER, y_offset = 12, public = FALSE, sound = null, datum/callback/can_see_cb = null)
	if(!icon_exists_or_scream(icon, icon_state))
		return

	var/mutable_appearance/appearance = mutable_appearance(icon, icon_state, layer, appearance_flags = RESET_COLOR)
	appearance.pixel_y = y_offset
	apply_offset(appearance, OFFSET_HEAD)

	if(public && sound)
		playsound(src, sound, 15, FALSE, extrarange = -1, ignore_walls = FALSE)
	else if(sound)
		playsound_local(src, sound, 15, FALSE)

	if(client)
		flick_overlay(appearance, client, duration)

	for(var/mob/viewer as anything in viewers(src))
		var/client/client = viewer.client
		if(!client)
			continue
		if(public)
			flick_overlay(appearance, client, duration)
		else if(can_see_cb)
			var/can_see = can_see_cb.Invoke(src, viewer)
			if(can_see)
				viewer.playsound_local(src, sound, 15, FALSE)
				flick_overlay(appearance, client, duration)

// Everything about this makes me sad

/mob/living/carbon/proc/play_stress_indicator()
	if(!COOLDOWN_FINISHED(src, stress_indicator))
		return
	show_overhead_indicator('icons/mob/overhead_effects.dmi', "stress", 2 SECONDS, sound = 'sound/ddstress.ogg', can_see_cb = CALLBACK(src, PROC_REF(is_empath)))
	COOLDOWN_START(src, stress_indicator, 8 SECONDS)

/mob/living/carbon/proc/play_relief_indicator()
	if(!COOLDOWN_FINISHED(src, stress_indicator))
		return
	show_overhead_indicator('icons/mob/overhead_effects.dmi', "relief", 2 SECONDS, sound = 'sound/ddrelief.ogg', can_see_cb = CALLBACK(src, PROC_REF(is_empath)))
	COOLDOWN_START(src, stress_indicator, 8 SECONDS)

/mob/living/carbon/proc/play_mental_break_indicator()
	if(!COOLDOWN_FINISHED(src, stress_indicator))
		return
	show_overhead_indicator('icons/mob/overhead_effects.dmi', "mentalbreak", 3 SECONDS, sound = 'sound/stressaffliction.ogg', can_see_cb = CALLBACK(src, PROC_REF(is_empath)))
	COOLDOWN_START(src, stress_indicator, 8 SECONDS)

/mob/living/carbon/proc/is_empath()
	return HAS_TRAIT(src, TRAIT_EMPATH)

/// Flicks a gesture (beckon, wave, taunt...) over our head, seen only by us and the target. Ported from Azure Peak.
/mob/living/proc/play_gesture_emote(mob/target, icon_state, y_offset = 20)
	var/image/gesture = image('icons/mob/overhead_effects.dmi', src, icon_state, ABOVE_ALL_MOB_LAYER)
	gesture.appearance_flags = RESET_COLOR|RESET_ALPHA|KEEP_APART
	gesture.plane = WEATHER_EFFECT_PLANE // Drawn above the vision cone like Azure, the mob's own plane hides it
	gesture.pixel_y = y_offset
	if(iscarbon(src))
		var/mob/living/carbon/C = src
		C.apply_offset(gesture, OFFSET_HEAD)
	var/list/viewers = list()
	if(client)
		viewers += client
	if(target != src && target.client && target.can_see_cone(src))
		viewers += target.client
	flick_overlay(gesture, viewers, 2 SECONDS)
