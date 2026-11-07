// RMH EDIT: Second Wind, the base fighter ability (Adventurer: Warrior).
// A short burst of grit: some healing, and for a moment the pain no longer slows me down.
// Near death (25% health or less) the healing is far greater and the pain stays away longer.
// (The stat bonuses now come from Momentum's Focus instead.)

/// Health fraction at or below which Second Wind is "desperate" and much stronger
#define SECOND_WIND_DESPERATE_HEALTH 0.25

/datum/action/cooldown/spell/undirected/second_wind
	name = "Second Wind"
	desc = "Steel yourself and fight on: recover some health and ignore pain for a few moments. \
	When at a quarter of your health or less, you recover far more and ignore pain for longer."
	button_icon_state = "bcry"
	sound = 'sound/magic/barbroar.ogg'

	antimagic_flags = NONE

	associated_skill = /datum/attribute/skill/misc/athletics
	associated_stat = STAT_CONSTITUTION

	charge_required = FALSE
	has_visual_effects = FALSE
	cooldown_time = 3 MINUTES
	spell_type = SPELL_STAMINA
	spell_cost = 0

/datum/action/cooldown/spell/undirected/second_wind/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return
	return isliving(owner)

/datum/action/cooldown/spell/undirected/second_wind/cast(mob/living/cast_on)
	. = ..()
	var/desperate = cast_on.maxHealth > 0 && (cast_on.health / cast_on.maxHealth) <= SECOND_WIND_DESPERATE_HEALTH
	if(desperate)
		cast_on.heal_overall_damage(40, 15)
		cast_on.apply_status_effect(/datum/status_effect/buff/second_wind, 30 SECONDS)
		cast_on.visible_message(span_danger("[cast_on] roars and rises again, refusing to fall!"), span_notice("Not yet! I refuse to fall here!"))
		cast_on.emote("rage", forced = TRUE)
	else
		cast_on.heal_overall_damage(15, 5)
		cast_on.apply_status_effect(/datum/status_effect/buff/second_wind, 10 SECONDS)
		cast_on.visible_message(span_notice("[cast_on] catches their breath and steadies their stance."), span_notice("I catch my second wind."))

/// Pain doesn't reach me for a few moments
/datum/status_effect/buff/second_wind
	id = "second_wind"
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/buff/second_wind
	duration = 10 SECONDS

/datum/status_effect/buff/second_wind/on_apply()
	. = ..()
	ADD_TRAIT(owner, TRAIT_NOPAIN, TRAIT_STATUS_EFFECT(id))

/datum/status_effect/buff/second_wind/on_remove()
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_NOPAIN, TRAIT_STATUS_EFFECT(id))
	if(owner.stat != DEAD)
		to_chat(owner, span_warning("The pain comes rushing back."))

/atom/movable/screen/alert/status_effect/buff/second_wind
	name = "Second Wind"
	desc = span_nicegreen("I've caught my second wind. The pain can't reach me right now.")
	icon_state = "ravox"

#undef SECOND_WIND_DESPERATE_HEALTH
