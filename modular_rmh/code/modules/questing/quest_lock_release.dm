// RMH EDIT: gear on contract (kill quest) mobs is locked with TRAIT_NODROP so it can't be stripped off them.
// If such an item still ends up in someone else's hands, the lock must not follow it: release it as soon as
// anyone who isn't a locked quest mob equips or picks it up, so players never get stuck holding it.

/obj/item/equipped(mob/user, slot, initial = FALSE)
	. = ..()
	release_quest_lock(user)

/obj/item/proc/release_quest_lock(mob/user)
	if(!HAS_TRAIT_FROM(src, TRAIT_NODROP, QUEST_SPAWN_LOCK_TRAIT))
		return
	if(user && HAS_TRAIT_FROM(user, TRAIT_STUCKITEMS, QUEST_SPAWN_LOCK_TRAIT))
		return // still on its quest mob
	REMOVE_TRAIT(src, TRAIT_NODROP, QUEST_SPAWN_LOCK_TRAIT)
	var/datum/component/storage/storage = GetComponent(/datum/component/storage)
	if(storage)
		storage.allow_look_inside = TRUE
		storage.locked = FALSE
