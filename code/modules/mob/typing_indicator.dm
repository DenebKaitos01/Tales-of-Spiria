/mob
	var/hud_typing = FALSE //set when typing in an input window instead of chatline
	var/typing
	var/last_typed
	var/last_typed_time
	var/afk_indicator_active = FALSE
	/// A winget of the chat bar is in flight
	var/polling_chatbar = FALSE

	var/static/mutable_appearance/typing_indicator
	var/static/mutable_appearance/afk_indicator

/mob/proc/set_typing_indicator(state, hudt)
	if(!typing_indicator)
		typing_indicator = mutable_appearance('icons/mob/talk.dmi', "default0", FLY_LAYER)
		typing_indicator.alpha = 175

	if(state)
		if(!typing)
			if(hudt)
				hud_typing = TRUE
			add_overlay(typing_indicator)
			typing = TRUE
		if(hudt)
			hud_typing = TRUE
	else
		if(typing)
			cut_overlay(typing_indicator)
			typing = FALSE
			hud_typing = FALSE
	return state

/mob/living/key_down(_key, client/user)
	if(stat == CONSCIOUS)
//		var/list/binds = user.prefs?.key_bindings[_key]
//		if(binds)
/*			if("Say" in binds)
				set_typing_indicator(TRUE, TRUE)
			if("Me" in binds)
				set_typing_indicator(TRUE, TRUE)*/
		if(_key == "T")
			set_typing_indicator(TRUE, TRUE)
		if(_key == "M")
			set_typing_indicator(TRUE, TRUE)
		if(_key == ",")
			set_typing_indicator(TRUE, TRUE)
	return ..()

/mob/proc/handle_typing_indicator()
	if(!client || stat)
		set_typing_indicator(FALSE)
		return
	// RMH EDIT: the say/me windows (T, M) raise the bubble themselves; also raise it while typing say or me in the chat bar
	if(hud_typing)
		return
	INVOKE_ASYNC(src, PROC_REF(poll_chatbar_typing))

/// Reads the chat bar (winget sleeps, so this runs async) and shows the bubble while a say or me is being written there
/mob/proc/poll_chatbar_typing()
	var/client/user = client
	if(!user || polling_chatbar)
		return
	polling_chatbar = TRUE
	var/typed = winget(user, "input", "text")
	var/command = winget(user, "input", "command")
	polling_chatbar = FALSE
	if(QDELETED(src) || client != user || hud_typing || stat)
		return
	set_typing_indicator(is_chatbar_speech("[command][typed]"))

/// Whether the chat bar holds a say or me with some text after the verb
/proc/is_chatbar_speech(line)
	line = LOWER_TEXT(trim_left(line))
	if(findtext(line, "!", 1, 2))
		line = copytext(line, 2)
	var/rest
	if(findtext(line, "say ", 1, 5) || findtext(line, "say\"", 1, 5))
		rest = copytext(line, 4)
	else if(findtext(line, "me ", 1, 4) || findtext(line, "me\"", 1, 4))
		rest = copytext(line, 3)
	else
		return FALSE
	rest = replacetext(rest, "\"", "")
	return length(trim(rest)) > 0

/mob/proc/set_afk_indicator(state)
	if(!afk_indicator)
		afk_indicator = mutable_appearance('icons/mob/ssd_indicator.dmi', "default0", FLY_LAYER)
		afk_indicator.alpha = 200
		afk_indicator.pixel_y = 16

	if(state)
		if(!afk_indicator_active)
			add_overlay(afk_indicator)
			afk_indicator_active = TRUE
	else
		if(afk_indicator_active)
			cut_overlay(afk_indicator)
			afk_indicator_active = FALSE
	return state
