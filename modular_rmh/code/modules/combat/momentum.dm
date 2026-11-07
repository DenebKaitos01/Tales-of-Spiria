// RMH EDIT: Momentum, the Warrior's second class trait.
// Every landed melee hit builds momentum. The sixth one in a row puts the warrior in Focus for a minute:
// +1 Strength, Speed and Intelligence, and stamina and energy slowly come back. While focused, every landed
// hit or successful block/parry restarts the minute. Momentum that isn't built on fades after a short lull.

/// Landed hits needed to enter Focus
#define MOMENTUM_HITS_FOR_FOCUS 6
/// Momentum is lost if no hit lands for this long
#define MOMENTUM_FADE_TIME 20 SECONDS

/// Called when this mob lands a melee hit on another living mob
/mob/living/proc/momentum_hit()
	if(!HAS_TRAIT(src, TRAIT_MOMENTUM))
		return
	if(has_status_effect(/datum/status_effect/buff/focus))
		apply_status_effect(/datum/status_effect/buff/focus) // refreshes the minute
		return
	var/datum/status_effect/momentum/stacks = has_status_effect(/datum/status_effect/momentum)
	if(!stacks)
		stacks = apply_status_effect(/datum/status_effect/momentum)
	else
		stacks.refresh()
	if(!stacks)
		return
	stacks.hits++
	if(stacks.hits >= MOMENTUM_HITS_FOR_FOCUS)
		remove_status_effect(/datum/status_effect/momentum)
		apply_status_effect(/datum/status_effect/buff/focus)
		playsound(src, 'sound/magic/barbroar.ogg', 40, TRUE)
		visible_message(span_notice("[src]'s eyes harden as they find their rhythm."), span_nicegreen("My momentum peaks. I am focused!"))
	else
		balloon_alert(src, "momentum [stacks.hits]/[MOMENTUM_HITS_FOR_FOCUS]")

/// Called when this mob blocks or parries an attack
/mob/living/proc/momentum_block()
	if(!HAS_TRAIT(src, TRAIT_MOMENTUM))
		return
	if(has_status_effect(/datum/status_effect/buff/focus))
		apply_status_effect(/datum/status_effect/buff/focus)

/// Hidden counter of landed hits towards Focus
/datum/status_effect/momentum
	id = "momentum"
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = null
	duration = MOMENTUM_FADE_TIME
	var/hits = 0

/datum/status_effect/buff/focus
	id = "warrior_focus"
	alert_type = /atom/movable/screen/alert/status_effect/buff/focus
	effectedstats = list(STAT_STRENGTH = 1, STAT_SPEED = 1, STAT_INTELLIGENCE = 1)
	duration = 1 MINUTES
	tick_interval = 2 SECONDS

/datum/status_effect/buff/focus/tick()
	owner.adjust_stamina(-owner.maximum_stamina * 0.04) // the blue bar: combat fatigue goes down
	owner.adjust_energy(owner.max_energy * 0.02) // the green bar comes back

/datum/status_effect/buff/focus/on_remove()
	. = ..()
	if(owner.stat != DEAD)
		to_chat(owner, span_warning("My focus fades."))

/atom/movable/screen/alert/status_effect/buff/focus
	name = "Focus"
	desc = span_nicegreen("I have found my rhythm. Every blow I land or turn aside keeps it going.")
	icon_state = "ravox"

#undef MOMENTUM_HITS_FOR_FOCUS
#undef MOMENTUM_FADE_TIME
