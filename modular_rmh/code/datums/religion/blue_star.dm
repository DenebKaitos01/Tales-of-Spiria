// RMH EDIT: Blue Star, the boon of Sirokel. At night, under the open sky, her blue star now and then shines
// for her faithful: a small lift in mood and some of their combat fatigue (the blue bar) eases away.

/// How often the sky is checked
#define BLUE_STAR_INTERVAL (1 MINUTES)
/// Chance per check that the star shines
#define BLUE_STAR_CHANCE 30

/datum/patron/spira/greater/sirokel/on_gain(mob/living/pious)
	. = ..()
	pious.apply_status_effect(/datum/status_effect/blue_star_watch)

/datum/patron/spira/greater/sirokel/on_remove(mob/living/pious)
	. = ..()
	pious.remove_status_effect(/datum/status_effect/blue_star_watch)

/// Hidden: watches the night sky for Sirokel's star
/datum/status_effect/blue_star_watch
	id = "blue_star_watch"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	alert_type = null
	tick_interval = BLUE_STAR_INTERVAL

/datum/status_effect/blue_star_watch/tick()
	if(!HAS_TRAIT(owner, TRAIT_BLUE_STAR) || owner.stat != CONSCIOUS || GLOB.tod != TOD_NIGHT)
		return
	var/area/here = get_area(owner)
	if(!here?.outdoors) // the star has to be seen
		return
	if(!prob(BLUE_STAR_CHANCE))
		return
	to_chat(owner, span_notice("A blue star glimmers in the night sky. Sirokel is watching over me."))
	owner.add_stress(/datum/stress_event/blue_star)
	owner.adjust_stamina(-owner.maximum_stamina * 0.2)

/datum/stress_event/blue_star
	timer = 10 MINUTES
	stress_change = -1
	desc = span_green("I saw Sirokel's blue star shining.")

#undef BLUE_STAR_INTERVAL
#undef BLUE_STAR_CHANCE
