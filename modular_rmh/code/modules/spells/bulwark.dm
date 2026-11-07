// RMH EDIT: Bulwark, the Ironclad's ability (inspired by Azure Peak's Malum reinforcement).
// For a while, every blow that wears down my armor knocks a fragment of it loose. The fragment lands
// behind me; walking over it or picking it up repairs every armored piece I wear a little.
// Anyone else stepping on it crushes it.

/// How much of each worn armored piece's max integrity one fragment restores
#define BULWARK_REPAIR_FRACTION 0.06
/// How long a fragment stays on the ground
#define BULWARK_SHARD_LIFETIME 10 SECONDS
/// Minimum time between two fragments (one per blow, even when it hits several pieces)
#define BULWARK_SHARD_COOLDOWN 0.8 SECONDS

/datum/action/cooldown/spell/undirected/bulwark
	name = "Bulwark"
	desc = "Brace your armor for two minutes. Every blow that wears it down knocks a fragment loose; \
	pick the fragments back up to slightly repair every armored piece you wear."
	button_icon_state = "bcry"
	sound = 'sound/foley/equip/equip_armor_plate.ogg'

	antimagic_flags = NONE

	associated_skill = /datum/attribute/skill/misc/athletics
	associated_stat = STAT_ENDURANCE

	charge_required = FALSE
	has_visual_effects = FALSE
	cooldown_time = 5 MINUTES
	spell_type = SPELL_STAMINA
	spell_cost = 0

/datum/action/cooldown/spell/undirected/bulwark/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return
	return ishuman(owner)

/datum/action/cooldown/spell/undirected/bulwark/cast(mob/living/cast_on)
	. = ..()
	cast_on.apply_status_effect(/datum/status_effect/buff/bulwark)
	cast_on.visible_message(span_notice("[cast_on] sets their feet and braces behind their armor."), span_notice("My armor is my bulwark. What breaks off, I will take back."))

/datum/status_effect/buff/bulwark
	id = "bulwark"
	tick_interval = STATUS_EFFECT_NO_TICK
	alert_type = /atom/movable/screen/alert/status_effect/buff/bulwark
	duration = 2 MINUTES
	COOLDOWN_DECLARE(shard_cooldown)

/datum/status_effect/buff/bulwark/on_remove()
	. = ..()
	if(owner.stat != DEAD)
		to_chat(owner, span_warning("My bulwark wanes."))

/// Called from checkarmor when one of the owner's armor pieces is worn down by a blow
/datum/status_effect/buff/bulwark/proc/shed_fragment()
	if(!COOLDOWN_FINISHED(src, shard_cooldown))
		return
	COOLDOWN_START(src, shard_cooldown, BULWARK_SHARD_COOLDOWN)
	var/turf/center = get_turf(owner)
	if(!center)
		return
	// Like Azure: the fragment flies a tile or two behind the wearer
	var/back_dir = REVERSE_DIR(owner.dir)
	var/side_dir = turn(owner.dir, 90)
	var/list/candidates = list()
	var/turf/back = get_step(center, back_dir)
	if(back)
		candidates += back
		candidates += get_step(back, side_dir)
		candidates += get_step(back, turn(side_dir, 180))
		var/turf/far_back = get_step(back, back_dir)
		if(far_back)
			candidates += far_back
	var/list/valid = list()
	for(var/turf/T as anything in candidates)
		if(T && !T.density && !isopenspace(T) && !T.is_blocked_turf(TRUE))
			valid += T
	var/turf/landing = length(valid) ? pick(valid) : center
	playsound(owner, 'sound/combat/sharpness_loss1.ogg', 60, TRUE)
	new /obj/effect/temp_visual/bulwark_shard(center, owner, landing)

/atom/movable/screen/alert/status_effect/buff/bulwark
	name = "Bulwark"
	desc = span_nicegreen("Fragments of my armor fly off when struck. I can pick them up to mend it.")
	icon_state = "buff"

/// Repairs every armored piece the mob wears by a fraction of its max integrity
/mob/living/carbon/human/proc/bulwark_repair()
	var/repaired = FALSE
	for(var/obj/item/clothing/C in get_equipped_items())
		if(!C.uses_integrity || !C.armor || C.max_integrity <= 0)
			continue
		if(C.get_integrity() >= C.max_integrity)
			continue
		C.repair_damage(C.max_integrity * BULWARK_REPAIR_FRACTION)
		if(C.obj_broken && C.get_integrity() > 0)
			C.atom_fix()
		C.update_appearance()
		repaired = TRUE
	return repaired

/obj/effect/temp_visual/bulwark_shard
	name = "armor fragment"
	desc = "A chunk of battered metal knocked loose in the fight. It could still be hammered back into place."
	icon = 'icons/effects/bulwark_shards.dmi'
	icon_state = "malum_shards"
	layer = ABOVE_OBJ_LAYER
	plane = GAME_PLANE
	mouse_opacity = MOUSE_OPACITY_ICON
	randomdir = FALSE
	duration = BULWARK_SHARD_LIFETIME
	/// The Ironclad it came from; only they can mend their armor with it
	var/datum/weakref/owner_ref
	/// Still flying: can't be collected or crushed yet
	var/landing = TRUE

/obj/effect/temp_visual/bulwark_shard/Initialize(mapload, mob/living/carbon/human/shedder, turf/target_turf)
	. = ..()
	owner_ref = WEAKREF(shedder)
	var/turf/here = get_turf(src)
	if(!istype(target_turf) || target_turf == here)
		landing = FALSE
		return
	animate(src, pixel_x = (target_turf.x - here.x) * 32, pixel_y = (target_turf.y - here.y) * 32, time = 5, easing = ELASTIC_EASING)
	addtimer(CALLBACK(src, PROC_REF(land), target_turf), 5)

/obj/effect/temp_visual/bulwark_shard/proc/land(turf/target_turf)
	if(QDELETED(src))
		return
	forceMove(target_turf)
	pixel_x = 0
	pixel_y = 0
	landing = FALSE
	for(var/mob/living/carbon/human/H in target_turf)
		if(try_collect(H))
			return

/// Returns TRUE if the shard was used up
/obj/effect/temp_visual/bulwark_shard/proc/try_collect(mob/living/carbon/human/H)
	if(landing || QDELETED(src) || !istype(H) || H.stat == DEAD)
		return FALSE
	if(H != owner_ref?.resolve())
		H.visible_message(span_notice("[H] crushes [src] underfoot."))
		playsound(get_turf(src), 'sound/foley/breaksound.ogg', 60, TRUE)
		qdel(src)
		return TRUE
	if(H.bulwark_repair())
		to_chat(H, span_notice("I hammer the fragment back into my armor."))
	else
		to_chat(H, span_notice("My armor is already whole."))
	new /obj/effect/temp_visual/heal(get_turf(H), "#6b6b6b")
	playsound(H, 'sound/foley/equip/equip_armor_plate.ogg', 60, TRUE)
	qdel(src)
	return TRUE

/obj/effect/temp_visual/bulwark_shard/Crossed(atom/movable/AM)
	. = ..()
	if(ishuman(AM))
		try_collect(AM)

/obj/effect/temp_visual/bulwark_shard/attack_hand(mob/living/carbon/human/user, list/modifiers)
	if(ishuman(user) && user.Adjacent(src) && user == owner_ref?.resolve())
		try_collect(user)
		return TRUE
	return ..()

#undef BULWARK_REPAIR_FRACTION
#undef BULWARK_SHARD_LIFETIME
#undef BULWARK_SHARD_COOLDOWN
