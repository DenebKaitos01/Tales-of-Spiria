// RMH EDIT: Will to Live, the boon of Saelion. When a follower is about to be defeated (beaten down by damage
// or pain, or at death's door) they get a small chance, based on Endurance, to refuse to fall: they recover a
// little and stay on their feet. It can only save them once per round.

/// Chance per point of Endurance (10 Endurance = 20%)
#define WILL_TO_LIVE_CHANCE_PER_END 2
#define WILL_TO_LIVE_MIN_CHANCE 5
#define WILL_TO_LIVE_MAX_CHANCE 40

/mob/living
	/// Saelion's Will to Live already saved this mob this round
	var/will_to_live_used = FALSE

/// Called right before this mob is defeated. Returns TRUE if they refuse to fall.
/mob/living/proc/try_will_to_live(reason)
	if(will_to_live_used || stat == DEAD || !HAS_TRAIT(src, TRAIT_WILL_TO_LIVE))
		return FALSE
	if(!(reason in list(DEFEAT_REASON_DAMAGE, DEFEAT_REASON_PAIN, DEFEAT_REASON_DEATH)))
		return FALSE
	var/chance = clamp(GET_MOB_ATTRIBUTE_VALUE(src, STAT_ENDURANCE) * WILL_TO_LIVE_CHANCE_PER_END, WILL_TO_LIVE_MIN_CHANCE, WILL_TO_LIVE_MAX_CHANCE)
	if(!prob(chance))
		return FALSE
	will_to_live_used = TRUE

	// Recover enough to get back under the point of defeat
	var/pool = get_defeat_damage_pool()
	var/threshold = get_effective_defeat_threshold()
	var/needed = max(15, pool - (threshold * 0.8))
	heal_overall_damage(needed, needed * 0.5)
	if(getOxyLoss() > 0)
		adjustOxyLoss(-50)
	if(!is_bloodless())
		adjust_bloodvolume(BLOOD_VOLUME_NORMAL * 0.1, BLOOD_VOLUME_NORMAL) // a little blood back
	SetUnconscious(0)
	SetParalyzed(0)
	SetKnockdown(0)
	if(body_position == LYING_DOWN)
		get_up(TRUE)

	playsound(src, 'sound/magic/bless.ogg', 80, TRUE)
	to_chat(src, span_userdanger("Saelion watches over his sons and daughters. RISE!"))
	return TRUE

#undef WILL_TO_LIVE_CHANCE_PER_END
#undef WILL_TO_LIVE_MIN_CHANCE
#undef WILL_TO_LIVE_MAX_CHANCE
