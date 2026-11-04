// RMH EDIT: an AI Broodmother (quest boss, desert map) used to fight like a plain troll.
// Without a player it now uses its own kit: frenzy, earthquake up close, acid vomit and rock throws at range,
// and it lays goblin eggs while fighting.

#define BB_BROOD_QUAKE "BB_brood_quake"
#define BB_BROOD_ACID "BB_brood_acid"
/// Time between eggs an AI Broodmother lays in a fight
#define BROOD_AI_EGG_INTERVAL (45 SECONDS)
/// Hatched children an AI Broodmother keeps alive at once
#define BROOD_AI_MAX_CHILDREN 4

/mob/living/simple_animal/hostile/retaliate/troll/broodmother
	ai_controller = /datum/ai_controller/troll/broodmother
	/// world.time of the next egg while AI controlled
	var/ai_next_egg = 0
	/// Weakrefs to the children hatched from AI-laid eggs
	var/list/ai_children = list()

/mob/living/simple_animal/hostile/retaliate/troll/broodmother/Initialize()
	. = ..()
	if(!ai_controller)
		return
	ai_controller.set_blackboard_key(BB_TARGETED_ACTION, locate(/datum/action/cooldown/spell/stone_throw) in actions)
	ai_controller.set_blackboard_key(BB_BROOD_ACID, locate(/datum/action/cooldown/spell/projectile/acid_splash_broodmother) in actions)
	ai_controller.set_blackboard_key(BB_BROOD_QUAKE, locate(/datum/action/cooldown/mob_cooldown/earth_quake) in actions)

/// Children from AI-laid eggs that are still alive
/mob/living/simple_animal/hostile/retaliate/troll/broodmother/proc/count_ai_children()
	. = 0
	for(var/datum/weakref/child_ref as anything in ai_children.Copy())
		var/mob/living/child = child_ref.resolve()
		if(QDELETED(child) || child.stat == DEAD)
			ai_children -= child_ref
			continue
		.++

/// Lays a goblin egg without spending biomass; the hatchling is tracked against the AI cap
/mob/living/simple_animal/hostile/retaliate/troll/broodmother/proc/ai_lay_egg()
	var/obj/structure/broodmother_egg/goblin/made_egg = new(get_turf(src))
	made_egg.mother_weak_ref = WEAKREF(src)
	made_egg.ai_mother = TRUE
	visible_message(span_danger("[src] heaves and lays a pulsing egg!"))

/obj/structure/broodmother_egg
	/// Laid by an AI Broodmother, which counts the hatchling toward its cap
	var/ai_mother = FALSE

/obj/structure/broodmother_egg/hatch()
	. = ..()
	if(!ai_mother)
		return
	var/mob/living/simple_animal/hostile/retaliate/troll/broodmother/mother = mother_weak_ref?.resolve()
	if(!istype(mother))
		return
	for(var/mob/living/child in get_turf(src))
		if(istype(child, type_to_spawn))
			mother.ai_children += WEAKREF(child)
			break

/datum/ai_controller/troll/broodmother
	planning_subtrees = list(
		/datum/ai_planning_subtree/aggro_find_target,
		/datum/ai_planning_subtree/broodmother_abilities,
		/datum/ai_planning_subtree/basic_melee_attack_subtree,

		/datum/ai_planning_subtree/find_dead_bodies,
		/datum/ai_planning_subtree/eat_dead_body,
	)

/datum/ai_planning_subtree/broodmother_abilities

/datum/ai_planning_subtree/broodmother_abilities/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	var/mob/living/simple_animal/hostile/retaliate/troll/broodmother/mother = controller.pawn
	var/mob/living/target = controller.blackboard[BB_BASIC_MOB_CURRENT_TARGET]
	if(!istype(mother) || QDELETED(target) || !isliving(target) || target.stat == DEAD)
		return

	if(mother.frenzy_ready)
		mother.frenzy_on()

	if(world.time >= mother.ai_next_egg && mother.count_ai_children() < BROOD_AI_MAX_CHILDREN)
		mother.ai_next_egg = world.time + BROOD_AI_EGG_INTERVAL
		mother.ai_lay_egg()

	var/distance = get_dist(mother, target)
	var/ability_key
	if(distance <= 2 && is_ready(controller, BB_BROOD_QUAKE))
		ability_key = BB_BROOD_QUAKE
	else if(distance >= 3 && is_ready(controller, BB_BROOD_ACID))
		ability_key = BB_BROOD_ACID
	else if(distance >= 2 && is_ready(controller, BB_TARGETED_ACTION))
		ability_key = BB_TARGETED_ACTION
	if(!ability_key)
		return

	controller.queue_behavior(/datum/ai_behavior/targeted_mob_ability, ability_key, BB_BASIC_MOB_CURRENT_TARGET)
	return SUBTREE_RETURN_FINISH_PLANNING

/datum/ai_planning_subtree/broodmother_abilities/proc/is_ready(datum/ai_controller/controller, ability_key)
	var/datum/action/cooldown/ability = controller.blackboard[ability_key]
	return !QDELETED(ability) && ability.IsAvailable()

#undef BB_BROOD_QUAKE
#undef BB_BROOD_ACID
#undef BROOD_AI_EGG_INTERVAL
#undef BROOD_AI_MAX_CHILDREN
