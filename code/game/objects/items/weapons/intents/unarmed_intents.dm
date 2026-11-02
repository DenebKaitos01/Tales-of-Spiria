
/datum/intent/unarmed
	unarmed = TRUE

/datum/intent/unarmed/punch
	name = "punch"
	icon_state = "inpunch"
	attack_verb = list("punches", "jabs", "clocks")
	chargetime = 0
	animname = "punch"
	hitsound = list('sound/combat/hits/punch/punch (1).ogg', 'sound/combat/hits/punch/punch (2).ogg', 'sound/combat/hits/punch/punch (3).ogg')
	misscost = 5
	releasedrain = 1
	swingdelay = 0
	rmb_ranged = TRUE
	candodge = TRUE
	canparry = TRUE
	blade_class = BCLASS_PUNCH
	miss_text = "swings a fist at the air!"
	miss_sound = "punchwoosh"
	item_damage_type = "blunt"

/datum/intent/unarmed/punch/rmb_ranged(atom/target, mob/user)
	if(ismob(target))
		var/mob/M = target
		var/list/targetl = list(target)
		var/mob/living/L = user
		var/taunt_icon = "taunt"
		var/taunt_offset = 21
		var/taunt_message = "[user] taunts [M]!"
		var/self_message = "I taunt [M]!"
		if(istype(L.patron, /datum/patron/divine/eora) || HAS_TRAIT(L, TRAIT_PACIFISM))
			taunt_icon = "thumbsdown"
			taunt_offset = 24
			taunt_message = "[user] berates [M] disapprovingly!"
			self_message = "I berate [M] disapprovingly!"
		else if(istype(L.patron, /datum/patron/inhumen/graggar) || L.get_stress_amount() > 10)
			taunt_icon = "midfinger"
			taunt_offset = 23
			taunt_message = "[user] flips [M] off!"
			self_message = "I flip [M] off!"
		user.visible_message(span_red(taunt_message), span_red(self_message), ignored_mobs = targetl)
		user.emote("taunt")
		if(M.client)
			L.play_gesture_emote(M, taunt_icon, taunt_offset)
			user.changeNext_move(CLICK_CD_FAST) // Keeps the animation from being spammed
			M.taunted(user)
			if(M.can_see_cone(user))
				to_chat(M, span_red(taunt_message))
		else
			M.taunted(user)
	return

/datum/intent/unarmed/shove
	name = "shove"
	icon_state = "inshove"
	attack_verb = list("shoves")
	chargetime = 0
	noaa = TRUE
	rmb_ranged = TRUE
	misscost = 5
	releasedrain = 2
	item_damage_type = "blunt"

/datum/intent/unarmed/shove/rmb_ranged(atom/target, mob/user)
	if(ismob(target))
		var/mob/M = target
		var/list/targetl = list(target)
		user.visible_message("<span class='blue'>[user] shoos [M] away.</span>", "<span class='blue'>I shoo [M] away.</span>", ignored_mobs = targetl)
		if(M.client)
			var/mob/living/L = user
			L.play_gesture_emote(M, "dismiss")
			user.changeNext_move(CLICK_CD_FAST) // Keeps the animation from being spammed
			if(M.can_see_cone(user))
				to_chat(M, "<span class='blue'>[user] shoos me away.</span>")
		else
			M.shood(user)
	return

/datum/intent/unarmed/grab
	name = "grab"
	icon_state = "ingrab"
	attack_verb = list("grabs")
	chargetime = 0
	noaa = TRUE
	rmb_ranged = TRUE
	releasedrain = 3
	misscost = 6.5
	candodge = TRUE
	canparry = TRUE
	item_damage_type = "blunt"

/datum/intent/unarmed/grab/rmb_ranged(atom/target, mob/user)
	if(ismob(target))
		var/mob/M = target
		var/list/targetl = list(target)
		user.visible_message("<span class='green'>[user] beckons [M] to come closer.</span>", "<span class='green'>I beckon [M] to come closer.</span>", ignored_mobs = targetl)
		if(M.client)
			var/mob/living/L = user
			L.play_gesture_emote(M, "beckon")
			user.changeNext_move(CLICK_CD_FAST) // Keeps the animation from being spammed
			if(M.can_see_cone(user))
				to_chat(M, "<span class='green'>[user] beckons me to come closer.</span>")
		else
			M.beckoned(user)
	return

/datum/intent/unarmed/help
	name = "touch"
	icon_state = "intouch"
	chargetime = 0
	noaa = TRUE
	candodge = FALSE
	misscost = 0
	releasedrain = 0
	rmb_ranged = TRUE

/datum/intent/unarmed/help/rmb_ranged(atom/target, mob/user)
	if(ismob(target))
		var/mob/M = target
		var/list/targetl = list(target)
		user.visible_message("<span class='green'>[user] waves friendly at [M].</span>", "<span class='green'>I wave friendly at [M].</span>", ignored_mobs = targetl)
		if(M.client)
			var/mob/living/L = user
			L.play_gesture_emote(M, "wavefriendly")
			user.changeNext_move(CLICK_CD_FAST) // Keeps the animation from being spammed
			if(M.can_see_cone(user))
				to_chat(M, "<span class='green'>[user] gives me a friendly wave.</span>")
	return
