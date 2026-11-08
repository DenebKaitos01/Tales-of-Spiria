// RMH EDIT: Azure Peak's mace smash. The smash is now a charged blow (1 second) that knocks the target
// back and slows them, scaling with Strength: X = 1 tile up to XIV = 4 tiles (one-handed smashes cap at 3).
// Below Strength X it does neither. Each target can only be knocked back once every 8 seconds, prone
// targets fly half as far, and a smash released early only knocks back one tile.
// Giant's Might (Ironclad) sends them 2 tiles further.

/datum/intent/mace/smash
	/// Furthest a full-strength smash can knock someone back
	var/maxrange = 4

/// Knockback and slowdown from a mace smash that landed on src
/mob/living/proc/mace_smash_knockback(mob/living/user)
	if(!user || user == src || stat == DEAD)
		return
	var/datum/intent/mace/smash/smash = user.used_intent
	if(!istype(smash))
		return
	if(has_status_effect(/datum/status_effect/debuff/yeetcd))
		return // recently knocked back
	var/strength = GET_MOB_ATTRIBUTE_VALUE(user, STAT_STRENGTH)
	if(strength < 10)
		return // too weak to move anyone
	var/scaling = clamp(strength - 10, 1, smash.maxrange)
	apply_status_effect(/datum/status_effect/debuff/yeetcd)
	Slowdown(scaling)
	if(HAS_TRAIT(src, TRAIT_IMMOVABLE) || anchored || buckled || mob_size >= MOB_SIZE_LARGE)
		return
	var/knockback_tiles = scaling
	if(body_position == LYING_DOWN)
		knockback_tiles = max(1, round(knockback_tiles / 2))
	if(smash.get_chargetime() && user.client?.chargedprog < 100)
		knockback_tiles = 1 // released early
	if(HAS_TRAIT(user, TRAIT_GIANT_MIGHT))
		knockback_tiles += 2
	var/turf/edge = get_edge_target_turf(src, get_dir(user, src))
	if(istype(edge))
		safe_throw_at(edge, knockback_tiles, scaling, user, spin = FALSE, force = move_force, callback = CALLBACK(src, TYPE_PROC_REF(/mob/living, handle_knockback), get_turf(src)))

/// Can't be knocked back by a smash again for a moment
/datum/status_effect/debuff/yeetcd
	id = "yeetcd"
	duration = 8 SECONDS
	alert_type = null
	status_type = STATUS_EFFECT_REFRESH
