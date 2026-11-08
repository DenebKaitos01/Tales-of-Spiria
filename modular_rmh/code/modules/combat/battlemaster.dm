// RMH EDIT: the Battlemaster's tools.
// - Action Surge: resets the cooldowns of Guard, Feint, Bait and the weapon's special maneuver.
// - Solid Foundations (TRAIT_SOLID_FOUNDATIONS): perfect guards, baits that land and feints that land
//   shave time off the weapon special's cooldown.

/// Seconds a solid move takes off the weapon special's cooldown
#define SOLID_FOUNDATIONS_REDUCTION (8 SECONDS)

/datum/action/cooldown/spell/undirected/action_surge
	name = "Action Surge"
	desc = "Push past your limits: your Guard, Feint, Bait and weapon special are ready again at once."
	button_icon_state = "bcry"
	sound = 'sound/combat/riposte.ogg'
	antimagic_flags = NONE
	associated_skill = /datum/attribute/skill/misc/athletics
	associated_stat = STAT_INTELLIGENCE
	charge_required = FALSE
	has_visual_effects = FALSE
	cooldown_time = 3 MINUTES
	spell_type = SPELL_STAMINA
	spell_cost = 0

/datum/action/cooldown/spell/undirected/action_surge/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return
	return isliving(owner)

/datum/action/cooldown/spell/undirected/action_surge/cast(mob/living/cast_on)
	. = ..()
	var/static/list/cooldowns = list(
		/datum/status_effect/debuff/clashcd,
		/datum/status_effect/debuff/feintcd,
		/datum/status_effect/debuff/baitcd,
		/datum/status_effect/debuff/specialcd,
	)
	var/refreshed = FALSE
	for(var/cd in cooldowns)
		if(cast_on.has_status_effect(cd))
			cast_on.remove_status_effect(cd)
			refreshed = TRUE
	cast_on.visible_message(span_notice("[cast_on] takes a sharp breath and resets [cast_on.p_their()] stance."), \
		span_nicegreen(refreshed ? "Action surge! Everything is ready again." : "Action surge! I'm already ready for anything."))

/// Called when this mob lands a perfect guard, a bait or a feint
/mob/living/proc/solid_foundations(reason)
	if(!HAS_TRAIT(src, TRAIT_SOLID_FOUNDATIONS))
		return
	var/datum/status_effect/debuff/specialcd/cd = has_status_effect(/datum/status_effect/debuff/specialcd)
	if(!cd)
		return
	cd.duration -= SOLID_FOUNDATIONS_REDUCTION
	if(cd.duration <= world.time)
		remove_status_effect(/datum/status_effect/debuff/specialcd)
		balloon_alert(src, "special ready!")
	else
		balloon_alert(src, "special -[SOLID_FOUNDATIONS_REDUCTION / 10]s")

#undef SOLID_FOUNDATIONS_REDUCTION
