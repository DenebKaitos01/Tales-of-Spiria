// RMH EDIT: Will to Live, the boon of Saelion. Once per round, when a follower is about to die - a lethal blow
// or critical, standing at death's door, or bleeding out massively - Saelion pulls them back: they recover
// enough to keep going, get some blood back and stay on their feet.

/// A blow or critical that would kill outright
#define WILL_TO_LIVE_LETHAL "lethal"
/// Massive blood loss
#define WILL_TO_LIVE_BLEEDING "bleeding"

/mob/living
	/// Saelion's Will to Live already saved this mob this round
	var/will_to_live_used = FALSE

/// Called when this mob is about to die. Returns TRUE if Saelion pulls them back.
/mob/living/proc/try_will_to_live(reason)
	if(will_to_live_used || stat == DEAD || !HAS_TRAIT(src, TRAIT_WILL_TO_LIVE))
		return FALSE
	if(!(reason in list(WILL_TO_LIVE_LETHAL, WILL_TO_LIVE_BLEEDING, DEFEAT_REASON_DEATH)))
		return FALSE
	if(iscarbon(src))
		var/mob/living/carbon/body = src
		if(!body.get_bodypart(BODY_ZONE_HEAD) || !body.getorganslot(ORGAN_SLOT_BRAIN))
			return FALSE // nothing to pull back
	will_to_live_used = TRUE

	// Back from the brink: well clear of death and of the point of defeat
	var/needed = max(25, (maxHealth * 0.35) - health)
	if(defeat_system_is_eligible())
		needed = max(needed, get_defeat_damage_pool() - (get_effective_defeat_threshold() * 0.8))
	heal_overall_damage(needed, needed * 0.5)
	if(getOxyLoss() > 0)
		adjustOxyLoss(-50)
	if(iscarbon(src))
		var/mob/living/carbon/C = src
		if(C.getOrganLoss(ORGAN_SLOT_BRAIN) >= BRAIN_DAMAGE_DEATH * 0.8)
			C.setOrganLoss(ORGAN_SLOT_BRAIN, BRAIN_DAMAGE_DEATH * 0.5)
	if(!is_bloodless())
		if(reason == WILL_TO_LIVE_BLEEDING || blood_volume < BLOOD_VOLUME_OKAY)
			adjust_bloodvolume(BLOOD_VOLUME_OKAY - blood_volume, BLOOD_VOLUME_OKAY) // enough blood to keep standing
		else
			adjust_bloodvolume(BLOOD_VOLUME_NORMAL * 0.1, BLOOD_VOLUME_NORMAL)
	SetUnconscious(0)
	SetParalyzed(0)
	SetKnockdown(0)
	if(body_position == LYING_DOWN)
		get_up(TRUE)
	updatehealth()

	playsound(src, 'sound/magic/bless.ogg', 80, TRUE)
	to_chat(src, span_userdanger("Saelion watches over his sons and daughters. RISE!"))
	return TRUE

/// Massive bleeding check, called after blood is lost
/mob/living/proc/check_will_to_live_bleeding()
	if(will_to_live_used || blood_volume > BLOOD_VOLUME_BAD || !HAS_TRAIT(src, TRAIT_WILL_TO_LIVE))
		return
	try_will_to_live(WILL_TO_LIVE_BLEEDING)

#undef WILL_TO_LIVE_LETHAL
#undef WILL_TO_LIVE_BLEEDING
