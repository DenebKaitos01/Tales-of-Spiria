// RMH EDIT: Second Wind, the base fighter ability (Adventurer: Warrior).
// A short burst of grit: +1 to every stat but Intelligence and Fortune for a while, a little healing and
// energy back. Near death (25% health or less) the healing and energy recovered are far greater.

/// Health fraction at or below which Second Wind is "desperate" and much stronger
#define SECOND_WIND_DESPERATE_HEALTH 0.25

/datum/action/cooldown/spell/undirected/second_wind
	name = "Second Wind"
	desc = "Steel yourself and fight on: +1 to every stat but Intelligence and Fortune for a minute, \
	and recover some health and energy. When at a quarter of your health or less, you recover far more."
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
	cast_on.apply_status_effect(/datum/status_effect/buff/second_wind)
	if(desperate)
		cast_on.heal_overall_damage(40, 15)
		cast_on.adjust_energy(cast_on.max_energy * 0.6) // the green bar
		cast_on.adjust_stamina(-cast_on.maximum_stamina) // and all combat fatigue
		cast_on.visible_message(span_danger("[cast_on] roars and rises again, refusing to fall!"), span_notice("Not yet! I refuse to fall here!"))
		cast_on.emote("rage", forced = TRUE)
	else
		cast_on.heal_overall_damage(10, 5)
		cast_on.adjust_energy(cast_on.max_energy * 0.15)
		cast_on.adjust_stamina(-cast_on.maximum_stamina * 0.3)
		cast_on.visible_message(span_notice("[cast_on] catches their breath and steadies their stance."), span_notice("I catch my second wind."))

/datum/status_effect/buff/second_wind
	id = "second_wind"
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/buff/second_wind
	effectedstats = list(STAT_STRENGTH = 1, STAT_PERCEPTION = 1, STAT_ENDURANCE = 1, STAT_CONSTITUTION = 1, STAT_SPEED = 1)
	duration = 1 MINUTES

/atom/movable/screen/alert/status_effect/buff/second_wind
	name = "Second Wind"
	desc = span_nicegreen("I have found my second wind!")
	icon_state = "ravox"

#undef SECOND_WIND_DESPERATE_HEALTH
