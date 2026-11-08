// RMH EDIT: flickering flames. Every fire-colored light (torches, candles, lanterns, hearths, campfires) gets a soft
// warm halo that breathes irregularly, each flame on its own rhythm, like living fire.
// The real lighting is never touched (recalculating it would cost the server): the halo is an image only shown to
// players who turned the option on, and its animation loops on their own client. Off by default:
// Settings > Display > Post processing > Flickering flames.

/// Every flame halo in the world
GLOBAL_LIST_EMPTY(flame_flicker_images)
/// Clients that see the flame halos
GLOBAL_LIST_EMPTY(flame_flicker_viewers)

/datum/preference/toggle/flame_flicker
	savefile_key = "flame_flicker"
	savefile_identifier = PREF_PLAYER
	category = "ui"
	can_randomize = FALSE
	should_update_preview = FALSE
	default_value = FALSE

/datum/light_source
	/// The flickering halo drawn over this light's source, if it is a flame
	var/image/flicker_image

/datum/light_source/New(atom/owner, atom/top)
	. = ..()
	add_flame_flicker()

/datum/light_source/Destroy(force)
	remove_flame_flicker()
	return ..()

/// Is this light a flame? Warm and fairly bright: reds and oranges well above blue.
/datum/light_source/proc/is_flame_light()
	if(!isobj(source_atom))
		return FALSE
	return lum_r >= 0.6 && (lum_r - lum_b) >= 0.25 && lum_g >= 0.25

/datum/light_source/proc/add_flame_flicker()
	if(flicker_image || !is_flame_light())
		return
	var/big = light_outer_range > 3
	flicker_image = image(big ? 'icons/effects/light_overlays/light_96.dmi' : 'icons/effects/light_overlays/light_64.dmi', source_atom, "light")
	flicker_image.pixel_x = big ? -32 : -16
	flicker_image.pixel_y = big ? -32 : -16
	flicker_image.plane = ABOVE_LIGHTING_PLANE
	flicker_image.layer = 1
	flicker_image.blend_mode = BLEND_ADD
	flicker_image.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM | KEEP_APART
	flicker_image.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	flicker_image.color = light_color || "#ffb060"
	var/base_alpha = big ? 34 : 26
	flicker_image.alpha = base_alpha
	// An irregular breathing loop with its own rhythm: brighter/dimmer and a touch bigger/smaller
	var/first = TRUE
	for(var/step in 1 to 6)
		var/target_alpha = base_alpha + rand(-14, 14)
		var/matrix/size = matrix()
		size.Scale(rand(92, 108) / 100)
		var/step_time = rand(1, 4)
		if(first)
			animate(flicker_image, alpha = target_alpha, transform = size, time = step_time, loop = -1, easing = SINE_EASING)
			first = FALSE
		else
			animate(alpha = target_alpha, transform = size, time = step_time, easing = SINE_EASING)
	GLOB.flame_flicker_images += flicker_image
	for(var/client/viewer as anything in GLOB.flame_flicker_viewers)
		viewer?.images += flicker_image

/datum/light_source/proc/remove_flame_flicker()
	if(!flicker_image)
		return
	GLOB.flame_flicker_images -= flicker_image
	for(var/client/viewer as anything in GLOB.flame_flicker_viewers)
		viewer?.images -= flicker_image
	flicker_image.loc = null
	flicker_image = null

/// Shows or hides the flame halos for this client, following their preference
/client/proc/update_flame_flicker()
	GLOB.flame_flicker_viewers -= null // drop disconnected clients
	if(prefs?.read_preference(/datum/preference/toggle/flame_flicker))
		if(!(src in GLOB.flame_flicker_viewers))
			GLOB.flame_flicker_viewers += src
			images |= GLOB.flame_flicker_images
	else if(src in GLOB.flame_flicker_viewers)
		GLOB.flame_flicker_viewers -= src
		images -= GLOB.flame_flicker_images

/client/Del()
	GLOB.flame_flicker_viewers -= src
	return ..()
