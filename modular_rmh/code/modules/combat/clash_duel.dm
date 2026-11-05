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

/mob/living
	/// The clash duel we are locked in, if any
	var/datum/clash_duel/active_clash_duel

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
	/// Clients we zoomed in, with the view they had: client = view string
	var/list/zoomed = list()
	/// Bar shown over the pair: client = image
	var/list/bar_images = list()
	var/finished = FALSE
	/// cleanup() already ran
	var/cleaned = FALSE

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
	lock_sprites(TRUE)
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

/datum/clash_duel/proc/zoom_in(mob/living/fighter)
	var/client/viewer = fighter.client
	if(!viewer || !viewer.prefs?.read_preference(/datum/preference/toggle/clash_zoom))
		return
	var/list/size = getviewsize(viewer.view)
	var/width = max(5, round(size[1] / 2))
	var/height = max(5, round(size[2] / 2))
	if(!(width % 2))
		width++
	if(!(height % 2))
		height++
	zoomed[viewer] = viewer.view
	viewer.change_view("[width]x[height]")

/// Lean both sprites into each other while the blades are locked
/datum/clash_duel/proc/lock_sprites(locking)
	for(var/mob/living/fighter as anything in list(defender, attacker))
		if(QDELETED(fighter))
			continue
		var/mob/living/other = (fighter == defender) ? attacker : defender
		var/list/step = get_sex_motion_step(fighter, other)
		var/shift = locking ? 6 : -6
		animate(fighter, pixel_w = step[1] * shift, pixel_z = step[2] * shift, time = 0.1 SECONDS, flags = ANIMATION_PARALLEL|ANIMATION_RELATIVE)

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
	shove_apart()
	if(!winner)
		defender.visible_message(span_boldwarning("[defender] and [attacker] break apart, neither giving ground!"))
		playsound(defender, 'sound/combat/clash_draw.ogg', 100, TRUE)
	else
		winner.visible_message(span_boldwarning("[winner] overpowers [loser]!"))
		winner.show_overhead_indicator('icons/mob/overhead_effects.dmi', "clashtwo", 1 SECONDS, y_offset = 24, sound = 'sound/combat/clash_disarm_us.ogg')
		loser.apply_status_effect(/datum/status_effect/debuff/exposed, 2 SECONDS)
		loser.Slowdown(3)
		if(decisive)
			loser.disarm_weapon()
	qdel(src)

/// Throw both a couple of tiles away from each other
/datum/clash_duel/proc/shove_apart()
	for(var/mob/living/fighter as anything in list(defender, attacker))
		if(QDELETED(fighter))
			continue
		var/mob/living/other = (fighter == defender) ? attacker : defender
		var/away = get_dir(other, fighter) || REVERSE_DIR(fighter.dir)
		var/turf/landing = get_ranged_target_turf(fighter, away, 2)
		fighter.SetImmobilized(0)
		fighter.safe_throw_at(landing, 2, 1, gentle = TRUE)

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
	for(var/client/viewer as anything in zoomed)
		viewer?.change_view(zoomed[viewer])
	zoomed.Cut()
	for(var/mob/living/fighter as anything in list(defender, attacker))
		if(QDELETED(fighter))
			continue
		UnregisterSignal(fighter, list(COMSIG_MOB_CLICKON, COMSIG_LIVING_DEATH, COMSIG_PARENT_QDELETING))
		if(fighter.active_clash_duel == src)
			fighter.active_clash_duel = null
		fighter.remove_status_effect(/datum/status_effect/buff/clash)
	if(!QDELETED(defender) && !QDELETED(attacker))
		lock_sprites(FALSE)

#undef CLASH_DUEL_TIME
#undef CLASH_DUEL_BAR_MAX
#undef CLASH_DUEL_PUSH
#undef CLASH_DUEL_MIN_CLICK_GAP
#undef CLASH_DUEL_NPC_CPS
