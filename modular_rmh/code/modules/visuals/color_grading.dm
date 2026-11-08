// RMH EDIT: color grading. A color filter over the game world (not the HUD) that follows the time of day.
// Under the open sky it follows the outdoor cycle (deep blue night, golden-peach dawn and dusk, clear fresh day);
// under a roof it stays warm and saturated, changing only a little with the hour. High fantasy, not desolation.
// Purely client-side: the server only swaps a filter when the hour changes or the player steps in or out.
// Off by default: players turn it on in Settings > Display > Post processing > "Time of day colors".

#define GRADING_FILTER "color_grading"
/// How long the colors take to shift when the hour changes
#define GRADING_TOD_TRANSITION (20 SECONDS)
/// How long the colors take to shift when stepping in or out from under a roof
#define GRADING_ROOF_TRANSITION (1.5 SECONDS)

/// Saturation, then red/green/blue gain. Gains above 1 brighten, so keep them gentle.
GLOBAL_LIST_INIT(color_grading_looks, list(
	"outdoor_night" = list(0.85, 0.80, 0.90, 1.15),
	"outdoor_dawn"  = list(1.20, 1.12, 1.00, 0.94),
	"outdoor_day"   = list(1.20, 1.03, 1.06, 1.06),
	"outdoor_dusk"  = list(1.25, 1.18, 1.00, 0.84),
	"indoor_night"  = list(1.10, 1.02, 0.95, 0.98),
	"indoor_dawn"   = list(1.20, 1.10, 1.02, 0.92),
	"indoor_day"    = list(1.25, 1.10, 1.04, 0.92),
	"indoor_dusk"   = list(1.25, 1.12, 1.00, 0.88),
))

/datum/preference/toggle/color_grading
	savefile_key = "color_grading"
	savefile_identifier = PREF_PLAYER
	category = "ui"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = FALSE

/mob
	/// Was this mob under the open sky last time the color grading was set? (null = never set)
	var/grading_outdoors = null

/// Builds the color matrix for a look
/proc/color_grading_matrix(look)
	var/list/values = GLOB.color_grading_looks[look]
	if(!values)
		return COLOR_MATRIX_IDENTITY
	var/list/gain = list(values[2],0,0,0, 0,values[3],0,0, 0,0,values[4],0, 0,0,0,1, 0,0,0,0)
	return color_matrix_multiply(color_matrix_saturation(values[1]), gain)

/// Is this mob standing under the open sky?
/mob/proc/grading_is_outdoors()
	var/turf/T = get_turf(src)
	return !!(T?.outdoor_effect && T.outdoor_effect.state != SKY_BLOCKED)

/// Applies or updates the color grading on this mob's screen. instant = no fade (used when the HUD is built).
/mob/proc/update_color_grading(instant = FALSE, transition_time = GRADING_TOD_TRANSITION)
	if(!client || !hud_used)
		return
	var/atom/movable/screen/plane_master/plate = hud_used.plane_masters["[RENDER_PLANE_GAME_POST_PROCESSING]"]
	if(!plate)
		return
	if(!client.prefs?.read_preference(/datum/preference/toggle/color_grading))
		plate.remove_filter(GRADING_FILTER)
		grading_outdoors = null
		return
	grading_outdoors = grading_is_outdoors()
	var/tod = GLOB.tod || TOD_DAY
	var/list/new_matrix = color_grading_matrix("[grading_outdoors ? "outdoor" : "indoor"]_[tod]")
	if(instant || !plate.get_filter(GRADING_FILTER))
		plate.add_filter(GRADING_FILTER, 10, color_matrix_filter(new_matrix))
		return
	plate.transition_filter(GRADING_FILTER, transition_time, list("color" = new_matrix))

/// Steps in or out from under a roof
/mob/proc/grading_on_moved(datum/source)
	SIGNAL_HANDLER
	if(isnull(grading_outdoors))
		return
	if(grading_is_outdoors() != grading_outdoors)
		update_color_grading(FALSE, GRADING_ROOF_TRANSITION)

/mob/Login()
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(grading_on_moved), override = TRUE)

/mob/Logout()
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	grading_outdoors = null
	return ..()

// The HUD's post-processing plate is (re)built: put the grading on it right away
/atom/movable/screen/plane_master/rendering_plate/game_world_post_processing/backdrop(mob/mymob)
	. = ..()
	if(istype(mymob))
		mymob.update_color_grading(TRUE)

/// Every connected player's colors follow the new hour
/proc/update_all_color_grading()
	for(var/mob/player as anything in GLOB.player_list)
		player?.update_color_grading()

#undef GRADING_FILTER
#undef GRADING_TOD_TRANSITION
#undef GRADING_ROOF_TRANSITION
