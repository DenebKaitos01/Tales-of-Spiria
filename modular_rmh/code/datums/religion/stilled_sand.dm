// RMH EDIT: Stilled Sand, the boon of Lunestra. Her faithful stitch wounds faster with a needle, and stitching
// someone at death's door stops their sand for a minute: they can't die from their wounds while it lasts, giving
// time to finish the work. Each patient can only be held back once every few minutes.

/// How long a stitched patient's sand stays still
#define STILLED_SAND_DURATION (1 MINUTES)
/// How long before the same patient can be held back again
#define STILLED_SAND_COOLDOWN (5 MINUTES)

/mob/living
	/// world.time until which Lunestra won't hold this mob back again
	var/stilled_sand_cooldown = 0

/// Needle work goes faster in a Lunestra follower's hands
/mob/living/proc/stilled_sand_sew_time(base_time)
	if(HAS_TRAIT(src, TRAIT_STILLED_SAND))
		return base_time * 0.6
	return base_time

/// A Lunestra follower just stitched this patient: if they are dying, their sand stops for a while
/mob/living/proc/stilled_sand_stitched(mob/living/patient)
	if(!HAS_TRAIT(src, TRAIT_STILLED_SAND) || !istype(patient) || patient.stat == DEAD)
		return
	var/dying = patient.stat != CONSCIOUS || patient.health <= patient.crit_threshold
	if(iscarbon(patient) && patient.blood_volume <= BLOOD_VOLUME_BAD && !patient.is_bloodless())
		dying = TRUE
	if(!dying || world.time < patient.stilled_sand_cooldown)
		return
	patient.stilled_sand_cooldown = world.time + STILLED_SAND_COOLDOWN
	patient.apply_status_effect(/datum/status_effect/stilled_sand)
	visible_message(span_notice("[src] ties off the last stitch, and for a moment the air around [patient] goes perfectly still."), \
		span_notice("Lunestra stills [patient]'s sand. I have a minute."))

/// Lunestra holds this mob's sand: wounds can't finish them off while it lasts
/datum/status_effect/stilled_sand
	id = "stilled_sand"
	duration = STILLED_SAND_DURATION
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/stilled_sand

/datum/status_effect/stilled_sand/on_apply()
	ADD_TRAIT(owner, TRAIT_NODEATH, TRAIT_STATUS_EFFECT(id))
	ADD_TRAIT(owner, TRAIT_NOCRITDAMAGE, TRAIT_STATUS_EFFECT(id))
	to_chat(owner, span_notice("The sand in my hourglass stops falling. Not yet."))
	return TRUE

/datum/status_effect/stilled_sand/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NODEATH, TRAIT_STATUS_EFFECT(id))
	REMOVE_TRAIT(owner, TRAIT_NOCRITDAMAGE, TRAIT_STATUS_EFFECT(id))
	if(owner.stat != DEAD)
		to_chat(owner, span_warning("The sand starts falling again."))

/atom/movable/screen/alert/status_effect/stilled_sand
	name = "Stilled Sand"
	desc = "Lunestra holds my sand still. My wounds can't finish me while it lasts."
	icon_state = "buff"

#undef STILLED_SAND_DURATION
#undef STILLED_SAND_COOLDOWN
