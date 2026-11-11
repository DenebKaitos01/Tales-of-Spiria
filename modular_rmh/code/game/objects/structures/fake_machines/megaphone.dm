// RMH EDIT: Town megaphone. A pole crowned with horns that works as a SCOM: it repeats the SCOMline out loud and
// you can speak into it from an adjacent tile. The horns are a separate piece so they can shake on their own:
// a little for normal speech, a lot for shouts and announcements (arrivals, decrees, laws...).

/// Hook for SCOMs that react when they speak a relayed message. Loud = shout or announcement.
/obj/structure/fake_machine/scomm/proc/on_relay(message, loud = FALSE)
	return

/// Shake every megaphone in the world hard, for announcements that don't go through the SCOMline
/proc/megaphones_boom()
	for(var/obj/structure/fake_machine/scomm/megaphone/M in SSroguemachine.scomm_machines)
		M.shake_horns(TRUE)

/obj/structure/fake_machine/scomm/megaphone
	name = "megaphone"
	desc = "A tall pole crowned with great horns. It booms the SCOMline across the town. Speak next to it to be heard everywhere."
	icon = 'modular_rmh/icons/obj/megaphone.dmi'
	icon_state = "pole"
	density = TRUE
	hear_range = 1
	SET_BASE_PIXEL(0, 0)
	/// The horns on top, a separate object so they can move without the pole
	var/obj/effect/megaphone_horns/horns

/obj/structure/fake_machine/scomm/megaphone/Initialize()
	. = ..()
	horns = new(null)
	vis_contents += horns

/obj/structure/fake_machine/scomm/megaphone/Destroy()
	vis_contents -= horns
	QDEL_NULL(horns)
	return ..()

/obj/structure/fake_machine/scomm/megaphone/update_icon_state()
	. = ..()
	icon_state = "pole"

/obj/structure/fake_machine/scomm/megaphone/on_relay(message, loud = FALSE)
	if(!loud && copytext(trim(strip_html(message)), -1) == "!")
		loud = TRUE
	shake_horns(loud)

/// Rattle the horns: a short buzz for speech, a long hard shake for shouts and announcements
/obj/structure/fake_machine/scomm/megaphone/proc/shake_horns(loud = FALSE)
	if(!horns || obj_broken)
		return
	var/amount = loud ? 2 : 1
	var/steps = loud ? 14 : 5
	animate(horns, pixel_x = 0, pixel_y = 0, time = 0)
	for(var/i in 1 to steps)
		animate(pixel_x = rand(-amount, amount), pixel_y = loud ? rand(-1, 1) : 0, time = 0.5)
	animate(pixel_x = 0, pixel_y = 0, time = 1)

/obj/effect/megaphone_horns
	name = "megaphone"
	icon = 'modular_rmh/icons/obj/megaphone.dmi'
	icon_state = "horns"
	anchored = TRUE
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_PLANE | VIS_INHERIT_LAYER
