// RMH EDIT: color grading. A color filter over the game world (not the HUD) that follows the time of day.
// Zones are picked by area: the outdoor areas listed in color_grading_outdoor_areas follow the outdoor cycle
// (deep blue night, golden-peach dawn and dusk, clear fresh day); the sewers are a sickly green; every other area
// is an interior that stays warm and saturated, changing only a little with the hour. High fantasy, not desolation.
// Purely client-side: the server only swaps a filter when the hour changes or the player changes zone.
// Off by default: players turn it on in Settings > Display > Post processing > "Time of day colors".

#define GRADING_FILTER "color_grading"
/// How long the colors take to shift when the hour changes
#define GRADING_TOD_TRANSITION (20 SECONDS)
/// How long the colors take to shift when walking into another zone
#define GRADING_ZONE_TRANSITION (1.5 SECONDS)

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
	"sewer_night"   = list(0.90, 0.82, 1.06, 0.84),
	"sewer_dawn"    = list(0.90, 0.85, 1.08, 0.86),
	"sewer_day"     = list(0.90, 0.85, 1.08, 0.86),
	"sewer_dusk"    = list(0.90, 0.85, 1.08, 0.86),
))

/// Areas (by name, lowercase) that use the outdoor colors. Every other area is an interior.
GLOBAL_LIST_INIT(color_grading_outdoor_areas, list(
	"rivermist hollow outdoors",
	"rivermist hollow outskirts",
	"west forest",
	"north forest",
	"east forest",
	"the town chapel",
	"ruined windmill",
	"misty lake",
	"hidden lake",
))

/datum/preference/toggle/color_grading
	savefile_key = "color_grading"
	savefile_identifier = PREF_PLAYER
	category = "ui"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = FALSE

/mob
	/// Color zone ("outdoor", "indoor" or "sewer") used last time the grading was set (null = never set)
	var/grading_zone = null

/// Builds the color matrix for a look
/proc/color_grading_matrix(look)
	var/list/values = GLOB.color_grading_looks[look]
	if(!values)
		return COLOR_MATRIX_IDENTITY
	var/list/gain = list(values[2],0,0,0, 0,values[3],0,0, 0,0,values[4],0, 0,0,0,1, 0,0,0,0)
	return color_matrix_multiply(color_matrix_saturation(values[1]), gain)

/// Which color zone is this mob in?
/mob/proc/get_grading_zone()
	var/area/A = get_area(src)
	if(!A)
		return "indoor"
	var/area_name = lowertext(A.name)
	if(findtext(area_name, "sewer"))
		return "sewer"
	if(area_name in GLOB.color_grading_outdoor_areas)
		return "outdoor"
	return "indoor"

/// Applies or updates the color grading on this mob's screen. instant = no fade (used when the HUD is built).
/mob/proc/update_color_grading(instant = FALSE, transition_time = GRADING_TOD_TRANSITION)
	if(!client || !hud_used)
		return
	var/atom/movable/screen/plane_master/plate = hud_used.plane_masters["[RENDER_PLANE_GAME_POST_PROCESSING]"]
	if(!plate)
		return
	if(!client.prefs?.read_preference(/datum/preference/toggle/color_grading))
		plate.remove_filter(GRADING_FILTER)
		grading_zone = null
		return
	grading_zone = get_grading_zone()
	var/tod = GLOB.tod || TOD_DAY
	var/list/new_matrix = color_grading_matrix("[grading_zone]_[tod]")
	if(instant || !plate.get_filter(GRADING_FILTER))
		plate.add_filter(GRADING_FILTER, 10, color_matrix_filter(new_matrix))
		return
	plate.transition_filter(GRADING_FILTER, transition_time, list("color" = new_matrix))

/// Walks into another zone
/mob/proc/grading_on_moved(datum/source)
	SIGNAL_HANDLER
	if(isnull(grading_zone))
		return
	if(get_grading_zone() != grading_zone)
		update_color_grading(FALSE, GRADING_ZONE_TRANSITION)

/mob/Login()
	. = ..()
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(grading_on_moved), override = TRUE)

/mob/Logout()
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	grading_zone = null
	return ..()

// The HUD's post-processing plate is (re)built: put the grading on it right away
/atom/movable/screen/plane_master/rendering_plate/game_world_post_processing/backdrop(mob/mymob)
	. = ..()
	if(istype(mymob))
		mymob.update_color_grading(TRUE)
		mymob.client?.update_flame_flicker()

/// Every connected player's colors follow the new hour
/proc/update_all_color_grading()
	for(var/mob/player as anything in GLOB.player_list)
		player?.update_color_grading()

#undef GRADING_FILTER
#undef GRADING_TOD_TRANSITION
#undef GRADING_ZONE_TRANSITION
