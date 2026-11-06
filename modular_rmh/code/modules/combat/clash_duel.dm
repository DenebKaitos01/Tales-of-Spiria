// RMH EDIT (combat rework): clashes are settled by a short click-mash duel instead of a hidden dice roll.
// When both fighters hold the Defend guard and one strikes, the camera closes in on them, both mash
// left click to push a shared bar, and the loser is thrown off. Stats, skill and weapons still matter:
// they tilt where the bar starts and how hard each click pushes.

/// How long the mash lasts
#define CLASH_DUEL_TIME (2.5 SECONDS)
/// Bar position each side has to reach to win outright (the bar runs 0 = attacker wins, 100 = defender wins)
#define CLASH_DUEL_BAR_MAX 100
/// Push per click before the advantage modifier
#define CLASH_DUEL_PUSH 4
/// Fastest counted clicking, so autoclickers gain nothing past it
#define CLASH_DUEL_MIN_CLICK_GAP (0.6)
/// Clicks per second an NPC mashes at
#define CLASH_DUEL_NPC_CPS 6
/// How far the camera closes in
#define CLASH_DUEL_ZOOM 1.3
/// Pixels each sprite leans into the other while locked
#define CLASH_DUEL_LEAN 6
/// Extra pixels the one winning the bar drives both sprites toward the loser
#define CLASH_DUEL_SHOVE 6

/datum/preference/toggle/clash_zoom
	savefile_key = "clash_zoom"
	savefile_identifier = PREF_PLAYER
	category = "gameplay"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = TRUE

/client/verb/toggle_clash_zoom()
	set name = "Toggle Clash Zoom"
	set desc = "Let the camera close in on you during weapon clashes."
	set category = "Preferences"
	prefs.write_preference(/datum/preference/toggle/clash_zoom, !prefs.read_preference(/datum/preference/toggle/clash_zoom))
	prefs.save_preferences()
	to_chat(usr, span_notice("Clash zoom [prefs.read_preference(/datum/preference/toggle/clash_zoom) ? "enabled" : "disabled"]."))

/// Window in which two fighters striking each other counts as an exchange of blows
#define CLASH_DUEL_EXCHANGE_WINDOW (2 SECONDS)
/// Chance an exchange of blows locks the blades
#define CLASH_DUEL_EXCHANGE_CHANCE 20
/// Time before the same fighter can be locked into another duel
#define CLASH_DUEL_COOLDOWN (15 SECONDS)

/mob/living
	/// The clash duel we are locked in, if any
	var/datum/clash_duel/active_clash_duel
	/// Who we last struck in melee, and when
	var/datum/weakref/last_melee_target
	var/last_melee_time = 0
	/// world.time before which we can't be locked into another clash duel
	var/next_clash_duel = 0

/// Our standing in a blade lock: Strength + Speed (dexterity) + Perception + twice our skill with the weapon
/mob/living/proc/clash_duel_score(obj/item/weapon)
	. = GET_MOB_ATTRIBUTE_VALUE(src, STAT_STRENGTH) + GET_MOB_ATTRIBUTE_VALUE(src, STAT_SPEED) + GET_MOB_ATTRIBUTE_VALUE(src, STAT_PERCEPTION)
	if(weapon?.associated_skill)
		. += GET_MOB_SKILL_VALUE_OLD(src, weapon.associated_skill) * 2

/**
 * Called as we strike target with weapon. If target struck us back within a moment, this is an exchange of blows
 * and has a chance to lock blades into a clash duel instead of landing the strike. Returns TRUE if a duel started.
 */
/mob/living/proc/try_exchange_clash_duel(mob/living/target, obj/item/weapon)
	if(!istype(target) || target == src || !istype(weapon) || !weapon.associated_skill || !weapon.force)
		return FALSE
	if(!used_intent || used_intent.tranged || used_intent.tshield || used_intent.noaa)
		return FALSE
	var/struck_back = (target.last_melee_target?.resolve() == src) && (world.time - target.last_melee_time <= CLASH_DUEL_EXCHANGE_WINDOW)
	last_melee_target = WEAKREF(target)
	last_melee_time = world.time
	if(!struck_back)
		return FALSE
	var/obj/item/their_weapon = target.get_active_held_item()
	if(!istype(their_weapon) || !their_weapon.associated_skill)
		return FALSE
	if(active_clash_duel || target.active_clash_duel || !Adjacent(target))
		return FALSE
	if(stat != CONSCIOUS || target.stat != CONSCIOUS)
		return FALSE
	if(world.time < next_clash_duel || world.time < target.next_clash_duel)
		return FALSE
	if(!prob(CLASH_DUEL_EXCHANGE_CHANCE))
		return FALSE
	next_clash_duel = world.time + CLASH_DUEL_COOLDOWN
	target.next_clash_duel = world.time + CLASH_DUEL_COOLDOWN
	// The one being struck holds the bar's high end; each point of score gap is worth 6 of advantage
	var/advantage = (target.clash_duel_score(their_weapon) - clash_duel_score(weapon)) * 6
	var/datum/clash_duel/duel = new(target, src, their_weapon, weapon, advantage)
	duel.start()
	return TRUE

/datum/clash_duel
	/// The fighter who held the guard (wins at bar 100)
	var/mob/living/defender
	/// The fighter who struck into it (wins at bar 0)
	var/mob/living/attacker
	var/obj/item/defender_item
	var/obj/item/attacker_item
	/// Shared bar, 50 is even
	var/bar = 50
	/// Push multiplier for each side, from stats, skill and weapons
	var/defender_push = 1
	var/attacker_push = 1
	var/end_time = 0
	/// Last counted click per fighter, to cap the clicking speed
	var/list/last_click = list()
	/// World rendering plates we scaled up for the zoom
	var/list/zoomed = list()
	/// Bar shown over the pair: client = image
	var/list/bar_images = list()
	var/finished = FALSE
	/// cleanup() already ran
	var/cleaned = FALSE
	/// Pixel offset we applied to each sprite: fighter = list(x, y)
	var/list/sprite_offsets = list()
	/// Process ticks since the start, to pace the sparks
	var/ticks = 0

/datum/clash_duel/New(mob/living/new_defender, mob/living/new_attacker, obj/item/new_defender_item, obj/item/new_attacker_item, advantage)
	. = ..()
	defender = new_defender
	attacker = new_attacker
	defender_item = new_defender_item
	attacker_item = new_attacker_item
	// advantage is the defender's edge in the old clash dice (about -80 to +80): it tilts the start and the clicks
	advantage = clamp(advantage, -80, 80)
	bar = 50 + round(advantage * 0.2)
	defender_push = 1 + (advantage / 200)
	attacker_push = 1 - (advantage / 200)

/datum/clash_duel/Destroy(force)
	cleanup()
	defender = null
	attacker = null
	defender_item = null
	attacker_item = null
	return ..()

/datum/clash_duel/proc/start()
	for(var/mob/living/fighter as anything in list(defender, attacker))
		fighter.active_clash_duel = src
		fighter.face_atom(fighter == defender ? attacker : defender)
		fighter.Immobilize(CLASH_DUEL_TIME + 0.5 SECONDS)
		RegisterSignal(fighter, COMSIG_MOB_CLICKON, PROC_REF(on_click))
		RegisterSignal(fighter, list(COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING), PROC_REF(abort))
		to_chat(fighter, span_userdanger("Blades locked! MASH LEFT CLICK to overpower [fighter == defender ? attacker : defender]!"))
		zoom_in(fighter)
	update_sprites()
	for(var/mob/living/fighter as anything in list(defender, attacker))
		shake_camera(fighter, 3, 1)
		clash_flash(fighter)
	clash_sparks()
	defender.visible_message(span_boldwarning("[defender] and [attacker] lock blades!"))
	playsound(defender, 'sound/combat/clash_struck.ogg', 100, TRUE)
	end_time = world.time + CLASH_DUEL_TIME
	update_bar()
	START_PROCESSING(SSfastprocess, src)

/datum/clash_duel/process(seconds_per_tick)
	if(finished)
		return PROCESS_KILL
	if(QDELETED(defender) || QDELETED(attacker) || get_dist(defender, attacker) > 1 || defender.stat != CONSCIOUS || attacker.stat != CONSCIOUS)
		abort()
		return PROCESS_KILL
	// NPCs mash on their own
	for(var/mob/living/fighter as anything in list(defender, attacker))
		if(!fighter.client && prob(CLASH_DUEL_NPC_CPS * seconds_per_tick * 100))
			push(fighter)
	update_bar()
	update_sprites()
	ticks++
	for(var/mob/living/fighter as anything in list(defender, attacker))
		shake_camera(fighter, 1, 0.08) // the blades grinding
	if(!(ticks % 3))
		clash_sparks(small = TRUE)
	if(bar <= 0 || bar >= CLASH_DUEL_BAR_MAX || world.time >= end_time)
		resolve()
		return PROCESS_KILL

/datum/clash_duel/proc/on_click(mob/living/clicker, atom/clicked_atom, list/modifiers)
	SIGNAL_HANDLER
	if(finished)
		return
	if(!LAZYACCESS(modifiers, RIGHT_CLICK) && !LAZYACCESS(modifiers, MIDDLE_CLICK))
		push(clicker)
	return COMSIG_MOB_CANCEL_CLICKON

/datum/clash_duel/proc/push(mob/living/fighter)
	if(world.time < (last_click[fighter] || 0) + CLASH_DUEL_MIN_CLICK_GAP)
		return
	last_click[fighter] = world.time
	if(fighter == defender)
		bar = min(CLASH_DUEL_BAR_MAX, bar + CLASH_DUEL_PUSH * defender_push)
	else
		bar = max(0, bar - CLASH_DUEL_PUSH * attacker_push)

/// A text bar over the pair, seen by both fighters; each sees their own side on the left
/datum/clash_duel/proc/update_bar()
	for(var/mob/living/fighter as anything in list(defender, attacker))
		var/client/viewer = fighter.client
		if(!viewer)
			continue
		var/mine = (fighter == defender) ? bar : (CLASH_DUEL_BAR_MAX - bar)
		var/filled = round(mine / 10)
		var/text = "<span style='color:#7fd1ff'>[repeat_string(filled, "|")]</span><span style='color:#ff5c5c'>[repeat_string(10 - filled, "|")]</span>"
		var/image/bar_image = bar_images[viewer]
		if(!bar_image)
			bar_image = image(loc = fighter, layer = ABOVE_ALL_MOB_LAYER)
			bar_image.plane = WEATHER_EFFECT_PLANE
			bar_image.appearance_flags = RESET_COLOR|RESET_ALPHA|RESET_TRANSFORM|KEEP_APART
			bar_image.maptext_width = 96
			bar_image.maptext_x = -32
			bar_image.pixel_y = 34
			bar_images[viewer] = bar_image
			viewer.images += bar_image
		bar_image.maptext = MAPTEXT_CENTER("<b>CLICK!</b><br>[text]")

/// Scales up the world rendering plate (not the HUD), which zooms the camera on the fighter
/datum/clash_duel/proc/zoom_in(mob/living/fighter)
	var/client/viewer = fighter.client
	if(!viewer || !viewer.prefs?.read_preference(/datum/preference/toggle/clash_zoom))
		return
	var/atom/movable/screen/plane_master/world_plate = fighter.hud_used?.plane_masters["[RENDER_PLANE_GAME_POST_PROCESSING]"]
	if(!world_plate)
		return
	zoomed += world_plate
	animate(world_plate, transform = matrix(CLASH_DUEL_ZOOM, 0, 0, 0, CLASH_DUEL_ZOOM, 0), time = 0.25 SECONDS, easing = SINE_EASING|EASE_OUT)

/// Leans both sprites into each other, slides them toward whoever is losing, with a little grinding jitter
/datum/clash_duel/proc/update_sprites()
	var/list/axis = get_sex_motion_step(defender, attacker) // from the defender toward the attacker
	var/shove = round(((bar - 50) / 50) * CLASH_DUEL_SHOVE)
	for(var/mob/living/fighter as anything in list(defender, attacker))
		var/lean = (fighter == defender) ? CLASH_DUEL_LEAN : -CLASH_DUEL_LEAN
		var/jitter = rand(-1, 1)
		set_sprite_offset(fighter, axis[1] * (lean + shove) + jitter, axis[2] * (lean + shove) + rand(-1, 1))

/// Moves the sprite to an absolute offset from where the duel found it
/datum/clash_duel/proc/set_sprite_offset(mob/living/fighter, new_x, new_y, time = 0.15 SECONDS)
	if(QDELETED(fighter))
		return
	var/list/current = sprite_offsets[fighter] || list(0, 0)
	var/delta_x = new_x - current[1]
	var/delta_y = new_y - current[2]
	sprite_offsets[fighter] = list(new_x, new_y)
	if(delta_x || delta_y)
		animate(fighter, pixel_w = delta_x, pixel_z = delta_y, time = time, flags = ANIMATION_PARALLEL|ANIMATION_RELATIVE)

/// A soft white flash on the fighter's screen as the blades meet
/datum/clash_duel/proc/clash_flash(mob/living/fighter)
	if(!fighter.client)
		return
	var/atom/movable/screen/fullscreen/flash = fighter.overlay_fullscreen("clash_flash", /atom/movable/screen/fullscreen/flash)
	flash.alpha = 90
	animate(flash, alpha = 0, time = 0.35 SECONDS)
	addtimer(CALLBACK(fighter, TYPE_PROC_REF(/mob, clear_fullscreen), "clash_flash", 0), 0.4 SECONDS)

/// Sparks thrown off both weapons, where the blades meet. Visual only: real sparks heat the tile and can light hay
/datum/clash_duel/proc/clash_sparks(small = FALSE)
	var/list/axis = get_sex_motion_step(defender, attacker)
	for(var/mob/living/fighter as anything in list(defender, attacker))
		if(QDELETED(fighter))
			continue
		var/toward = (fighter == defender) ? 1 : -1
		var/obj/effect/temp_visual/clash_spark/spark = new(get_turf(fighter))
		spark.pixel_x = axis[1] * toward * 12 + rand(-4, 4)
		spark.pixel_y = axis[2] * toward * 12 + rand(0, 8)
		if(small)
			spark.transform = matrix(0.6, 0, 0, 0, 0.6, 0)

/obj/effect/temp_visual/clash_spark
	icon = 'icons/effects/effects.dmi'
	icon_state = "sparks"
	plane = ABOVE_LIGHTING_PLANE
	duration = 0.5 SECONDS
	light_outer_range = MINIMUM_USEFUL_LIGHT_RANGE
	light_power = 1
	light_color = LIGHT_COLOR_FIRE

/datum/clash_duel/proc/resolve()
	if(finished)
		return
	finished = TRUE
	var/mob/living/winner
	var/mob/living/loser
	if(bar > 50)
		winner = defender
		loser = attacker
	else if(bar < 50)
		winner = attacker
		loser = defender
	var/decisive = (bar <= 0 || bar >= CLASH_DUEL_BAR_MAX)
	cleanup()
	shove_apart(loser)
	for(var/mob/living/fighter as anything in list(defender, attacker))
		shake_camera(fighter, decisive ? 4 : 2, decisive ? 2 : 1)
	if(!winner)
		defender.visible_message(span_boldwarning("[defender] and [attacker] break apart, neither giving ground!"))
		playsound(defender, 'sound/combat/clash_draw.ogg', 100, TRUE)
	else
		winner.visible_message(span_boldwarning("[winner] overpowers [loser]!"))
		winner.show_overhead_indicator('icons/mob/overhead_effects.dmi', "clashtwo", 1 SECONDS, y_offset = 24, sound = 'sound/combat/clash_disarm_us.ogg')
		loser.apply_status_effect(/datum/status_effect/debuff/exposed, 2 SECONDS)
		if(decisive) // Overpowered outright: the blade flies
			loser.disarm_weapon()
	qdel(src)

/// The loser is thrown two tiles back from the winner; on a draw both give one tile
/datum/clash_duel/proc/shove_apart(mob/living/loser)
	for(var/mob/living/fighter as anything in list(defender, attacker))
		if(QDELETED(fighter))
			continue
		fighter.SetImmobilized(0)
		if(loser && fighter != loser)
			continue
		var/mob/living/other = (fighter == defender) ? attacker : defender
		var/away = get_dir(other, fighter) || REVERSE_DIR(fighter.dir)
		var/distance = loser ? 2 : 1
		fighter.safe_throw_at(get_ranged_target_turf(fighter, away, distance), distance, 1, gentle = TRUE)

/// Ends the duel without a winner (someone died, left or was deleted)
/datum/clash_duel/proc/abort()
	SIGNAL_HANDLER
	if(finished)
		return
	finished = TRUE
	cleanup()
	qdel(src)

/datum/clash_duel/proc/cleanup()
	if(cleaned)
		return
	cleaned = TRUE
	STOP_PROCESSING(SSfastprocess, src)
	for(var/client/viewer as anything in bar_images)
		viewer?.images -= bar_images[viewer]
	bar_images.Cut()
	for(var/atom/movable/screen/plane_master/world_plate as anything in zoomed)
		if(!QDELETED(world_plate))
			animate(world_plate, transform = matrix(), time = 0.3 SECONDS, easing = SINE_EASING|EASE_IN)
	zoomed.Cut()
	for(var/mob/living/fighter as anything in list(defender, attacker))
		if(QDELETED(fighter))
			continue
		UnregisterSignal(fighter, list(COMSIG_MOB_CLICKON, COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING))
		if(fighter.active_clash_duel == src)
			fighter.active_clash_duel = null
		fighter.remove_status_effect(/datum/status_effect/buff/clash)
	for(var/mob/living/fighter as anything in sprite_offsets)
		set_sprite_offset(fighter, 0, 0, 0.1 SECONDS)
	sprite_offsets.Cut()

#undef CLASH_DUEL_TIME
#undef CLASH_DUEL_BAR_MAX
#undef CLASH_DUEL_PUSH
#undef CLASH_DUEL_MIN_CLICK_GAP
#undef CLASH_DUEL_NPC_CPS
#undef CLASH_DUEL_EXCHANGE_WINDOW
#undef CLASH_DUEL_EXCHANGE_CHANCE
#undef CLASH_DUEL_COOLDOWN
#undef CLASH_DUEL_ZOOM
#undef CLASH_DUEL_LEAN
#undef CLASH_DUEL_SHOVE
