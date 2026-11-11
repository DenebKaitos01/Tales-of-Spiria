// RMH EDIT: shared combat aggro.
// A fight is a /datum/combat_encounter: every combatant in it (players and NPCs, any side) holds one threat value
// in a shared pool. Everyone starts a fresh fight at 0; whoever joins a fight already under way starts at the pool's
// average. Aggressive acts (hits, shots, spells, miracles, scripted threat) raise the actor's threat.
// NPCs with an /datum/component/ai_aggro_system read the pool to pick their target: they only pick foes they can see,
// and spread out in proportion to threat (a foe holding 70% of the threat draws about 70% of the enemies).
// Fights far apart are separate encounters; when they touch, they merge.
// Every step is written to the combat_aggro log (data/logs/<round>/combat_aggro.log).

/// Threat for landing a hit: base plus half the damage
#define COMBAT_THREAT_HIT_BASE 5
#define COMBAT_THREAT_HIT_DAMAGE_MULT 0.5
/// Threat for casting a spell or miracle in a fight (harmful or helpful)
#define COMBAT_THREAT_SPELL 10
/// A combatant this far from everyone else in the fight leaves it
#define COMBAT_ENCOUNTER_LEASH 14
/// A fight with no threat gained and nobody engaged for this long ends
#define COMBAT_ENCOUNTER_TIMEOUT (45 SECONDS)
/// How often an NPC looks around for foes that wandered into the fight
#define COMBAT_ENCOUNTER_SWEEP_COOLDOWN (3 SECONDS)
/// A better-suited foe must be short at least this many enemies before an NPC switches to them
#define COMBAT_ENCOUNTER_SWITCH_MARGIN 1

#define BB_COMBAT_SWEEP_NEXT "combat_sweep_next"

GLOBAL_VAR_INIT(combat_encounter_count, 0)

/mob/living
	/// The fight this mob is part of, if any
	var/datum/combat_encounter/combat_encounter

/// Multiplier on all threat this mob generates. Traits and abilities that draw or shed attention hook in here.
/mob/living/proc/get_combat_threat_modifier()
	return 1

/proc/log_combat_aggro(text)
	WRITE_LOG(GLOB.world_combat_aggro_log, "\[[TIMETOTEXT4LOGS]\] [text]")

/datum/combat_encounter
	/// Number for the log
	var/id
	/// mob/living -> threat
	var/list/threat = list()
	/// When something last happened in this fight
	var/last_activity = 0

/datum/combat_encounter/New()
	. = ..()
	id = ++GLOB.combat_encounter_count
	last_activity = world.time
	START_PROCESSING(SSaggro, src)

/datum/combat_encounter/Destroy(force)
	STOP_PROCESSING(SSaggro, src)
	for(var/mob/living/member as anything in threat.Copy())
		drop_member(member)
	threat = null
	return ..()

/datum/combat_encounter/proc/describe(mob/living/member)
	return "[member] ([member.ckey ? member.ckey : "npc"])"

/// The pool's average threat, what a newcomer starts at
/datum/combat_encounter/proc/average_threat()
	if(!length(threat))
		return 0
	var/total = 0
	for(var/mob/living/member as anything in threat)
		total += threat[member]
	return total / length(threat)

/// Brings a mob into the fight at the pool's average threat
/datum/combat_encounter/proc/add_member(mob/living/joiner, reason)
	if(QDELETED(joiner) || (joiner in threat))
		return
	if(joiner.combat_encounter && joiner.combat_encounter != src)
		merge(joiner.combat_encounter)
		return
	var/start = round(average_threat(), 0.1)
	threat[joiner] = start
	joiner.combat_encounter = src
	RegisterSignal(joiner, COMSIG_PARENT_QDELETING, PROC_REF(on_member_deleted))
	if(!joiner.GetComponent(/datum/component/ai_aggro_system))
		// Anyone the NPCs can hit also reports who hits them, so NPC aggression lands in the pool too
		joiner.AddElement(/datum/element/relay_attackers)
		RegisterSignal(joiner, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_member_attacked))
	last_activity = world.time
	log_combat_aggro("#[id] JOIN [describe(joiner)] at [start] ([reason])")

/// Takes a mob out of the fight without logging
/datum/combat_encounter/proc/drop_member(mob/living/member)
	UnregisterSignal(member, list(COMSIG_PARENT_QDELETING, COMSIG_ATOM_WAS_ATTACKED))
	if(member.combat_encounter == src)
		member.combat_encounter = null
	threat -= member

/datum/combat_encounter/proc/remove_member(mob/living/member, reason)
	if(!(member in threat))
		return
	log_combat_aggro("#[id] LEAVE [describe(member)] with [threat[member]] ([reason])")
	drop_member(member)

/datum/combat_encounter/proc/on_member_deleted(mob/living/source)
	SIGNAL_HANDLER
	drop_member(source)

/// A member without an aggro board was hit: the attacker gains threat
/datum/combat_encounter/proc/on_member_attacked(mob/living/victim, atom/attacker, damage)
	SIGNAL_HANDLER
	if(!isliving(attacker) || attacker == victim)
		return
	add_combat_threat(attacker, COMBAT_THREAT_HIT_BASE + damage * COMBAT_THREAT_HIT_DAMAGE_MULT, "hit [victim]", victim)

/// Folds another fight into this one; everyone keeps the threat they earned
/datum/combat_encounter/proc/merge(datum/combat_encounter/other)
	if(other == src || QDELETED(other))
		return
	log_combat_aggro("#[id] MERGE with #[other.id] ([length(other.threat)] combatants)")
	for(var/mob/living/member as anything in other.threat.Copy())
		var/earned = other.threat[member]
		other.drop_member(member)
		if(member in threat)
			threat[member] = max(threat[member], earned)
			continue
		threat[member] = earned
		member.combat_encounter = src
		RegisterSignal(member, COMSIG_PARENT_QDELETING, PROC_REF(on_member_deleted))
		if(!member.GetComponent(/datum/component/ai_aggro_system))
			member.AddElement(/datum/element/relay_attackers)
			RegisterSignal(member, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_member_attacked))
	last_activity = world.time
	qdel(other)

/datum/combat_encounter/proc/gain_threat(mob/living/actor, amount, reason)
	if(!(actor in threat))
		add_member(actor, reason)
	amount = round(amount * actor.get_combat_threat_modifier(), 0.1)
	threat[actor] = max(0, threat[actor] + amount)
	last_activity = world.time
	log_combat_aggro("#[id] THREAT [describe(actor)] +[amount] = [threat[actor]] ([reason])")
	// Keep the NPC boards' mirrored values current
	for(var/mob/living/member as anything in threat)
		var/list/board = member.ai_controller?.blackboard[BB_MOB_AGGRO_TABLE]
		if(board && !isnull(board[actor]))
			board[actor] = threat[actor]

/// Periodic cleanup: the dead, the departed and the finished fight
/datum/combat_encounter/process()
	for(var/mob/living/member as anything in threat.Copy())
		if(member.stat == DEAD)
			remove_member(member, "dead")
			continue
		var/near_anyone = FALSE
		for(var/mob/living/other as anything in threat)
			if(other == member || other.z != member.z)
				continue
			if(get_dist(member, other) <= COMBAT_ENCOUNTER_LEASH)
				near_anyone = TRUE
				break
		if(!near_anyone)
			remove_member(member, "left the fight")

	var/engaged = FALSE
	for(var/mob/living/member as anything in threat)
		var/atom/target = member.ai_controller?.blackboard[BB_HIGHEST_THREAT_MOB]
		if(target && (target in threat))
			engaged = TRUE
			break
	if(engaged)
		last_activity = world.time

	if(length(threat) < 2 || world.time - last_activity > COMBAT_ENCOUNTER_TIMEOUT)
		end_encounter()

/datum/combat_encounter/proc/end_encounter()
	var/list/summary = list()
	for(var/mob/living/member as anything in threat)
		summary += "[member]: [threat[member]]"
	log_combat_aggro("#[id] END ([length(summary) ? jointext(summary, ", ") : "no one left"])")
	qdel(src)

/// Chooses the target for an NPC in this fight and writes it to BB_HIGHEST_THREAT_MOB
/datum/combat_encounter/proc/pick_target_for(mob/living/npc, datum/component/ai_aggro_system/board_owner)
	var/datum/ai_controller/controller = npc.ai_controller
	if(!controller)
		return
	var/list/board = controller.blackboard[BB_MOB_AGGRO_TABLE]
	if(!board)
		board = list()
		controller.blackboard[BB_MOB_AGGRO_TABLE] = board
	var/datum/targetting_datum/targetting = controller.blackboard[BB_TARGETTING_DATUM]
	var/aggro_range = controller.blackboard[BB_AGGRO_RANGE] || 9
	var/mob/living/current = controller.blackboard[BB_HIGHEST_THREAT_MOB]

	// Foes that walked into view join the fight
	if(world.time >= controller.blackboard[BB_COMBAT_SWEEP_NEXT])
		controller.blackboard[BB_COMBAT_SWEEP_NEXT] = world.time + COMBAT_ENCOUNTER_SWEEP_COOLDOWN
		for(var/mob/living/seen in view(aggro_range, npc))
			if(seen == npc || seen.stat == DEAD || (seen in threat))
				continue
			if(!targetting?.can_attack(npc, seen))
				continue
			add_member(seen, "spotted by [npc]")

	// Everyone in the fight this NPC can see and would fight is on its board
	for(var/mob/living/member as anything in threat)
		if(member == npc || !isnull(board[member]))
			continue
		if(get_dist(npc, member) > aggro_range || !can_see(npc, member, aggro_range))
			continue
		if(targetting && !targetting.can_attack(npc, member))
			continue
		board[member] = threat[member]

	// Prune and gather the foes it can pick: anyone it sees, or the one it is already after
	var/list/candidates = list()
	for(var/mob/living/foe as anything in board.Copy())
		if(!board_owner.is_valid_threat_target(npc, foe))
			board -= foe
			continue
		if(!(foe in threat))
			add_member(foe, "on [npc]'s board")
		board[foe] = threat[foe]
		if(foe != current && (get_dist(npc, foe) > aggro_range || !can_see(npc, foe, aggro_range)))
			continue
		candidates += foe

	if(!length(candidates))
		if(current)
			controller.clear_blackboard_key(BB_HIGHEST_THREAT_MOB)
		return

	// Whoever is grabbing us comes first
	var/mob/living/grabber = npc.pulledby
	if(grabber && (grabber in candidates))
		set_target(npc, controller, grabber, "grabbed")
		return

	// Split the NPCs on this fight in proportion to the threat each foe holds
	var/total = 0
	for(var/mob/living/foe as anything in candidates)
		total += threat[foe]
	var/list/assigned = list()
	var/npc_count = 1
	for(var/mob/living/member as anything in threat)
		if(member == npc || member.client || member.stat != CONSCIOUS)
			continue
		var/atom/their_target = member.ai_controller?.blackboard[BB_HIGHEST_THREAT_MOB]
		if(!their_target || !(their_target in threat))
			continue
		npc_count++
		assigned[their_target] += 1

	var/mob/living/best
	var/best_deficit
	var/current_deficit
	for(var/mob/living/foe as anything in candidates)
		var/share = total ? threat[foe] / total : 1 / length(candidates)
		var/deficit = share * npc_count - (assigned[foe] || 0)
		if(foe == current)
			current_deficit = deficit
		if(isnull(best_deficit) || deficit > best_deficit || (deficit == best_deficit && get_dist(npc, foe) < get_dist(npc, best)))
			best = foe
			best_deficit = deficit

	if(current && !isnull(current_deficit) && best_deficit - current_deficit < COMBAT_ENCOUNTER_SWITCH_MARGIN)
		best = current
	set_target(npc, controller, best, "share [round(best_deficit, 0.01)] of [npc_count] npcs")

/datum/combat_encounter/proc/set_target(mob/living/npc, datum/ai_controller/controller, mob/living/target, why)
	if(controller.blackboard[BB_HIGHEST_THREAT_MOB] == target)
		return
	controller.set_blackboard_key(BB_HIGHEST_THREAT_MOB, target)
	SEND_SIGNAL(npc, COMSIG_AI_GENERAL_CHANGE, "Threat Changed: [target]")
	last_activity = world.time
	log_combat_aggro("#[id] TARGET [describe(npc)] -> [describe(target)] (threat [threat[target]], [why])")

/// Puts actor (and whoever they acted on) in a fight and raises actor's threat.
/// related: the other side of the act; links the two fights, or starts one. Returns the encounter or null.
/proc/add_combat_threat(mob/living/actor, amount, reason, mob/living/related)
	if(QDELETED(actor) || actor.stat == DEAD)
		return null
	var/datum/combat_encounter/encounter = link_combatants(actor, related, reason)
	if(!encounter)
		return null
	encounter.gain_threat(actor, amount, reason)
	return encounter

/// Makes sure both mobs share a fight, starting or merging one as needed. related may be null.
/proc/link_combatants(mob/living/actor, mob/living/related, reason)
	if(!isliving(related) || related == actor || QDELETED(related))
		related = null
	var/datum/combat_encounter/encounter = actor.combat_encounter || related?.combat_encounter
	if(!encounter)
		if(!related)
			return null // a lone act starts no fight
		encounter = new
		log_combat_aggro("#[encounter.id] START [encounter.describe(actor)] vs [encounter.describe(related)] ([reason])")
	if(related?.combat_encounter && related.combat_encounter != encounter)
		encounter.merge(related.combat_encounter)
	if(actor.combat_encounter && actor.combat_encounter != encounter)
		encounter.merge(actor.combat_encounter)
	encounter.add_member(actor, reason)
	if(related)
		encounter.add_member(related, reason)
	return encounter

/// Spells and miracles cast in a fight raise the caster's threat, helpful or not
/proc/combat_threat_from_spell(mob/living/caster, datum/action/cooldown/spell/spell, atom/cast_on)
	if(!isliving(caster))
		return
	var/mob/living/living_target = isliving(cast_on) && cast_on != caster ? cast_on : null
	if(!caster.combat_encounter && !living_target?.combat_encounter)
		return // not a fight
	var/kind = spell.spell_type == SPELL_MIRACLE ? "miracle" : "spell"
	add_combat_threat(caster, COMBAT_THREAT_SPELL, "[kind] [spell.name][living_target ? " on [living_target]" : ""]", living_target)

// ---------------- The NPC aggro board, backed by the shared pool ----------------

/datum/component/ai_aggro_system/add_threat(mob/victim, mob/attacker, amount, reason = "attack")
	if(!isliving(victim) || !isliving(attacker) || !victim.ai_controller)
		return ..()
	var/mob/living/living_victim = victim
	var/datum/combat_encounter/encounter = add_combat_threat(attacker, amount, reason == "attack" ? "attacked [victim]" : reason, living_victim)
	if(!encounter)
		return
	var/list/board = living_victim.ai_controller.blackboard[BB_MOB_AGGRO_TABLE]
	if(!board)
		board = list()
		living_victim.ai_controller.blackboard[BB_MOB_AGGRO_TABLE] = board
	board[attacker] = encounter.threat[attacker]
	if(!living_victim.ai_controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET] && is_valid_threat_target(living_victim, attacker))
		living_victim.ai_controller.set_blackboard_key(BB_BASIC_MOB_CURRENT_TARGET, attacker)
	update_highest_threat(living_victim)
	living_victim.ai_controller.recalculate_idle()

/datum/component/ai_aggro_system/add_threat_to_mob(mob/target, amount)
	if(!target || !parent)
		return
	add_threat(parent, target, amount, "scripted threat")

/// Scripted "go after this one" (ambushes, waves, calls for help): joins the fight without inflating anyone's threat
/datum/component/ai_aggro_system/add_threat_to_mob_capped(mob/target, amount, cap)
	notice_target(target)

/// Puts a foe on this NPC's board and in its fight, at whatever threat the fight already gives them
/datum/component/ai_aggro_system/proc/notice_target(mob/living/target)
	var/mob/living/living_mob = parent
	if(!isliving(target) || !living_mob?.ai_controller || target == living_mob)
		return
	var/datum/combat_encounter/encounter = link_combatants(living_mob, target, "noticed by [living_mob]")
	var/list/board = living_mob.ai_controller.blackboard[BB_MOB_AGGRO_TABLE]
	if(!board)
		board = list()
		living_mob.ai_controller.blackboard[BB_MOB_AGGRO_TABLE] = board
	board[target] = encounter.threat[target]
	update_highest_threat(living_mob)
	living_mob.ai_controller.recalculate_idle()

/datum/component/ai_aggro_system/update_highest_threat(mob/living/source)
	if(!source?.combat_encounter)
		return ..()
	source.combat_encounter.pick_target_for(source, src)

/datum/component/ai_aggro_system/process()
	var/mob/living/living_mob = parent
	if(!living_mob?.combat_encounter)
		return ..()
	// Threat holds for the whole fight: no decay, just re-check who to fight
	update_highest_threat(living_mob)

/datum/component/ai_aggro_system/on_death(mob/living/source)
	. = ..()
	source.combat_encounter?.remove_member(source, "dead")

/// Re-balance every time the NPC looks for targets, not just when its board changes
/datum/ai_behavior/find_aggro_targets/perform(seconds_per_tick, datum/ai_controller/controller, target_key, targetting_datum_key, hiding_location_key)
	var/mob/living/living_mob = controller.pawn
	if(living_mob?.combat_encounter)
		var/datum/component/ai_aggro_system/board_owner = living_mob.GetComponent(/datum/component/ai_aggro_system)
		board_owner?.update_highest_threat(living_mob)
	return ..()

#undef COMBAT_THREAT_HIT_BASE
#undef COMBAT_THREAT_HIT_DAMAGE_MULT
#undef COMBAT_THREAT_SPELL
#undef COMBAT_ENCOUNTER_LEASH
#undef COMBAT_ENCOUNTER_TIMEOUT
#undef COMBAT_ENCOUNTER_SWEEP_COOLDOWN
#undef COMBAT_ENCOUNTER_SWITCH_MARGIN
#undef BB_COMBAT_SWEEP_NEXT
