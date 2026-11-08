// RMH EDIT: the Dragoon's techniques and the Acrobat trait.
// - Full Thrust: dash 2-5 tiles toward the target, then a thrust that strikes the two tiles ahead for
//   extra damage with the held polearm.
// - Elusive Jump: a quick, slowing strike at the tile ahead, then a flip up to 4 tiles back through enemies.
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
	L.visible_message(span_danger("[L] surges forward, polearm leveled!"), span_danger("Full thrust!"))
	INVOKE_ASYNC(src, PROC_REF(do_thrust), L, cast_on)

/// Dashes 2 to 5 tiles toward the target, always stopping right in front of it, then thrusts.
/datum/action/cooldown/spell/dragoon_full_thrust/proc/do_thrust(mob/living/L, atom/target)
	var/turf/target_turf = get_turf(target)
	var/moved = 0
	while(moved < 5)
		if(QDELETED(L) || L.stat || L.body_position == LYING_DOWN)
			return
		if(!QDELETED(target) && ismovable(target))
			target_turf = get_turf(target) // follow a moving target
		if(get_dist(L, target_turf) <= 1 && moved >= 2)
			break
		if(get_dist(L, target_turf) <= 1) // already in front: keep the facing, the thrust still lands
			break
		var/turf/next = get_step_towards(L, target_turf)
		if(!next || next == target_turf || next.density || (locate(/mob/living) in next))
			break
		var/turf/before = get_turf(L)
		L.Move(next, get_dir(before, next))
		if(get_turf(L) == before)
			break
		moved++
		new /obj/effect/temp_visual/decoy/fading/afterimage(before, L)
		sleep(1)
	if(QDELETED(L) || L.stat)
		return
	var/obj/item/weapon/polearm/P = L.get_dragoon_polearm()
	if(!P)
		return
	var/thrust_dir = get_dir(L, target_turf) || L.dir
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
	desc = "A quick jab that slows whoever stands before you, then a flip 4 tiles backwards, over anyone in the way, \
	until something solid stops you. Requires a polearm in hand."
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
			if(cast_on.dragoon_strike(victim, P, DRAGOON_QUICK_MULT))
				victim.apply_status_effect(/datum/status_effect/debuff/hobbled, 4 SECONDS)
			break
	cast_on.visible_message(span_notice("[cast_on] strikes and flips away!"), span_notice("I strike and leap back!"))
	INVOKE_ASYNC(src, PROC_REF(do_leap), cast_on, cast_on.dir)

/// Flips up to 4 tiles backwards, passing through anyone in the way, until something solid stops it.
/datum/action/cooldown/spell/undirected/dragoon_elusive_jump/proc/do_leap(mob/living/L, facing)
	var/back_dir = REVERSE_DIR(facing)
	var/matrix/old_transform = L.transform
	var/old_pixel_z = L.pixel_z
	var/flip = (facing & (SOUTH|WEST)) ? -90 : 90
	animate(L, pixel_z = old_pixel_z + 8, transform = turn(old_transform, flip), time = 2, flags = ANIMATION_PARALLEL)
	animate(transform = turn(old_transform, flip * 2), time = 2)
	animate(transform = turn(old_transform, flip * 3), time = 2)
	animate(pixel_z = old_pixel_z, transform = old_transform, time = 2)
	playsound(L, 'sound/combat/shove.ogg', 60, TRUE)
	var/turf/last_free = get_turf(L)
	for(var/i in 1 to 4)
		if(QDELETED(L) || L.stat)
			break
		var/turf/next = get_step(L, back_dir)
		if(!next || next.density || isopenspace(next))
			break
		var/blocked = FALSE
		for(var/obj/O in next)
			if(O.density && !(O.flags_1 & ON_BORDER_1))
				blocked = TRUE
				break
		if(blocked)
			break
		var/turf/before = get_turf(L)
		new /obj/effect/temp_visual/decoy/fading/afterimage(before, L)
		L.forceMove(next) // leaps over anyone in the way
		L.setDir(facing)
		var/occupied = FALSE
		for(var/mob/living/other in next)
			if(other != L && other.density)
				occupied = TRUE
				break
		if(!occupied)
			last_free = next
		sleep(1)
	if(!QDELETED(L))
		if(get_turf(L) != last_free) // never land on top of someone
			L.forceMove(last_free)
		L.setDir(facing)
		if(isopenturf(L.loc))
			var/turf/open/landing = L.loc
			if(landing.landsound)
				playsound(landing, landing.landsound, 100, FALSE)

// ---------------- Acrobat ----------------

/mob/living/proc/acrobat_jump_bonus()
	return HAS_TRAIT(src, TRAIT_ACROBAT) ? 1 : 0

#undef DRAGOON_THRUST_MULT
#undef DRAGOON_QUICK_MULT
