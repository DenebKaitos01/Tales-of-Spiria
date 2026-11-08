// RMH EDIT: the Dragoon's techniques and the Acrobat trait.
// - Full Thrust: dash 2-5 tiles toward the target, then a thrust that strikes the two tiles ahead for
//   extra damage with the held polearm.
// - Elusive Jump: a quick strike at the tile ahead, then a leap 2-4 tiles backwards.
// - Acrobat (TRAIT_ACROBAT): no damage from a fall of one level, and jumps reach a tile further.

#define DRAGOON_THRUST_MULT 1.5
#define DRAGOON_QUICK_MULT 0.8

/// The polearm a Dragoon technique is performed with, if they hold one
/mob/living/proc/get_dragoon_polearm()
	var/obj/item/weapon/polearm/P = get_active_held_item()
	if(istype(P))
		return P
	P = get_inactive_held_item()
	if(istype(P))
		return P
	return null

/// One technique strike against a living target, with the polearm's force times `mult`. The target may still defend.
/mob/living/proc/dragoon_strike(mob/living/victim, obj/item/weapon/polearm/P, mult)
	if(!victim || victim == src || victim.stat == DEAD)
		return FALSE
	do_attack_animation(victim, visual_effect_icon = used_intent?.animname, used_item = P)
	if(victim.checkdefense(used_intent, src))
		return FALSE
	var/base = HAS_TRAIT(P, TRAIT_WIELDED) && P.force_wielded ? P.force_wielded : P.force
	var/damage = round(base * mult)
	var/zone = check_zone(zone_selected) || BODY_ZONE_CHEST
	var/armor = victim.run_armor_check(zone, "stab", armor_penetration = P.armor_penetration, damage = damage, used_weapon = P, attacker = src, used_intent = used_intent)
	victim.apply_damage(damage, BRUTE, zone, armor)
	playsound(victim, 'sound/combat/hits/bladed/genstab (1).ogg', 100, TRUE)
	log_combat(src, victim, "struck with a dragoon technique", P)
	return TRUE

// ---------------- Full Thrust ----------------

/datum/action/cooldown/spell/dragoon_full_thrust
	name = "Full Thrust"
	desc = "Dash 2 to 5 tiles toward your target and drive your polearm through the two tiles ahead of you \
	with greatly increased force. Requires a polearm in hand."
	button_icon_state = "bcry"
	sound = 'sound/combat/shove.ogg'
	antimagic_flags = NONE
	associated_skill = /datum/attribute/skill/combat/polearms
	associated_stat = STAT_STRENGTH
	charge_required = FALSE
	has_visual_effects = FALSE
	self_cast_possible = FALSE
	cast_range = 6
	cooldown_time = 25 SECONDS
	spell_type = SPELL_STAMINA
	spell_cost = 25

/datum/action/cooldown/spell/dragoon_full_thrust/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return
	var/mob/living/L = owner
	if(!isliving(L) || L.body_position == LYING_DOWN || L.buckled || L.incapacitated(IGNORE_GRAB))
		return FALSE
	if(!L.get_dragoon_polearm())
		to_chat(L, span_warning("I need a polearm in hand for that."))
		return FALSE
	if(get_turf(cast_on) == get_turf(L) || cast_on.z != L.z)
		return FALSE
	return TRUE

/datum/action/cooldown/spell/dragoon_full_thrust/cast(atom/cast_on)
	. = ..()
	var/mob/living/L = owner
	var/thrust_dir = get_dir(L, cast_on)
	var/travel = clamp(get_dist(L, cast_on) - 1, 2, 5)
	L.visible_message(span_danger("[L] surges forward, polearm leveled!"), span_danger("Full thrust!"))
	INVOKE_ASYNC(src, PROC_REF(do_thrust), L, thrust_dir, travel)

/datum/action/cooldown/spell/dragoon_full_thrust/proc/do_thrust(mob/living/L, thrust_dir, travel)
	L.setDir(thrust_dir)
	for(var/i in 1 to travel)
		if(QDELETED(L) || L.stat || L.body_position == LYING_DOWN)
			return
		var/turf/next = get_step(L, thrust_dir)
		if(!next || next.density || (locate(/mob/living) in next))
			break
		var/turf/before = get_turf(L)
		L.Move(next, thrust_dir)
		if(get_turf(L) == before)
			break
		new /obj/effect/temp_visual/decoy/fading/halfsecond(before, L)
		sleep(1)
	if(QDELETED(L) || L.stat)
		return
	var/obj/item/weapon/polearm/P = L.get_dragoon_polearm()
	if(!P)
		return
	L.setDir(thrust_dir)
	var/turf/reach = get_turf(L)
	for(var/i in 1 to 2)
		reach = get_step(reach, thrust_dir)
		if(!reach || reach.density)
			break
		for(var/mob/living/victim in reach)
			L.dragoon_strike(victim, P, DRAGOON_THRUST_MULT)
	L.changeNext_move(CLICK_CD_MELEE)

// ---------------- Elusive Jump ----------------

/datum/action/cooldown/spell/undirected/dragoon_elusive_jump
	name = "Elusive Jump"
	desc = "A quick jab at whoever stands before you, then leap 2 to 4 tiles backwards out of reach. \
	The better your athletics, the further you leap. Requires a polearm in hand."
	button_icon_state = "bcry"
	sound = null
	antimagic_flags = NONE
	associated_skill = /datum/attribute/skill/misc/athletics
	associated_stat = STAT_SPEED
	charge_required = FALSE
	has_visual_effects = FALSE
	cooldown_time = 20 SECONDS
	spell_type = SPELL_STAMINA
	spell_cost = 20

/datum/action/cooldown/spell/undirected/dragoon_elusive_jump/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return
	var/mob/living/L = owner
	if(!isliving(L) || L.body_position == LYING_DOWN || L.buckled || L.incapacitated(IGNORE_GRAB) || L.usable_legs < 2)
		return FALSE
	if(L.pulledby && L.pulledby != L)
		to_chat(L, span_warning("I'm being held!"))
		return FALSE
	if(!L.get_dragoon_polearm())
		to_chat(L, span_warning("I need a polearm in hand for that."))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/undirected/dragoon_elusive_jump/cast(mob/living/cast_on)
	. = ..()
	var/obj/item/weapon/polearm/P = cast_on.get_dragoon_polearm()
	var/turf/front = get_step(cast_on, cast_on.dir)
	if(front)
		for(var/mob/living/victim in front)
			cast_on.dragoon_strike(victim, P, DRAGOON_QUICK_MULT)
			break
	var/athletics = floor(GET_MOB_SKILL_VALUE(cast_on, /datum/attribute/skill/misc/athletics) / 10)
	var/range = clamp(2 + floor(athletics / 2), 2, 4)
	var/turf/landing = get_ranged_target_turf(cast_on, REVERSE_DIR(cast_on.dir), range)
	if(!landing)
		return
	var/facing = cast_on.dir
	cast_on.visible_message(span_notice("[cast_on] strikes and springs back!"), span_notice("I strike and leap back!"))
	cast_on.jump_action_resolve(landing, 10, range, FALSE)
	cast_on.setDir(facing) // keep facing the enemy

// ---------------- Acrobat ----------------

/mob/living/proc/acrobat_jump_bonus()
	return HAS_TRAIT(src, TRAIT_ACROBAT) ? 1 : 0

#undef DRAGOON_THRUST_MULT
#undef DRAGOON_QUICK_MULT
