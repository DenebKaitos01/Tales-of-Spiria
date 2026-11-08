// RMH EDIT: soft bloom. Light sources (fire, candles, torches, lanterns) get a warm halo.
// A copy of the finished game image is drawn on its own plate, a color matrix keeps only bright
// fire-colored pixels (so white cloth, pale hair and snow never glow), it is blurred and added back
// on top of the game. Purely client-side. Off by default: Settings > Display > Post processing > Bloom.

#define RENDER_PLANE_GAME_BLOOM 993

/// Keeps only bright warm (fire-colored) pixels and tints them amber: glow = (R+G)/2 - B - 0.3
#define BLOOM_ISOLATE_MATRIX list(\
	1.25, 0.75, 0.25, 0,\
	1.25, 0.75, 0.25, 0,\
	-2.5, -1.5, -0.5, 0,\
	0, 0, 0, 1,\
	-0.75, -0.45, -0.15, 0)

/datum/preference/toggle/bloom
	savefile_key = "bloom"
	savefile_identifier = PREF_PLAYER
	category = "ui"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = FALSE

/// The glow plate: holds a copy of the game image, keeps the fire, blurs it and adds it over the game
/atom/movable/screen/plane_master/rendering_plate/game_world_bloom
	name = "game bloom rendering plate"
	plane = RENDER_PLANE_GAME_BLOOM
	render_relay_plane = RENDER_PLANE_GAME_POST_PROCESSING
	blend_mode_override = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// The copy of the game image drawn onto this plate while bloom is on
	var/atom/movable/render_plane_relay/bloom_source

/atom/movable/screen/plane_master/rendering_plate/game_world_bloom/Initialize(mapload)
	. = ..()
	add_filter("bloom_isolate", 1, color_matrix_filter(BLOOM_ISOLATE_MATRIX))
	add_filter("bloom_blur", 2, gauss_blur_filter(4))

/atom/movable/screen/plane_master/rendering_plate/game_world_bloom/Destroy()
	QDEL_NULL(bloom_source)
	return ..()

/atom/movable/screen/plane_master/rendering_plate/game_world_bloom/backdrop(mob/mymob)
	. = ..()
	if(istype(mymob))
		update_bloom_source(mymob)

/// Shows or hides the glow for this viewer, following their preference
/atom/movable/screen/plane_master/rendering_plate/game_world_bloom/proc/update_bloom_source(mob/viewer)
	var/client/viewer_client = viewer?.client
	if(!viewer_client)
		return
	var/wanted = viewer_client.prefs?.read_preference(/datum/preference/toggle/bloom)
	if(!wanted)
		if(bloom_source)
			viewer_client.screen -= bloom_source
			QDEL_NULL(bloom_source)
		return
	if(!bloom_source)
		bloom_source = new()
		bloom_source.render_source = RENDER_PLANE_GAME_RENDER_TARGET
		bloom_source.plane = RENDER_PLANE_GAME_BLOOM
		bloom_source.layer = 1
		bloom_source.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		bloom_source.name = "bloom source"
	if(!(bloom_source in viewer_client.screen))
		viewer_client.screen += bloom_source

/// Turns the bloom on or off on this mob's screen
/mob/proc/update_bloom()
	var/atom/movable/screen/plane_master/rendering_plate/game_world_bloom/plate = hud_used?.plane_masters["[RENDER_PLANE_GAME_BLOOM]"]
	plate?.update_bloom_source(src)

#undef BLOOM_ISOLATE_MATRIX
