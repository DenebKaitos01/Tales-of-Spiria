// RMH EDIT (combat rework): Sekiro-style posture. Every blow we parry builds tension; when it fills,
// our guard breaks: we are left vulnerable and the blow cracks into our armor.
// Tension drains on its own once we stop parrying. Winning a clash duel clears it, losing one piles it on,
// and a successful dodge eases it a little.

/// Seconds after the last parried blow before tension starts to drain
#define POSTURE_REGEN_DELAY (3 SECONDS)
/// Tension drained per second once it drains
#define POSTURE_REGEN_RATE 8
/// How often the drain ticks
#define POSTURE_TICK (0.5 SECONDS)
/// Base tension of a parried blow, before the weapon and the strength gap
#define POSTURE_PARRY_BASE 12
/// How long a broken guard leaves us vulnerable
#define POSTURE_BREAK_VULNERABLE (3 SECONDS)
/// Armor integrity a guard break tears off, before the attacker's weapon
#define POSTURE_BREAK_ARMOR_BASE 50
/// How long the attacker keeps seeing our bar after striking into our guard
#define POSTURE_VIEW_TIME (6 SECONDS)
/// Tension a successful dodge drains
#define POSTURE_DODGE_RELIEF 15
/// Tension a lost clash duel piles on
#define POSTURE_CLASH_LOSS 40

/mob/living
	/// Tension built up by parrying, 0 to get_max_posture()
	var/posture = 0
	/// world.time of the last tension gain
	var/last_posture_gain = 0
	/// The drain timer is running
	var/posture_ticking = FALSE
	/// Bar shown over our head
	var/image/posture_image
	/// Clients seeing our bar: client = world.time they stop seeing it (0 = always, for ourselves)
	var/list/posture_viewers

/// Endurance raises how much tension we can take before the guard breaks
/mob/living/proc/get_max_posture()
	return clamp(100 + (GET_MOB_ATTRIBUTE_VALUE(src, STAT_ENDURANCE) - 10) * 5, 70, 150)

/// Tension a parried blow builds: heavier weapons and stronger arms push harder, a perfect parry halves it
/mob/living/proc/parry_posture_damage(mob/living/attacker, datum/intent/intenty, obj/item/used_weapon, perfect)
	var/obj/item/attacker_item = intenty?.get_master_item()
	. = POSTURE_PARRY_BASE
	if(attacker_item)
		. += attacker_item.force * 0.5
	var/strength_gap = GET_MOB_ATTRIBUTE_VALUE(attacker, STAT_STRENGTH) - GET_MOB_ATTRIBUTE_VALUE(src, STAT_STRENGTH)
	if(strength_gap > 0)
		. += strength_gap * 2
	if(istype(used_weapon, /obj/item/weapon/shield)) // a shield takes the brunt
		. *= 0.75
	if(perfect)
		. *= 0.5
	return round(.)

/**
 * Adds tension. If it fills, the guard breaks.
 * attacker is who pushed it (they get to see our bar), and whose weapon cracks our armor on a break.
 */
/mob/living/proc/add_posture(amount, mob/living/attacker)
	if(amount <= 0 || stat == DEAD)
		return
	posture = min(posture + amount, get_max_posture())
	last_posture_gain = world.time
	if(attacker?.client)
		show_posture_to(attacker.client, world.time + POSTURE_VIEW_TIME)
	if(posture >= get_max_posture())
		posture_break(attacker)
		return
	update_posture_bar()
	start_posture_ticks()

/// Drains tension: dodges, clash wins
/mob/living/proc/reduce_posture(amount)
	if(amount <= 0 || posture <= 0)
		return
	posture = max(posture - amount, 0)
	update_posture_bar()

/// Settles a clash duel on posture: the winner's tension clears, the loser's piles up (which can break their guard)
/proc/clash_duel_posture(mob/living/winner, mob/living/loser)
	winner?.reduce_posture(winner.posture)
	loser?.add_posture(POSTURE_CLASH_LOSS, winner)

/// A clean dodge eases the tension a little
/mob/living/proc/dodge_posture_relief()
	reduce_posture(POSTURE_DODGE_RELIEF)

/mob/living/proc/start_posture_ticks()
	if(posture_ticking)
		return
	posture_ticking = TRUE
	addtimer(CALLBACK(src, PROC_REF(posture_tick)), POSTURE_TICK)

/mob/living/proc/posture_tick()
	if(QDELETED(src))
		return
	if(posture <= 0 || stat == DEAD)
		posture = 0
		posture_ticking = FALSE
		update_posture_bar()
		return
	if(world.time >= last_posture_gain + POSTURE_REGEN_DELAY)
		posture = max(posture - POSTURE_REGEN_RATE * (POSTURE_TICK / (1 SECONDS)), 0)
	update_posture_bar()
	addtimer(CALLBACK(src, PROC_REF(posture_tick)), POSTURE_TICK)

/// The guard gives way: vulnerable for a moment, and the blow tears into our armor
/mob/living/proc/posture_break(mob/living/attacker)
	posture = 0
	update_posture_bar()
	visible_message(span_boldwarning("[src]'s guard is broken!"), span_userdanger("MY GUARD BREAKS!"))
	playsound(src, 'sound/combat/clash_disarm_us.ogg', 100, TRUE)
	shake_camera(src, 3, 2)
	apply_status_effect(/datum/status_effect/debuff/vulnerable, POSTURE_BREAK_VULNERABLE)
	var/obj/item/attacker_item = attacker?.get_active_held_item()
	var/armor_damage = POSTURE_BREAK_ARMOR_BASE + (attacker_item ? attacker_item.force * 1.5 : 0)
	posture_break_armor(armor_damage, attacker)

/mob/living/proc/posture_break_armor(armor_damage, mob/living/attacker)
	return

/// Cracks the armor piece covering where the attacker aimed (the worn armor first)
/mob/living/carbon/human/posture_break_armor(armor_damage, mob/living/attacker)
	var/zone = attacker?.zone_selected || BODY_ZONE_CHEST
	if(zone == BODY_ZONE_PRECISE_MOUTH || zone == BODY_ZONE_PRECISE_NOSE || (zone in BODY_ZONES_EYES))
		zone = BODY_ZONE_HEAD
	var/obj/item/clothing/used
	var/best = 0
	for(var/obj/item/clothing/piece in list(wear_armor, head, wear_shirt, gloves, wear_wrists, wear_neck, shoes, wear_pants, cloak))
		if(!piece.uses_integrity || piece.get_integrity() <= 0 || !zone2covered(zone, piece.body_parts_covered))
			continue
		if(piece == wear_armor)
			used = piece
			break
		var/rating = piece.get_armor_rating(BLUNT) + piece.get_armor_rating(SLASH)
		if(rating > best)
			best = rating
			used = piece
	if(!used)
		return
	var/old_integrity = used.get_integrity()
	var/dealt = used.take_damage(armor_damage, damage_flag = BLUNT, sound_effect = FALSE, armor_penetration = 100)
	if(used.blocksound)
		playsound(src, get_armor_sound(used.blocksound, FALSE), 100)
	if(dealt > 0)
		show_armor_damage_feedback(used, dealt, old_integrity, used.get_integrity(), attacker)

/mob/living/proc/show_posture_to(client/viewer, until)
	if(!viewer)
		return
	LAZYINITLIST(posture_viewers)
	if((viewer in posture_viewers) && !posture_viewers[viewer])
		return // our own bar, always shown
	posture_viewers[viewer] = until

/// A small bar under our feet, filling yellow to red; seen by us and by whoever is striking into our guard
/mob/living/proc/update_posture_bar()
	if(posture <= 0)
		clear_posture_bar()
		return
	if(client)
		show_posture_to(client, 0)
	if(!posture_image)
		posture_image = image(loc = src, layer = ABOVE_ALL_MOB_LAYER)
		posture_image.plane = WEATHER_EFFECT_PLANE
		posture_image.appearance_flags = RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM|KEEP_APART
		posture_image.maptext_width = 96
		posture_image.maptext_x = -32
		posture_image.pixel_y = -10
	var/ratio = posture / get_max_posture()
	var/filled = clamp(round(ratio * 10), 1, 10)
	var/color = ratio >= 0.8 ? "#ff3b3b" : (ratio >= 0.5 ? "#ff9a3b" : "#ffd84a")
	posture_image.maptext = MAPTEXT_CENTER("<span style='color:[color]'>[repeat_string(filled, "|")]</span><span style='color:#555555'>[repeat_string(10 - filled, "|")]</span>")
	for(var/client/viewer as anything in posture_viewers?.Copy())
		var/until = posture_viewers[viewer]
		if(!viewer || (until && world.time > until))
			viewer?.images -= posture_image
			posture_viewers -= viewer
			continue
		viewer.images |= posture_image

/mob/living/proc/clear_posture_bar()
	for(var/client/viewer as anything in posture_viewers)
		viewer?.images -= posture_image
	posture_viewers = null

/mob/living/Destroy()
	clear_posture_bar()
	posture_image = null
	return ..()

#undef POSTURE_REGEN_DELAY
#undef POSTURE_REGEN_RATE
#undef POSTURE_TICK
#undef POSTURE_PARRY_BASE
#undef POSTURE_BREAK_VULNERABLE
#undef POSTURE_BREAK_ARMOR_BASE
#undef POSTURE_VIEW_TIME
#undef POSTURE_DODGE_RELIEF
#undef POSTURE_CLASH_LOSS
