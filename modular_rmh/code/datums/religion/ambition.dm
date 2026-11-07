// RMH EDIT: Ambition, the boon of Gaedon. When a critical failure is rolled on an attack (critical miss)
// or while crafting (a fumble), the roll is made again; only a second critical failure stands.

/// Called after a critical failure has been rolled. `rerolled_fail` is the result of rolling it again.
/// Returns TRUE if Ambition undoes the critical failure.
/mob/proc/ambition_spares(rerolled_fail)
	if(!HAS_TRAIT(src, TRAIT_AMBITION))
		return FALSE
	if(rerolled_fail)
		to_chat(src, span_warning("Not even my ambition could save that one..."))
		return FALSE
	to_chat(src, span_notice("I refuse to fail here! Gaedon's ambition steadies me."))
	return TRUE
