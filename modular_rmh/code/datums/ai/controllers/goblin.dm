// RMH EDIT: goblin pack tactics. What a goblin does depends on the gear it carries.
// - Slingers (sling + pouch of stones) pelt the target from range, but only while another goblin is with them;
//   alone, or once the foe closes in, they fight with their knife. A slinger runs when it is alone and hurt, or
//   when it is badly hurt even with the pack around.
// - Shield bearers hold the line: they always fight toe to toe.
// - Everyone else brawls in a duo and harasses hit-and-run in packs of three or more.
// - A goblin fighting alone flees once badly hurt or in pain, breaks line of sight, and after hiding for a few
//   seconds licks its wounds. It keeps the attacker in mind and comes back for them once recovered.
//   It stays in the fight while another goblin is close by. A cornered goblin fights.

#define BB_GOBLIN_ROLE "goblin_role"
#define BB_GOBLIN_FLEEING "goblin_fleeing"
#define BB_GOBLIN_THREAT "goblin_threat"
#define BB_GOBLIN_HIDDEN_SINCE "goblin_hidden_since"
#define BB_GOBLIN_CORNERED_SINCE "goblin_cornered_since"
#define BB_GOBLIN_NEXT_FLEE "goblin_next_flee"

#define GOBLIN_ROLE_BRAWLER "brawler"
#define GOBLIN_ROLE_HARASSER "harasser"
#define GOBLIN_ROLE_SLINGER "slinger"

/// Packmates on the same target within this range share out roles
#define GOBLIN_PACK_RANGE 7
/// A goblin with a packmate this close doesn't run
#define GOBLIN_BACKUP_RANGE 5
/// How far a fleeing goblin watches for its attacker
#define GOBLIN_SIGHT_RANGE 8
/// Hurt fraction (damage or pain) at which a lone goblin runs
#define GOBLIN_FLEE_HURT 0.5
/// Hurt fraction at which a slinger runs even with the pack around
#define GOBLIN_SLINGER_FLEE_HURT 0.75
/// Hurt fraction at which a hiding goblin is ready to fight again
#define GOBLIN_RECOVERED_HURT 0.2
/// Out of sight this long before it starts licking its wounds
#define GOBLIN_HIDE_TIME (4 SECONDS)
/// Caught this long at arm's reach while fleeing and it turns to fight
#define GOBLIN_CORNERED_TIME (2 SECONDS)
/// A cornered goblin won't try to run again for this long
#define GOBLIN_CORNERED_COOLDOWN (15 SECONDS)
/// Short pause before running again after leaving a flight
#define GOBLIN_REFLEE_DELAY (3 SECONDS)

/datum/ai_controller/human_npc/goblin
	planning_subtrees = list(
		/datum/ai_planning_subtree/pet_planning,
		/datum/ai_planning_subtree/call_for_help,
		/datum/ai_planning_subtree/generic_break_restraints,
		/datum/ai_planning_subtree/use_powder,
		/datum/ai_planning_subtree/use_bandage,
		/datum/ai_planning_subtree/use_throwable,
		/datum/ai_planning_subtree/use_healing_drink,
		/datum/ai_planning_subtree/throw_grenade,
		/datum/ai_planning_subtree/generic_wield,
		/datum/ai_planning_subtree/generic_resist,
		/datum/ai_planning_subtree/generic_stand,
		/datum/ai_planning_subtree/goblin_survival,
		/datum/ai_planning_subtree/kidnap_defeated_prey,
		/datum/ai_planning_subtree/simple_find_horny,
		/datum/ai_planning_subtree/horny,

		/datum/ai_planning_subtree/tree_climb,
		/datum/ai_planning_subtree/aggro_find_target,
		/datum/ai_planning_subtree/goblin_pack_role,
		/datum/ai_planning_subtree/ranged_attack_subtree/goblin,
		/datum/ai_planning_subtree/wounded_harass/goblin,
		/datum/ai_planning_subtree/squad_flank,
		/datum/ai_planning_subtree/human_npc_gap_close,
		/datum/ai_planning_subtree/basic_melee_attack_subtree/human_npc,
		/datum/ai_planning_subtree/find_weapon,
		/datum/ai_planning_subtree/equip_item,
		/datum/ai_planning_subtree/retrieve_arrows,
		/datum/ai_planning_subtree/loot,
	)

/datum/ai_controller/human_npc/goblin/TryPossessPawn(atom/new_pawn)
	. = ..()
	set_blackboard_key(BB_GOBLIN_ROLE, GOBLIN_ROLE_BRAWLER)

/// Is other a goblin of pawn's pack, awake and AI-driven?
/proc/is_goblin_packmate(mob/living/carbon/human/pawn, mob/living/carbon/human/other)
	if(other == pawn || other.client || other.stat != CONSCIOUS)
		return FALSE
	if(!istype(other.ai_controller, /datum/ai_controller/human_npc/goblin))
		return FALSE
	return pawn.faction_check_atom(other)

/// Is a packmate (not running away) within range?
/proc/goblin_has_backup(mob/living/carbon/human/pawn, range = GOBLIN_BACKUP_RANGE)
	for(var/mob/living/carbon/human/other in view(range, pawn))
		if(!is_goblin_packmate(pawn, other))
			continue
		if(other.ai_controller.blackboard[BB_GOBLIN_FLEEING])
			continue
		return TRUE
	return FALSE

/// Does this goblin carry a sling it can use?
/proc/goblin_has_sling(mob/living/carbon/human/pawn)
	for(var/obj/item/gun/ballistic/revolver/grenadelauncher/bow/sling/sling in pawn.get_all_gear())
		return TRUE
	return FALSE

/// Does this goblin hold a shield?
/proc/goblin_has_shield(mob/living/carbon/human/pawn)
	for(var/obj/item/held in pawn.held_items)
		if(istype(held, /obj/item/weapon/shield))
			return TRUE
	return FALSE

/// Puts back the melee weapon the ranged subtree stowed to free its hands
/proc/goblin_draw_stashed_weapon(datum/ai_controller/controller)
	var/mob/living/carbon/human/pawn = controller.pawn
	var/obj/item/stashed = controller.blackboard[BB_ARCHER_NPC_STASHED_WEAPON]
	if(!stashed || QDELETED(stashed))
		controller.clear_blackboard_key(BB_ARCHER_NPC_STASHED_WEAPON)
		return
	// Put the sling away first so the knife has a free hand
	for(var/obj/item/gun/ballistic/revolver/grenadelauncher/bow/sling/sling in pawn.held_items)
		if(!pawn.equip_to_slot_if_possible(sling, ITEM_SLOT_BELT_L, disable_warning = TRUE) && !pawn.equip_to_slot_if_possible(sling, ITEM_SLOT_BELT_R, disable_warning = TRUE))
			pawn.equip_to_slot_if_possible(sling, ITEM_SLOT_BACK_L, disable_warning = TRUE)
	if(!pawn.get_active_held_item())
		pawn.dropItemToGround(stashed, TRUE, TRUE)
		pawn.put_in_active_hand(stashed)
	else if(!pawn.get_inactive_held_item())
		pawn.dropItemToGround(stashed, TRUE, TRUE)
		pawn.put_in_inactive_hand(stashed)
	controller.clear_blackboard_key(BB_ARCHER_NPC_STASHED_WEAPON)

// ---------------- Survival: run, hide, lick wounds ----------------

/datum/ai_planning_subtree/goblin_survival

/datum/ai_planning_subtree/goblin_survival/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/living/carbon/human/pawn = controller.pawn
	if(!controller.blackboard[BB_GOBLIN_FLEEING])
		var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
		if(QDELETED(target) || target.stat == DEAD)
			return
		if(world.time < controller.blackboard[BB_GOBLIN_NEXT_FLEE])
			return
		if(!should_run(pawn))
			return
		start_fleeing(controller, target)

	var/mob/living/threat = controller.blackboard[BB_GOBLIN_THREAT]
	if(QDELETED(threat) || threat.stat == DEAD)
		stop_fleeing(controller, resume_fight = FALSE)
		return
	// Wounds licked, or (unless it is a badly hurt slinger) a packmate came by: back to the fight
	if(pawn.get_ai_hurt_fraction() <= GOBLIN_RECOVERED_HURT || !should_run(pawn))
		stop_fleeing(controller, resume_fight = TRUE)
		return

	// Keep the attacker in mind, but don't let the fighting subtrees chase them
	controller.clear_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET)
	goblin_draw_stashed_weapon(controller)

	if(get_dist(pawn, threat) <= GOBLIN_SIGHT_RANGE && can_see(pawn, threat, GOBLIN_SIGHT_RANGE))
		controller.set_blackboard_key(BB_GOBLIN_HIDDEN_SINCE, 0)
		if(pawn.Adjacent(threat))
			var/cornered_since = controller.blackboard[BB_GOBLIN_CORNERED_SINCE]
			if(!cornered_since)
				controller.set_blackboard_key(BB_GOBLIN_CORNERED_SINCE, world.time)
			else if(world.time - cornered_since >= GOBLIN_CORNERED_TIME)
				// Nowhere left to run: fight like a rat in a corner
				pawn.balloon_alert_to_viewers("<font color='#c7c6c6'>cornered</font>", balloon_flag = DISABLE_BALLOON_COMBAT, y_offset = -8)
				stop_fleeing(controller, resume_fight = TRUE)
				controller.set_blackboard_key(BB_GOBLIN_NEXT_FLEE, world.time + GOBLIN_CORNERED_COOLDOWN)
				return
		else
			controller.set_blackboard_key(BB_GOBLIN_CORNERED_SINCE, 0)
		controller.queue_behavior(/datum/ai_behavior/run_away_from_target/goblin, BB_GOBLIN_THREAT, BB_GOBLIN_THREAT)
		return SUBTREE_RETURN_FINISH_PLANNING

	// Out of sight: lie low, then tend to the wounds
	controller.set_blackboard_key(BB_GOBLIN_CORNERED_SINCE, 0)
	if(!controller.blackboard[BB_GOBLIN_HIDDEN_SINCE])
		controller.set_blackboard_key(BB_GOBLIN_HIDDEN_SINCE, world.time)
	controller.queue_behavior(/datum/ai_behavior/goblin_lie_low, BB_GOBLIN_HIDDEN_SINCE)
	return SUBTREE_RETURN_FINISH_PLANNING

/// Hurt enough to run, given who is around?
/datum/ai_planning_subtree/goblin_survival/proc/should_run(mob/living/carbon/human/pawn)
	var/hurt = pawn.get_ai_hurt_fraction()
	if(hurt >= GOBLIN_SLINGER_FLEE_HURT && goblin_has_sling(pawn))
		return TRUE // a slinger has no business in a brawl this hurt
	if(hurt < GOBLIN_FLEE_HURT)
		return FALSE
	return !goblin_has_backup(pawn)

/datum/ai_planning_subtree/goblin_survival/proc/start_fleeing(datum/ai_controller/controller, mob/living/threat)
	controller.CancelActions()
	controller.set_blackboard_key(BB_GOBLIN_FLEEING, TRUE)
	controller.set_blackboard_key(BB_BASIC_MOB_FLEEING, TRUE)
	controller.set_blackboard_key(BB_GOBLIN_THREAT, threat)
	controller.set_blackboard_key(BB_GOBLIN_HIDDEN_SINCE, 0)
	controller.set_blackboard_key(BB_GOBLIN_CORNERED_SINCE, 0)

/datum/ai_planning_subtree/goblin_survival/proc/stop_fleeing(datum/ai_controller/controller, resume_fight)
	var/mob/living/threat = controller.blackboard[BB_GOBLIN_THREAT]
	controller.CancelActions()
	controller.set_blackboard_key(BB_GOBLIN_FLEEING, FALSE)
	controller.set_blackboard_key(BB_BASIC_MOB_FLEEING, FALSE)
	controller.clear_blackboard_key(BB_GOBLIN_THREAT)
	controller.set_blackboard_key(BB_GOBLIN_HIDDEN_SINCE, 0)
	controller.set_blackboard_key(BB_GOBLIN_CORNERED_SINCE, 0)
	controller.set_blackboard_key(BB_GOBLIN_NEXT_FLEE, max(controller.blackboard[BB_GOBLIN_NEXT_FLEE] || 0, world.time + GOBLIN_REFLEE_DELAY))
	if(resume_fight && !QDELETED(threat) && threat.stat != DEAD)
		controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, threat)

/// Runs from the remembered attacker; unlike the base flight it never forgets who that was
/datum/ai_behavior/run_away_from_target/goblin
	clear_failed_targets = FALSE

/// Stays put out of sight; once hidden long enough, licks its wounds
/datum/ai_behavior/goblin_lie_low
	action_cooldown = 2 SECONDS
	behavior_flags = AI_BEHAVIOR_CAN_PLAN_DURING_EXECUTION

/datum/ai_behavior/goblin_lie_low/perform(delta_time, datum/ai_controller/controller, hidden_since_key)
	. = ..()
	var/hidden_since = controller.blackboard[hidden_since_key]
	if(!hidden_since || world.time - hidden_since < GOBLIN_HIDE_TIME)
		finish_action(controller, TRUE, hidden_since_key)
		return
	var/mob/living/carbon/human/pawn = controller.pawn
	if(prob(25))
		pawn.visible_message(span_notice("[pawn] licks its wounds."))
	pawn.heal_overall_damage(4, 4)
	pawn.heal_wounds(6)
	pawn.adjustShockStage(-5)
	finish_action(controller, TRUE, hidden_since_key)

// ---------------- Pack roles ----------------

/datum/ai_planning_subtree/goblin_pack_role

/datum/ai_planning_subtree/goblin_pack_role/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/living/carbon/human/pawn = controller.pawn
	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(QDELETED(target))
		controller.set_blackboard_key(BB_GOBLIN_ROLE, GOBLIN_ROLE_BRAWLER)
		return

	// Slingers only sling with a packmate around to keep the foe busy
	if(goblin_has_sling(pawn) && goblin_has_backup(pawn, GOBLIN_PACK_RANGE))
		controller.set_blackboard_key(BB_GOBLIN_ROLE, GOBLIN_ROLE_SLINGER)
		return

	var/pack_size = 1
	for(var/mob/living/carbon/human/other in view(GOBLIN_PACK_RANGE, pawn))
		if(!is_goblin_packmate(pawn, other))
			continue
		var/datum/ai_controller/other_controller = other.ai_controller
		if(other_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] != target || other_controller.blackboard[BB_GOBLIN_FLEEING])
			continue
		pack_size++

	var/role = GOBLIN_ROLE_BRAWLER
	if(pack_size >= 3 && !goblin_has_shield(pawn))
		role = GOBLIN_ROLE_HARASSER
	controller.set_blackboard_key(BB_GOBLIN_ROLE, role)

/// Harassers fight hit-and-run even when unhurt
/datum/ai_planning_subtree/wounded_harass/goblin

/datum/ai_planning_subtree/wounded_harass/goblin/wants_to_harass(datum/ai_controller/controller, mob/living/carbon/human/pawn)
	if(controller.blackboard[BB_GOBLIN_ROLE] == GOBLIN_ROLE_HARASSER)
		return TRUE
	if(goblin_has_shield(pawn) || controller.blackboard[BB_GOBLIN_ROLE] == GOBLIN_ROLE_SLINGER)
		return FALSE // shield bearers hold the line; slingers keep their distance on their own
	return ..()

/// The sling only comes out while the goblin is a slinger; otherwise the knife goes back in hand
/datum/ai_planning_subtree/ranged_attack_subtree/goblin

/datum/ai_planning_subtree/ranged_attack_subtree/goblin/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(controller.blackboard[BB_GOBLIN_ROLE] != GOBLIN_ROLE_SLINGER)
		goblin_draw_stashed_weapon(controller)
		return
	return ..()

#undef BB_GOBLIN_ROLE
#undef BB_GOBLIN_FLEEING
#undef BB_GOBLIN_THREAT
#undef BB_GOBLIN_HIDDEN_SINCE
#undef BB_GOBLIN_CORNERED_SINCE
#undef BB_GOBLIN_NEXT_FLEE
#undef GOBLIN_ROLE_BRAWLER
#undef GOBLIN_ROLE_HARASSER
#undef GOBLIN_ROLE_SLINGER
#undef GOBLIN_PACK_RANGE
#undef GOBLIN_BACKUP_RANGE
#undef GOBLIN_SIGHT_RANGE
#undef GOBLIN_FLEE_HURT
#undef GOBLIN_SLINGER_FLEE_HURT
#undef GOBLIN_RECOVERED_HURT
#undef GOBLIN_HIDE_TIME
#undef GOBLIN_CORNERED_TIME
#undef GOBLIN_CORNERED_COOLDOWN
#undef GOBLIN_REFLEE_DELAY
